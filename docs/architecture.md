# 🏗️ Architecture

This document explains how pip-analyzer works internally.

---

## 🔄 Execution Flow

1. Collect installed packages:

```bash
pip list --format=freeze (or equivalent command)
```

2. Parse package list into structured entries

3. For each package:

- invoke `pip-size` as an external process
- capture output
- extract size using regex
- normalize size to KB for consistent comparison

4. Store results in memory

5. Calculate metrics:

- Instant speed (current iteration)
- Average speed (global)
- Moving average (sliding window)

6. Render output:

- progress bar (`Write-Progress`)
- formatted table

---

## 📦 Data Model

Each package is represented as:

```
Package
Version
Size
SizeKB
```

---

## 🧠 Key Design Decisions

### Sequential Execution

- simpler logic
- deterministic output
- stable progress tracking

**Trade-off:**
- slower for large environments

---

### External Tool: pip-size

Used for:

- accurate package size estimation

**Trade-off:**
- depends on external execution
- may involve network/cache latency

---

### Regex Parsing

Used to extract size from `pip-size` output.

**Advantages:**

- flexible
- tolerant to format variations

---

### In-memory Aggregation

All results are stored in memory before final sorting.

**Advantages:**

- flexible sorting
- easy transformations

---

## 📊 Metrics System

Tracks:

- Instant speed → current processing rate
- Average speed → overall performance
- Moving average → smoothed short-term trend

**Purpose:**

- observability
- performance feedback

---

## ⚠️ Limitations

- sequential execution
- dependency on external tool (`pip-size`)
- no dependency tree awareness