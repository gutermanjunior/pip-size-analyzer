<#
==============================================================
 Script: Python Package Size Analyzer
 Versão: 1.2
 Autor: Guterman Junior
 Data: 2026-04-14

==============================================================
 DESCRIÇÃO

 Ferramenta para análise de tamanho de pacotes Python
 instalados no ambiente atual (venv/global).

 Fornece:

 - Visão quantitativa (tamanho total)
 - Comparação entre pacotes
 - Observabilidade em tempo real
 - Diagnóstico de ambiente Python

--------------------------------------------------------------
 FUNCIONALIDADES

 - Coleta de pacotes via `pip list`
 - Cálculo de tamanho via `pip-size`
 - Exibição incremental com overwrite de linha
 - Barra de progresso dinâmica
 - Métricas:
     * Velocidade instantânea (Inst)
     * Média global (Avg)
     * Média móvel (Mov N=5)
 - Ordenação:
     * Nome
     * Tamanho
     * Ordem original
 - Soma total acumulada

--------------------------------------------------------------
 NOVIDADES v1.2

 - Cache inteligente baseado em `pip freeze`
 - Modo CLI (sem interação)
 - Exportação (CSV / JSON)
 - Top N maiores pacotes
 - Melhor feedback operacional

--------------------------------------------------------------
 DEPENDÊNCIAS

 - Python + pip
 - pip-size (pip install pip-size)

--------------------------------------------------------------
 OBSERVAÇÕES TÉCNICAS

 - Parsing via regex (tolerante)
 - Normalização para KB (comparação correta)
 - Encoding UTF-8 para evitar problemas de output
 - Overwrite de linha com `\r`
 - Uso de List<T> (evita O(n²))
 - Cache por hash do ambiente

--------------------------------------------------------------
 LIMITAÇÕES

 - pip-size pode ser lento (rede/cache)
 - Tamanho não é deduplicado entre dependências
 - Representa distribuição (wheel), não disco real
 - Execução sequencial (sem paralelismo nesta versão)

==============================================================
#>

param(
    [ValidateSet("Name","Size","Original")]
    [string]$Sort,

    [int]$Top = 10,

    [switch]$FastMode,
    [switch]$UseCache,

    [ValidateSet("csv","json","")]
    [string]$Export = ""
)

# ============================================================
# CONFIGURAÇÃO
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONUTF8 = "1"

# ============================================================
# FUNÇÕES
# ============================================================

function Convert-ToKB {
    param($size)

    if ([string]::IsNullOrWhiteSpace($size)) { return 0 }

    $value = [double](($size -replace '[^0-9.]',''))

    if ($size -match 'GB') { return $value * 1024 * 1024 }
    elseif ($size -match 'MB') { return $value * 1024 }
    elseif ($size -match 'KB') { return $value }
    elseif ($size -match 'B') { return $value / 1024 }
    else { return 0 }
}

function Format-Size {
    param($kb)

    if ($kb -ge 1024*1024) { return "{0:N2} GB" -f ($kb / (1024*1024)) }
    elseif ($kb -ge 1024) { return "{0:N2} MB" -f ($kb / 1024) }
    else { return "{0:N2} KB" -f $kb }
}

function Get-EnvironmentHash {

    Write-Host ""
    Write-Host "🔍 Gerando fingerprint do ambiente Python..." -ForegroundColor DarkGray
    Write-Host "   Isso garante que o cache só será usado se o ambiente não mudou." -ForegroundColor DarkGray

    $envState = pip freeze | Out-String
    $bytes = [Text.Encoding]::UTF8.GetBytes($envState)
    $stream = [IO.MemoryStream]::new($bytes)

    return (Get-FileHash -InputStream $stream).Hash
}

# ============================================================
# VALIDAÇÃO
# ============================================================

if (-not $FastMode) {
    if (-not (Get-Command pip-size -ErrorAction SilentlyContinue)) {
        Write-Host ""
        Write-Host "❌ Dependência não encontrada: pip-size" -ForegroundColor Red
        Write-Host "👉 Instale com: pip install pip-size" -ForegroundColor Yellow
        return
    }
}

# ============================================================
# INTERFACE
# ============================================================

