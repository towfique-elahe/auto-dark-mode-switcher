# AutoThemeGUI.ps1
# Version
$LocalVersion = "1.0.0"

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Host "Error loading GUI libraries. Are you on a minimal PowerShell?"
    pause
    exit
}

# === GUI SETUP ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Auto Dark Mode Switcher"
$form.Size = New-Object System.Drawing.Size(400, 330)
$form.StartPosition = "CenterScreen"

$labelLocation = New-Object System.Windows.Forms.Label
$labelLocation.Text = "Location: Detecting..."
$labelLocation.AutoSize = $true
$labelLocation.Location = New-Object System.Drawing.Point(20,20)
$form.Controls.Add($labelLocation)

$labelSunrise = New-Object System.Windows.Forms.Label
$labelSunrise.Text = "Sunrise: ..."
$labelSunrise.AutoSize = $true
$labelSunrise.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($labelSunrise)

$labelSunset = New-Object System.Windows.Forms.Label
$labelSunset.Text = "Sunset: ..."
$labelSunset.AutoSize = $true
$labelSunset.Location = New-Object System.Drawing.Point(20, 80)
$form.Controls.Add($labelSunset)

$labelVersion = New-Object System.Windows.Forms.Label
$labelVersion.Text = "Version: $LocalVersion"
$labelVersion.AutoSize = $true
$labelVersion.Location = New-Object System.Drawing.Point(20, 280)
$form.Controls.Add($labelVersion)

$btnLight = New-Object System.Windows.Forms.Button
$btnLight.Text = "Set Light Mode"
$btnLight.Size = New-Object System.Drawing.Size(120, 30)
$btnLight.Location = New-Object System.Drawing.Point(20, 130)
$btnLight.Add_Click({
    Set-ThemeMode -Mode "light"
})
$form.Controls.Add($btnLight)

$btnDark = New-Object System.Windows.Forms.Button
$btnDark.Text = "Set Dark Mode"
$btnDark.Size = New-Object System.Drawing.Size(120, 30)
$btnDark.Location = New-Object System.Drawing.Point(160, 130)
$btnDark.Add_Click({
    Set-ThemeMode -Mode "dark"
})
$form.Controls.Add($btnDark)

$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "Install Auto Switch"
$btnInstall.Size = New-Object System.Drawing.Size(180, 30)
$btnInstall.Location = New-Object System.Drawing.Point(20, 180)
$btnInstall.Add_Click({
    Install-Scheduler
})
$form.Controls.Add($btnInstall)

$btnUninstall = New-Object System.Windows.Forms.Button
$btnUninstall.Text = "Uninstall Auto Switch"
$btnUninstall.Size = New-Object System.Drawing.Size(180, 30)
$btnUninstall.Location = New-Object System.Drawing.Point(20, 220)
$btnUninstall.Add_Click({
    Uninstall-Scheduler
})
$form.Controls.Add($btnUninstall)

# === VERSION CHECK ===
function Check-ForUpdate {
    try {
        $remoteUrl = "https://raw.githubusercontent.com/towfique-elahe/auto-dark-mode-switcher/main/version.txt"
        $remoteVersion = Invoke-RestMethod -Uri $remoteUrl -UseBasicParsing
        if ($remoteVersion -ne $LocalVersion) {
            $resp = [System.Windows.Forms.MessageBox]::Show(
                "A new version ($remoteVersion) is available!`nDo you want to open the release page?",
                "Update Available",
                [System.Windows.Forms.MessageBoxButtons]::YesNo
            )
            if ($resp -eq [System.Windows.Forms.DialogResult]::Yes) {
                Start-Process "https://github.com/towfique-elahe/auto-dark-mode-switcher/releases/latest"
            }
        }
    } catch {
        Write-Host "Update check failed: $_"
    }
}

