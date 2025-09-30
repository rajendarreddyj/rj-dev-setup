# Java Developer Workstation Setup

🚀 **Automated PowerShell script to set up a complete Java development environment on Windows**

This repository contains a comprehensive PowerShell script that automatically installs and configures all essential Java development tools, IDEs, and environment variables for a productive Java development workstation.

## ✨ Features

- ✅ **One-click installation** of all Java development tools
- ✅ **Automatic environment variable configuration** (JAVA_HOME, MAVEN_HOME, GRADLE_HOME)
- ✅ **System PATH updates** for command-line access
- ✅ **Update existing installations** with a single flag
- ✅ **Comprehensive logging** and error handling
- ✅ **Flexible installation options** (skip Java, skip IDEs, etc.)
- ✅ **Administrator privilege checking**
- ✅ **Chocolatey package manager integration**

## 📦 What Gets Installed

### Core Development Tools

- **Microsoft OpenJDK 21** - Latest LTS Java version
- **Apache Maven** - Build automation and dependency management
- **Gradle** - Build automation tool
- **Apache Tomcat** - Java web server and servlet container
- **Git** - Version control system
- **Node.js** - JavaScript runtime (useful for modern development)
- **Python** - Popular programming language for scripting and data analysis
- **Perl** - Powerful text processing language with regex capabilities

### IDEs & Editors

- **Visual Studio Code** - Lightweight, extensible code editor
- **Eclipse IDE** - Popular Java IDE with rich ecosystem
- **IntelliJ IDEA Community** - JetBrains professional Java IDE
- **JetBrains Toolbox** - Manages all JetBrains IDEs from one place
- **Android Studio** - Official Android development environment

### Git & GitHub Tools

- **Setup-github.ps1** - Automated GitHub SSH key setup and configuration
  - Generates SSH keys for secure authentication
  - Configures Git global settings
  - Sets up SSH agent and adds keys
  - Tests GitHub SSH connection
  - Provides step-by-step guidance

### Additional Tools

- **Oracle VirtualBox** - Virtualization platform for testing and development
- **DBeaver Community Edition** - Universal database tool for developers and DBAs
- **Chocolatey GUI** - Graphical user interface for Chocolatey package management
- **7-Zip** - File archiver with high compression ratio
- **WinMerge** - Visual diff and merge tool for files and directories
- **WinSCP** - Free SFTP, SCP, FTP, WebDAV client
- **Notepad++** - Lightweight text and code editor
- **OBS Studio** - Screen recording and live streaming software
- **ShareX** - Screen capture, file sharing and productivity tool
- **Syncthing** - Continuous file synchronization program
- **Wireshark** - Network protocol analyzer
- **VNC Viewer** - Remote desktop software for controlling computers
- **mRemoteNG** - Multi-protocol remote connections manager
- **Lunacy** - Professional design software for working with Sketch files
- **Adobe Acrobat Reader DC** - Industry-standard PDF viewer and annotator
- **Bruno API Client** - Open-source API testing and collaboration tool
- **PowerShell 7** - Next-generation command-line shell and scripting language
- **VisualVM** - Java profiling and monitoring tool

### Web Browsers

- **Mozilla Firefox** - Privacy-focused web browser

### Environment Configuration

- `JAVA_HOME` → Points to JDK installation
- `MAVEN_HOME` → Points to Maven installation
- `GRADLE_HOME` → Points to Gradle installation
- `CATALINA_HOME` → Points to Tomcat installation
- `PATH` → Updated to include all tool binaries

## 🚀 Quick Start

### Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges
- Internet connection

### Basic Installation

1. **Open PowerShell as Administrator**
2. **Navigate to the project directory**
3. **Run the setup scripts:**

```powershell
# For Java development environment setup
.\Setup-JavaDeveloperWorkstation.ps1

# For GitHub SSH configuration
.\Setup-github.ps1
```

That's it! The scripts will handle everything automatically.

## 🛠️ Advanced Usage

### Update Existing Tools

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -UpdateExisting
```

### Skip Java Installation (if already installed)

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -SkipJava
```

### Install Only Build Tools (skip IDEs)

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -SkipIDEs
```

### Custom Log Location

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -LogPath "C:\MyLogs\setup.log"
```

### Combine Options

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -UpdateExisting -SkipJava
```

## 📋 Post-Installation

After running the script:

1. **Restart your command prompt or IDE** to pick up new environment variables
2. **Verify installations:**

```powershell
java -version
mvn -version
gradle -version
git --version
node --version
```

## 🔧 Script Workflow

1. **Privilege Check** - Ensures script runs with administrator rights
2. **Chocolatey Setup** - Installs package manager if not present
3. **Tool Installation** - Downloads and installs all development tools
4. **Environment Setup** - Configures JAVA_HOME, MAVEN_HOME, GRADLE_HOME
5. **PATH Updates** - Makes tools available from command line
6. **Logging** - Creates detailed log file for troubleshooting

## 📁 Repository Structure

```text
rj-dev-setup/
├── Setup-JavaDeveloperWorkstation.ps1    # Main setup script
├── Setup-github.ps1                      # GitHub SSH configuration script
├── README.md                             # Detailed usage guide
```

## 🔍 Troubleshooting

- **Check the log file** at `%TEMP%\JavaDevSetup.log` for detailed information
- **Ensure administrator privileges** - Script must run as admin
- **Verify internet connection** - Downloads require internet access
- **Antivirus interference** - Some antivirus may block installations
- **Windows Updates** - Ensure system is up to date for best compatibility

## 🔄 Keeping Tools Updated

Run the script periodically with the update flag to keep all tools current:

```powershell
.\Setup-JavaDeveloperWorkstation.ps1 -UpdateExisting
```

## 💡 Tips & Best Practices

- **Run as Administrator** - Always required for system-wide installations
- **Regular Updates** - Use `-UpdateExisting` monthly to stay current
- **Selective Installation** - Use `-SkipIDEs` for server environments
- **Log Review** - Check logs if something goes wrong
- **Safe Re-runs** - Script is idempotent, safe to run multiple times

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- Report bugs or issues
- Suggest new tools or features
- Submit pull requests
- Improve documentation

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy Coding!** 🎉

For detailed usage instructions, see [USAGE.md](USAGE.md)