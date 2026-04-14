# 🧠 Smart Cache

This document explains how the caching system works.

---

## 📌 Concept

The cache is based on the **state of the Python environment**, not the current directory.

---

## 🔍 How it works

1. Capture environment:

```bash
pip freeze
```

2. Generate a hash from the full environment snapshot

3. Use this hash as a cache key

4. Store and retrieve package size results using this key

---

## 📁 Storage Location

| OS        | Location |
|----------|---------|
| Windows  | `%LOCALAPPDATA%\pip-analyzer\cache.json` |
| macOS/Linux | `~/.local/share/pip-analyzer/cache.json` |

---

## 🎯 Behavior

| Scenario            | Result |
|--------------------|--------|
| Same environment   | Uses cache |
| Updated package    | Recalculate |
| New environment    | New cache |

---

## 💡 Why this approach

Ensures:

- correctness (no stale data)
- reproducibility
- performance gains for repeated runs

---

## ⚠️ Limitations

- cache invalidates fully on any environment change
- no incremental reuse yet

---

## 🚀 Future Improvement

Incremental cache:

- per-package caching
- partial reuse