# === THEME SWITCH FUNCTION ===
function Set-ThemeMode {
    param([string]$Mode)

    try {
        $value = if ($Mode -eq "dark") { 0 } else { 1 }
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

        # Apply registry keys
        Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Value $value
        Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Value $value

        # Use Windows API to broadcast theme change
        $signature = @"
using System;
using System.Runtime.InteropServices;

public class NativeMethods {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
        uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@

        Add-Type $signature

        $HWND_BROADCAST = [intptr]0xffff
        $WM_SETTINGCHANGE = 0x001A
        $SMTO_ABORTIFHUNG = 0x0002
        $result = [uintptr]::Zero

        [NativeMethods]::SendMessageTimeout(
            $HWND_BROADCAST,
            $WM_SETTINGCHANGE,
            [uintptr]::Zero,
            "ImmersiveColorSet",
            $SMTO_ABORTIFHUNG,
            100,
            [ref]$result
        )

        [System.Windows.Forms.MessageBox]::Show("Switched to $Mode mode.", "Success")

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to set theme: $_", "Error")
    }
}

# === INSTALL SCHEDULER ===
function Install-Scheduler {
    try {
        # Get location
        $loc = Invoke-RestMethod -Uri "http://ip-api.com/json"
        $lat = $loc.lat
        $lon = $loc.lon

        # Get sunrise/sunset
        $sun = Invoke-RestMethod -Uri "https://api.sunrise-sunset.org/json?lat=$lat&lng=$lon&formatted=0"
        if ($sun.status -ne "OK") { throw "API error" }

        $sunriseLocal = ([datetime]::Parse($sun.results.sunrise)).ToLocalTime()
        $sunsetLocal  = ([datetime]::Parse($sun.results.sunset)).ToLocalTime()

        # Create Set-Theme.ps1
        $themeScript = "$env:USERPROFILE\AutoTheme\Set-Theme.ps1"
        if (!(Test-Path (Split-Path $themeScript))) {
            New-Item -ItemType Directory -Path (Split-Path $themeScript) | Out-Null
        }

$scriptLines = @'
param([string]$Mode)
if ($Mode -eq "dark") { $val = 0 } elseif ($Mode -eq "light") { $val = 1 } else { exit }
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $path -Name "SystemUsesLightTheme" -Value $val
Set-ItemProperty -Path $path -Name "AppsUseLightTheme" -Value $val

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
  [DllImport("user32.dll", SetLastError = true)]
  public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
}
"@

$HWND_BROADCAST = [intptr]0xffff
$WM_SETTINGCHANGE = 0x001A
$SMTO_ABORTIFHUNG = 0x0002
$result = [uintptr]::Zero
[NativeMethods]::SendMessageTimeout(
  $HWND_BROADCAST, $WM_SETTINGCHANGE, [uintptr]::Zero,
  "ImmersiveColorSet", $SMTO_ABORTIFHUNG, 100, [ref]$result
)
'@

        Set-Content -Path $themeScript -Value $scriptLines

        # Create scheduled tasks
        $lightAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$themeScript`" -Mode light"
        $darkAction  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$themeScript`" -Mode dark"

        $lightTrigger = New-ScheduledTaskTrigger -Once -At $sunriseLocal -RepetitionInterval (New-TimeSpan -Days 1) -RepetitionDuration ([TimeSpan]::MaxValue)
        $darkTrigger  = New-ScheduledTaskTrigger -Once -At $sunsetLocal  -RepetitionInterval (New-TimeSpan -Days 1) -RepetitionDuration ([TimeSpan]::MaxValue)

        Register-ScheduledTask -TaskName "AutoLightTheme" -Action $lightAction -Trigger $lightTrigger -Force -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable)
        Register-ScheduledTask -TaskName "AutoDarkTheme"  -Action $darkAction  -Trigger $darkTrigger  -Force -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable)

        # Immediately apply correct mode
        $now = Get-Date
        if ($now -ge $sunsetLocal -or $now -lt $sunriseLocal) {
            Set-ThemeMode -Mode "dark"
        } else {
            Set-ThemeMode -Mode "light"
        }

        [System.Windows.Forms.MessageBox]::Show("✅ Auto-switch installed.`nLight at $sunriseLocal`nDark at $sunsetLocal", "Done")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("❌ Failed: $_", "Install Scheduler")
    }
}

# === UNINSTALL SCHEDULER ===
function Uninstall-Scheduler {
    try {
        Unregister-ScheduledTask -TaskName "AutoLightTheme" -Confirm:$false -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName "AutoDarkTheme" -Confirm:$false -ErrorAction SilentlyContinue

        $themeScript = "$env:USERPROFILE\AutoTheme\Set-Theme.ps1"
        if (Test-Path $themeScript) {
            Remove-Item $themeScript -Force
        }

        [System.Windows.Forms.MessageBox]::Show("🚫 Auto switch tasks removed.", "Uninstalled")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error removing tasks: $_", "Uninstall Failed")
    }
}

# === INITIAL LOCATION & SUN DATA ===
try {
    $loc = Invoke-RestMethod -Uri "http://ip-api.com/json"
    $lat = $loc.lat
    $lon = $loc.lon
    $labelLocation.Text = "Location: $($loc.city), $($loc.country)"

    $sunData = Invoke-RestMethod -Uri "https://api.sunrise-sunset.org/json?lat=$lat&lng=$lon&formatted=0"
    $sunrise = ([datetime]::Parse($sunData.results.sunrise)).ToLocalTime()
    $sunset = ([datetime]::Parse($sunData.results.sunset)).ToLocalTime()

    $labelSunrise.Text = "Sunrise: $sunrise"
    $labelSunset.Text = "Sunset: $sunset"
} catch {
    $labelLocation.Text = "Failed to detect location."
    $labelSunrise.Text = "Sunrise: N/A"
    $labelSunset.Text = "Sunset: N/A"
}

# === Show GUI & Check for Updates ===
$form.Topmost = $true
$form.Add_Shown({ 
    $form.Activate()
    Check-ForUpdate
})
[void]$form.ShowDialog()
