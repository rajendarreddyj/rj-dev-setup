#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Java Developer Workstation Setup Script
.DESCRIPTION
    This script automatically installs and configures essential Java development tools
    including Java JDK, Maven, Gradle, VS Code, Eclipse, IntelliJ IDEA, and Android Studio.
    It also sets up proper environment variables and can update existing installations.
.AUTHOR
    Java Developer Setup Script
.DATE
    September 15, 2025
#>

param(
    [switch]$UpdateExisting = $false,
    [switch]$SkipJava = $false,
    [switch]$SkipIDEs = $false,
    [string]$LogPath = "$env:TEMP\JavaDevSetup.log"
)

# Initialize logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry
    Add-Content -Path $LogPath -Value $logEntry
}

# Check if script is running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install Chocolatey if not present
function Install-Chocolatey {
    Write-Log "Checking for Chocolatey..."
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Installing Chocolatey..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            Write-Log "Chocolatey installed successfully" "SUCCESS"
        } catch {
            Write-Log "Failed to install Chocolatey: $($_.Exception.Message)" "ERROR"
            return $false
        }
    } else {
        Write-Log "Chocolatey is already installed" "SUCCESS"
    }
    return $true
}

# Install or update a package via Chocolatey
function Install-ChocoPackage {
    param(
        [string]$PackageName,
        [string]$DisplayName = $PackageName,
        [switch]$Force = $UpdateExisting
    )

    Write-Log "Processing $DisplayName..."

    try {
        if ($Force) {
            Write-Log "Installing/Updating $DisplayName (forced)..."
            choco install $PackageName -y --force
        } else {
            $installed = choco list --local-only | Select-String "^$PackageName "
            if ($installed) {
                Write-Log "$DisplayName is already installed" "INFO"
                if ($UpdateExisting) {
                    Write-Log "Updating $DisplayName..."
                    choco upgrade $PackageName -y
                }
            } else {
                Write-Log "Installing $DisplayName..."
                choco install $PackageName -y
            }
        }
        Write-Log "$DisplayName processed successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to install $DisplayName : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Set environment variable
function Set-EnvironmentVariable {
    param(
        [string]$Name,
        [string]$Value,
        [string]$Scope = "Machine"
    )

    try {
        Write-Log "Setting environment variable $Name = $Value"
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        Write-Log "Environment variable $Name set successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to set environment variable $Name : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Update PATH environment variable
function Add-ToPath {
    param([string]$NewPath)

    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$NewPath*") {
            Write-Log "Adding $NewPath to PATH"
            $newPathValue = "$currentPath;$NewPath"
            [Environment]::SetEnvironmentVariable("PATH", $newPathValue, "Machine")
            Write-Log "PATH updated successfully" "SUCCESS"
        } else {
            Write-Log "$NewPath is already in PATH" "INFO"
        }
        return $true
    } catch {
        Write-Log "Failed to update PATH: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Find Java installation path
function Get-JavaPath {
    $javaPath = $null

    # Check common Java installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\Java",
        "${env:ProgramFiles(x86)}\Java",
        "${env:ProgramFiles}\Eclipse Adoptium",
        "${env:ProgramFiles}\Microsoft\jdk-*"
    )

    foreach ($basePath in $commonPaths) {
        if (Test-Path $basePath) {
            $jdkFolders = Get-ChildItem $basePath -Directory | Where-Object { $_.Name -match "jdk" } | Sort-Object Name -Descending
            if ($jdkFolders) {
                $javaPath = $jdkFolders[0].FullName
                break
            }
        }
    }

    return $javaPath
}

# Main installation function
function Start-Installation {
    Write-Log "Starting Java Developer Workstation Setup..." "INFO"
    Write-Log "Log file: $LogPath" "INFO"

    # Check administrator privileges
    if (!(Test-Administrator)) {
        Write-Log "This script must be run as Administrator!" "ERROR"
        Write-Host "Please restart PowerShell as Administrator and try again." -ForegroundColor Red
        exit 1
    }

    # Install Chocolatey
    if (!(Install-Chocolatey)) {
        Write-Log "Cannot continue without Chocolatey" "ERROR"
        exit 1
    }

    # Refresh environment variables for this session
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    Write-Log "Installing Java Development Tools..." "INFO"

    # Install Java JDK (if not skipped)
    if (!$SkipJava) {
        Write-Log "Installing Java JDK..."
        Install-ChocoPackage -PackageName "microsoft-openjdk-21" -DisplayName "Microsoft OpenJDK 21"
    }

    # Install Build Tools
    Write-Log "Installing Build Tools..."
    Install-ChocoPackage -PackageName "maven" -DisplayName "Apache Maven"
    Install-ChocoPackage -PackageName "gradle" -DisplayName "Gradle"
    Install-ChocoPackage -PackageName "tomcat" -DisplayName "Apache Tomcat"

    # Install IDEs and Editors (if not skipped)
    if (!$SkipIDEs) {
        Write-Log "Installing IDEs and Editors..."
        Install-ChocoPackage -PackageName "vscode" -DisplayName "Visual Studio Code"
        Install-ChocoPackage -PackageName "eclipse" -DisplayName "Eclipse IDE"
        Install-ChocoPackage -PackageName "intellijidea-community" -DisplayName "IntelliJ IDEA Community"
        Install-ChocoPackage -PackageName "jetbrainstoolbox" -DisplayName "JetBrains Toolbox"
        Install-ChocoPackage -PackageName "androidstudio" -DisplayName "Android Studio"
    }

    # Additional useful tools
    Write-Log "Installing Additional Tools..."
    Install-ChocoPackage -PackageName "git" -DisplayName "Git"
    Install-ChocoPackage -PackageName "nodejs" -DisplayName "Node.js"
    Install-ChocoPackage -PackageName "python" -DisplayName "Python"
    Install-ChocoPackage -PackageName "strawberryperl" -DisplayName "Perl"
    Install-ChocoPackage -PackageName "virtualbox" -DisplayName "Oracle VirtualBox"
    Install-ChocoPackage -PackageName "dbeaver" -DisplayName "DBeaver Community Edition"
    Install-ChocoPackage -PackageName "visualvm" -DisplayName "VisualVM"

    # Utility software
    Write-Log "Installing Utility Software..."
    Install-ChocoPackage -PackageName "chocolateygui" -DisplayName "Chocolatey GUI"
    Install-ChocoPackage -PackageName "7zip" -DisplayName "7-Zip"
    Install-ChocoPackage -PackageName "winmerge" -DisplayName "WinMerge"
    Install-ChocoPackage -PackageName "winscp" -DisplayName "WinSCP"
    Install-ChocoPackage -PackageName "notepadplusplus" -DisplayName "Notepad++"
    Install-ChocoPackage -PackageName "obs-studio" -DisplayName "OBS Studio"
    Install-ChocoPackage -PackageName "sharex" -DisplayName "ShareX"
    Install-ChocoPackage -PackageName "syncthing" -DisplayName "Syncthing"
    Install-ChocoPackage -PackageName "wireshark" -DisplayName "Wireshark"
    Install-ChocoPackage -PackageName "vnc-viewer" -DisplayName "VNC Viewer"
    Install-ChocoPackage -PackageName "mremoteng" -DisplayName "mRemoteNG"
    Install-ChocoPackage -PackageName "lunacy" -DisplayName "Lunacy"
    Install-ChocoPackage -PackageName "adobereader" -DisplayName "Adobe Acrobat Reader DC"
    Install-ChocoPackage -PackageName "bruno" -DisplayName "Bruno API Client"
    Install-ChocoPackage -PackageName "powershell-core" -DisplayName "PowerShell 7"

    # Web browsers
    Write-Log "Installing Web Browsers..."
    Install-ChocoPackage -PackageName "firefox" -DisplayName "Mozilla Firefox"

    Write-Log "Setting up environment variables..." "INFO"

    # Set JAVA_HOME
    $javaPath = Get-JavaPath
    if ($javaPath) {
        Set-EnvironmentVariable -Name "JAVA_HOME" -Value $javaPath
        Add-ToPath -NewPath "$javaPath\bin"
    } else {
        Write-Log "Could not find Java installation path. Please set JAVA_HOME manually." "WARNING"
    }

    # Set MAVEN_HOME
    $mavenPath = "${env:ProgramData}\chocolatey\lib\maven\apache-maven-*"
    $mavenDir = Get-ChildItem $mavenPath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($mavenDir) {
        Set-EnvironmentVariable -Name "MAVEN_HOME" -Value $mavenDir.FullName
        Add-ToPath -NewPath "$($mavenDir.FullName)\bin"
    }

    # Set GRADLE_HOME
    $gradlePath = "${env:ProgramData}\chocolatey\lib\gradle\tools\gradle-*"
    $gradleDir = Get-ChildItem $gradlePath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($gradleDir) {
        Set-EnvironmentVariable -Name "GRADLE_HOME" -Value $gradleDir.FullName
        Add-ToPath -NewPath "$($gradleDir.FullName)\bin"
    }

    # Set CATALINA_HOME
    $tomcatPath = "${env:ProgramData}\chocolatey\lib\tomcat\apache-tomcat-*"
    $tomcatDir = Get-ChildItem $tomcatPath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($tomcatDir) {
        Set-EnvironmentVariable -Name "CATALINA_HOME" -Value $tomcatDir.FullName
        Add-ToPath -NewPath "$($tomcatDir.FullName)\bin"
    }

    Write-Log "Installation completed!" "SUCCESS"
    Write-Log "Please restart your command prompt or IDE to use the new environment variables." "INFO"

    # Display summary
    Write-Host "`n=== INSTALLATION SUMMARY ===" -ForegroundColor Green
    Write-Host "✓ Java Development Environment Setup Complete" -ForegroundColor Green
    Write-Host "✓ Environment variables configured" -ForegroundColor Green
    Write-Host "✓ All tools should be available in new command prompt sessions" -ForegroundColor Green
    Write-Host "`nInstalled Tools:" -ForegroundColor Yellow
    Write-Host "- Microsoft OpenJDK 21" -ForegroundColor White
    Write-Host "- Apache Maven" -ForegroundColor White
    Write-Host "- Gradle" -ForegroundColor White
    Write-Host "- Apache Tomcat" -ForegroundColor White
    Write-Host "- Visual Studio Code" -ForegroundColor White
    Write-Host "- Eclipse IDE" -ForegroundColor White
    Write-Host "- IntelliJ IDEA Community" -ForegroundColor White
    Write-Host "- JetBrains Toolbox" -ForegroundColor White
    Write-Host "- Android Studio" -ForegroundColor White
    Write-Host "- Git" -ForegroundColor White
    Write-Host "- Node.js" -ForegroundColor White
    Write-Host "- Python" -ForegroundColor White
    Write-Host "- Perl" -ForegroundColor White
    Write-Host "- Oracle VirtualBox" -ForegroundColor White
    Write-Host "- DBeaver Community Edition" -ForegroundColor White
    Write-Host "- VisualVM" -ForegroundColor White
    Write-Host "- Chocolatey GUI" -ForegroundColor White
    Write-Host "- WinMerge" -ForegroundColor White
    Write-Host "- WinSCP" -ForegroundColor White
    Write-Host "- Notepad++" -ForegroundColor White
    Write-Host "- OBS Studio" -ForegroundColor White
    Write-Host "- ShareX" -ForegroundColor White
    Write-Host "- Syncthing" -ForegroundColor White
    Write-Host "- Wireshark" -ForegroundColor White
    Write-Host "- VNC Viewer" -ForegroundColor White
    Write-Host "- mRemoteNG" -ForegroundColor White
    Write-Host "- Lunacy" -ForegroundColor White
    Write-Host "- 7-Zip" -ForegroundColor White
    Write-Host "- Adobe Acrobat Reader DC" -ForegroundColor White
    Write-Host "- Bruno API Client" -ForegroundColor White
    Write-Host "- PowerShell 7" -ForegroundColor White
    Write-Host "- Mozilla Firefox" -ForegroundColor White
    Write-Host "`nLog file: $LogPath" -ForegroundColor Cyan
}

# Script execution
try {
    Start-Installation
} catch {
    Write-Log "Script execution failed: $($_.Exception.Message)" "ERROR"
    Write-Host "Setup failed. Check the log file for details: $LogPath" -ForegroundColor Red
    exit 1
}