if (-not $Sort) {

    Write-Host ""
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host " Análise de pacotes do Python " -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Este script analisa o tamanho dos pacotes instalados no seu ambiente Python." -ForegroundColor DarkGray
    Write-Host "Dependendo da quantidade de pacotes e da rede, pode levar algum tempo." -ForegroundColor DarkGray
    Write-Host ""

    if ($FastMode) {
        Write-Host "⚡ Modo rápido ativado → tamanhos NÃO serão calculados" -ForegroundColor Yellow
    }
    if ($UseCache) {
        Write-Host "🧠 Cache ativado → resultados anteriores podem ser reutilizados" -ForegroundColor Yellow
    }
    if ($Export) {
        Write-Host "📤 Exportação ativada → formato: $Export" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Escolha como deseja visualizar o resultado:" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "1 - Nome       → fácil busca manual" -ForegroundColor Green
    Write-Host "    (não destaca os maiores)" -ForegroundColor DarkGray

    Write-Host "2 - Tamanho    → identifica pacotes pesados" -ForegroundColor Green
    Write-Host "    (ordem final só após coleta)" -ForegroundColor DarkGray

    Write-Host "3 - Original   → ordem do pip list" -ForegroundColor Green
    Write-Host "    (sem análise comparativa)" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host "Digite apenas: 1, 2 ou 3" -ForegroundColor Cyan

    $choice = Read-Host "Opção"

    if ($choice -eq "1") { $Sort = "Name" }
    elseif ($choice -eq "2") { $Sort = "Size" }
    else { $Sort = "Original" }
}
else {
    Write-Host ""
    Write-Host "Modo CLI detectado → execução não interativa" -ForegroundColor Cyan
    Write-Host "Sort = $Sort | Top = $Top | Cache = $UseCache | Export = $Export" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "🚀 Iniciando análise..." -ForegroundColor Yellow
Write-Host "📦 Coletando lista de pacotes instalados..." -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# INICIALIZAÇÃO
# ============================================================

$pips = pip list --format=freeze
$total = $pips.Count
$current = 0
$startTime = Get-Date

Write-Host "Total de pacotes detectados: $total" -ForegroundColor Cyan
Write-Host ""

$result = New-Object System.Collections.Generic.List[object]
$totalSizeKB = 0

# ============================================================
# CACHE
# ============================================================

$cacheFile = "pip-size-cache-v2.json"
$cacheData = @{}
$cache = @{}

if ($UseCache) {

    $hash = Get-EnvironmentHash

    if (Test-Path $cacheFile) {
        $cacheData = Get-Content $cacheFile | ConvertFrom-Json -AsHashtable
    }

    if ($cacheData.ContainsKey($hash)) {
        Write-Host "✅ Cache válido encontrado para este ambiente" -ForegroundColor Green
        Write-Host "   Pacotes já analisados não serão recalculados" -ForegroundColor DarkGray
        $cache = $cacheData[$hash]
    }
    else {
        Write-Host "⚠️ Nenhum cache válido encontrado" -ForegroundColor Yellow
        Write-Host "   Um novo cache será criado ao final da execução" -ForegroundColor DarkGray
        $cache = @{}
    }

    Write-Host ""
}

# ============================================================
# PROCESSAMENTO
# ============================================================

$sizeRegex = [regex]'\d+(\.\d+)?\s*(KB|MB|GB)'
$lastTimes = @()
$windowSize = 5

foreach ($line in $pips) {

    $name, $version = $line -split "=="

    Write-Host ("Processando pacote: {0}" -f $name) -NoNewline -ForegroundColor DarkGray

    $pkgStart = Get-Date
    $size = "N/A"

    if ($FastMode) {
        $size = "0 KB"
    }
    elseif ($cache.ContainsKey($name)) {
        $size = $cache[$name]
    }
    else {
        try {
            $output = & pip-size $name 2>&1 | Out-String
            $match = $sizeRegex.Match($output)

            if ($match.Success) {
                $size = $match.Value
                if ($UseCache) { $cache[$name] = $size }
            }
        } catch {
            $size = "ERR"
        }
    }

    # métricas
    $pkgSeconds = [math]::Max(((Get-Date) - $pkgStart).TotalSeconds, 0.001)
    $instSpeed = 1 / $pkgSeconds

    $lastTimes += $pkgSeconds
    if ($lastTimes.Count -gt $windowSize) {
        $lastTimes = $lastTimes[-$windowSize..-1]
    }

    $movSpeed = 1 / [math]::Max(($lastTimes | Measure-Object -Average).Average, 0.001)

    $current++
    $elapsed = (Get-Date) - $startTime
    $avgSpeed = $current / [math]::Max($elapsed.TotalSeconds,1)
    $percent = [int](($current / $total) * 100)

    Write-Progress `
        -Activity "Analisando pacotes Python" `
        -Status ("{0}/{1} | {2} | Inst: {3:N1} pkg/s | Avg: {4:N1} pkg/s | Mov({5}): {6:N1} pkg/s" -f `
            $current, $total, $name, $instSpeed, $avgSpeed, $windowSize, $movSpeed) `
        -PercentComplete $percent

    $kb = Convert-ToKB $size

    $obj = [PSCustomObject]@{
        Package = $name
        Version = $version
        Size    = $size
        SizeKB  = $kb
    }

    $result.Add($obj)
    $totalSizeKB += $kb

    Write-Host ("`r{0,-25} {1,-12} {2,12}" -f $name, $version, $size)
}

Write-Progress -Completed

# ============================================================
# SALVAR CACHE
# ============================================================

if ($UseCache) {
    $cacheData[$hash] = $cache
    $cacheData | ConvertTo-Json | Out-File $cacheFile
    Write-Host ""
    Write-Host "💾 Cache atualizado para este ambiente" -ForegroundColor DarkGray
}

# ============================================================
# RESULTADO FINAL
# ============================================================

Write-Host ""
Write-Host "✅ Coleta concluída com sucesso" -ForegroundColor Green
Write-Host ("📦 Total acumulado: {0}" -f (Format-Size $totalSizeKB)) -ForegroundColor Cyan
Write-Host ""

if ($Sort -eq "Name") {
    Write-Host "Resultado ordenado por nome:" -ForegroundColor Cyan
    $result = $result | Sort-Object Package
}
elseif ($Sort -eq "Size") {
    Write-Host "Resultado ordenado por tamanho (maiores primeiro):" -ForegroundColor Cyan
    $result = $result | Sort-Object SizeKB -Descending
}
else {
    Write-Host "Resultado na ordem original do pip:" -ForegroundColor Cyan
}

$result | Format-Table Package, Version, Size -AutoSize

# ============================================================
# TOP N
# ============================================================

Write-Host ""
Write-Host "🏆 Top $Top maiores pacotes:" -ForegroundColor Yellow

$result | Sort-Object SizeKB -Descending | Select-Object -First $Top |
Format-Table Package, Size

# ============================================================
# EXPORTAÇÃO
# ============================================================

if ($Export -eq "csv") {
    $result | Export-Csv "packages.csv" -NoTypeInformation
    Write-Host "📄 Exportado para packages.csv" -ForegroundColor Green
}
elseif ($Export -eq "json") {
    $result | ConvertTo-Json | Out-File "packages.json"
    Write-Host "📄 Exportado para packages.json" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 Análise finalizada." -ForegroundColor Green