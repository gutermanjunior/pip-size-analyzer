# ▶️ Usage

This guide shows how to use pip-analyzer in real scenarios.

---

## 🚀 Basic Usage

Run:

```bash
pip-analyze
```

This opens interactive mode.

---

## ⚙️ CLI Mode

```bash
pip-analyze -Sort Size -Top 10 -UseCache
```

---

## 📊 Example Output

```
Processing packages...

numpy        1.26.0     12.3 MB
pandas       2.2.1      45.1 MB
requests     2.31.0     1.2 MB

Total packages: 57
```

---

## 📊 Sorting Options

```bash
pip-analyze -Sort Name
pip-analyze -Sort Size
pip-analyze -Sort Original
```

---

## 🏆 Top Packages

```bash
pip-analyze -Top 5
```

---

## 🧠 Cache

```bash
pip-analyze -UseCache
```

Speeds up repeated analysis.

---

## ⚡ Fast Mode

```bash
pip-analyze -FastMode
```

Skips size calculation.

---

## 📤 Export

```bash
pip-analyze -Export csv
pip-analyze -Export json
```

---

## 🧪 Real Use Cases

### Identify heavy dependencies

```bash
pip-analyze -Sort Size
```

---

### Debug environment bloat

```bash
pip-analyze -Top 20
```

---

### Quick overview (fast)

```bash
pip-analyze -FastMode
```

---

## 🧠 Tips

- Use cache for repeated runs
- Use sorting by size for insights
- Use top N to focus analysis

---

## 🧠 When to use each mode

- **Interactive mode**  
  Best for manual exploration and first-time usage

- **CLI mode**  
  Best for automation, scripts, and repeatable workflows

- **Fast mode**  
  Useful for quick inspections without external calls

- **Cache enabled**  
  Ideal when analyzing the same environment multiple times