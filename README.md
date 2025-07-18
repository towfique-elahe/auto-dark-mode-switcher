# 🌗 Auto Dark Mode Switcher for Windows

**Version**: `v1.0.0`  
A lightweight PowerShell GUI tool that automatically transitions between **Light Mode** and **Dark Mode** based on **local sunrise and sunset** times — featuring auto location detection, clean theme switching (no Explorer restart), and scheduler integration via Windows Task Scheduler.

---

## ✨ Features

- 🧭 **Auto-detects location** using your IP
- ☀️ Automatically switches to **Light Theme** at local sunrise
- 🌙 Automatically switches to **Dark Theme** at local sunset
- 🖱 Manual control: `Set Light Mode` / `Set Dark Mode` buttons
- ⚙️ One-click **Install Auto Switch** to schedule daily theme changes
- ❌ Includes **Uninstall Auto Switch** for clean removal
- 🔄 Applies theme changes without restarting Explorer or closing active File Explorer windows
- ✅ No external dependencies — 100% native PowerShell and Windows

---

## 📸 Screenshots

> Replace with actual screenshots when ready

| App Interface | Theme Activated |
|---------------|------------------|
| ![GUI preview](https://via.placeholder.com/320x200.png?text=App+GUI) | ![Example light/dark](https://via.placeholder.com/320x200.png?text=Theme+Changed) |

---

## ⚙️ Requirements

| Requirement      | Description                                  |
|------------------|----------------------------------------------|
| Windows Version   | Windows 10 or 11                             |
| PowerShell        | v5.1 or newer (installed by default)        |
| Internet Access   | Required for location and sunrise/sunset data |
| Admin Rights      | Only required when installing scheduled tasks |

---

## 🚀 Getting Started

### 1. Clone the Repository or Download ZIP
```bash
git clone https://github.com/towfique-elahe/auto-dark-mode-switcher.git
````

Or use the **Download ZIP** option on GitHub.

### 2. Launch the Application

* **Double-click** `RunAutoTheme.bat`
  —or—
* **Right-click** `AutoThemeGUI.ps1` → **Run with PowerShell**

### 3. Use the Interface

* ✅ Click **Set Light Mode** / **Set Dark Mode** to transfer manually
* ⚙️ Click **Install Auto Switch** to set up scheduled switching
* ❌ Click **Uninstall Auto Switch** to remove automation and cleanup files

---

## 📅 How the Scheduler Works

When you click **Install Auto Switch**:

1. It fetches your location (via `ip-api.com`)
2. Retrieves today's sunrise/sunset time (via `sunrise-sunset.org`)
3. Creates two scheduled tasks:

   * **AutoLightTheme**: runs daily at sunrise
   * **AutoDarkTheme**: runs daily at sunset
4. Immediately applies the correct theme upon setup
5. Runs quietly in the background without user interaction

---

## 🧼 Removing the Scheduler

Click the **Uninstall Auto Switch** button to:

* Delete both scheduled tasks
* Remove the helper script (`Set-Theme.ps1`)
* Leave your current theme untouched

---

## 🔄 Auto-Updater (Planning Ahead)

An update checker is built into the interface for future releases. When enabled:

* It queries your GitHub repo for the latest version
* Prompts you to download and update automatically (or via browser link)

> Coming in **v1.x.x**

---

## 📁 Project Structure

```text
auto-dark-mode-switcher/
├── AutoThemeGUI.ps1      # Main PowerShell GUI application
├── RunAutoTheme.bat      # Launcher script for easy double-click usage
└── README.md             # This file
```

---

## 📘 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🛠 Author

**Towfique Elahe**
Feel free to fork, submit issues, request features, or contribute improvements.

---

## 📞 Contact or Contribute

* GitHub: [towfique-elahe/auto-dark-mode-switcher](https://github.com/towfique-elahe/auto-dark-mode-switcher)
* Issues: [Open a new issue](https://github.com/towfique-elahe/auto-dark-mode-switcher/issues)

> Keep your desktop in sync with the sun — effortlessly!
