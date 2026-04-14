# 📦 Installation

This guide explains how to install pip-analyzer globally on your system.

---

## 🧠 Notes on PATH

Changes to PATH may require restarting the terminal session to take effect.

On some systems, you may need to reopen your shell or log out and back in.

---

## 🪟 Windows

Run:

```powershell
.\install.ps1
```

This will:

- Copy the script to `%LOCALAPPDATA%\pip-analyzer`
- Add it to your PATH
- Enable global usage

---

## 🍎 macOS / 🐧 Linux

Run:

```bash
chmod +x install.sh
./install.sh
```

Then ensure your PATH includes:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## 🌍 Global Usage

After installation:

```bash
pip-analyze
```

You can run it from any directory.

---

## 📁 Installation Paths

| OS        | Location |
|----------|---------|
| Windows  | `%LOCALAPPDATA%\pip-analyzer` |
| macOS/Linux | `~/.local/share/pip-analyzer` |

---

## 🧹 Uninstall

### Windows
```powershell
.\uninstall.ps1
```

### macOS / Linux
```bash
./uninstall.sh
```

---

## ⚠️ Notes

- Requires PowerShell 7+
- Requires Python and pip
- Requires pip-size

Install dependency:

```bash
pip install pip-size
```