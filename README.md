# 📦 pip-analyzer

> 🔍 Python package size analyzer with real-time metrics, smart caching, and CLI support.

---

## 🚀 Overview

`pip-analyzer` is a PowerShell-based tool designed to analyze the size of Python packages installed in your environment.

It provides:

- 📊 Real-time progress and performance metrics
- 📦 Package size analysis using `pip-size`
- ⚡ Smart caching based on environment state
- 🧠 Insight into dependency impact
- 🖥️ CLI and interactive modes

---

## ✨ Features

- 🔎 Analyze installed Python packages (`pip list`)
- 📏 Measure package sizes (`pip-size`)
- 📈 Real-time metrics:
  - Instant speed (Inst)
  - Average speed (Avg)
  - Moving average (Mov)
- 🧾 Sorting options:
  - Name
  - Size
  - Original order
- 🧠 Smart cache (based on `pip freeze`)
- 📤 Export results:
  - CSV
  - JSON
- 🏆 Top N largest packages

---

## 🧠 How Smart Cache Works

The cache system is based on the **state of your Python environment**.

### 🔍 Process

1. Captures environment using:
   ```bash
   pip freeze
   ```

2. Generates a hash from this state

3. Uses the hash as a cache key

---

### 🎯 Result

| Scenario            | Behavior        |
|--------------------|----------------|
| Same environment   | ⚡ Uses cache  |
| Updated package    | 🔄 Recalculate |
| New environment    | 🔄 New cache   |

---

## 📦 Requirements

- Python 3.x
- pip
- pip-size

Install dependency:

```bash
pip install pip-size
```

---

## ▶️ Usage

### Interactive mode

```powershell
.\pip-size.ps1
```

---

### CLI mode

```powershell
.\pip-size.ps1 -Sort Size -Top 10 -UseCache
```

---

### With export

```powershell
.\pip-size.ps1 -Sort Size -Export csv
```

---

## ⚙️ Parameters

| Parameter   | Description |
|------------|------------|
| `-Sort`    | Name / Size / Original |
| `-Top`     | Top N largest packages |
| `-UseCache`| Enable smart cache |
| `-FastMode`| Skip size calculation |
| `-Export`  | csv / json |

---

## 📊 Example Output

```
Total packages: 57

numpy        1.26.0     12.3 MB
pandas       2.2.1      45.1 MB
requests     2.31.0     1.2 MB
```

---

## ⚠️ Limitations

- `pip-size` can be slow (network/cache dependent)
- Size is not deduplicated across dependencies
- Represents package distribution size (wheel), not actual disk usage
- Execution is sequential (no parallelism yet)

---

## 🛠️ Tech Details

- PowerShell 7+
- Regex-based parsing
- UTF-8 encoding handling
- Real-time terminal rendering (`Write-Progress`)
- Optimized collections (List<T>)

---

## 🧩 Future Improvements

- ⚡ Parallel processing (multi-threaded)
- 📊 Visualization (charts / dashboards)
- 🔍 Dependency tree analysis
- 🧠 Smarter caching strategies

---

## 📄 License

MIT

---

## 👨‍💻 Author

Guterman Junior