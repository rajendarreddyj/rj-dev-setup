# Setup GitHub SSH and Git Bash Configuration
# This script helps set up Git, SSH keys, and configures Git Bash

# Function to check if a command exists
function Test-CommandExists {
    param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# Check if Git is installed
if (-not (Test-CommandExists 'git')) {
    Write-Host "Git is not installed. Please install Git from https://git-scm.com/downloads"
    exit 1
}

# Get Git user configuration
$gitUserName = Read-Host "Enter your Git username"
$gitEmail = Read-Host "Enter your Git email"

# Configure Git global settings
git config --global user.name $gitUserName
git config --global user.email $gitEmail

# Set default branch name to main
git config --global init.defaultBranch main

# Configure Git to use OpenSSH
git config --global core.sshCommand C:/Windows/System32/OpenSSH/ssh.exe

# Generate SSH key if it doesn't exist
$sshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
if (-not (Test-Path $sshKeyPath)) {
    Write-Host "Generating new SSH key..."
    
    # Create .ssh directory if it doesn't exist
    if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh"
    }
    
    # Generate SSH key using Ed25519 algorithm
    ssh-keygen -t ed25519 -C $gitEmail -f $sshKeyPath -N '""'
}

# Check if OpenSSH is installed and install if needed
$opensshFeature = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
if ($opensshFeature.State -ne "Installed") {
    Write-Host "Installing OpenSSH Client..."
    Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0'
}

# Ensure SSH agent service exists and is configured
$sshAgentService = Get-Service -Name 'ssh-agent' -ErrorAction SilentlyContinue
if (-not $sshAgentService) {
    Write-Host "SSH Agent service not found. Setting up SSH Agent..."
    Set-Service -Name 'ssh-agent' -StartupType Automatic -ErrorAction SilentlyContinue
}

# Try to start the SSH agent service
try {
    # Check if service exists again after potential setup
    $sshAgentService = Get-Service -Name 'ssh-agent' -ErrorAction Stop
    
    if ($sshAgentService.Status -ne 'Running') {
        Write-Host "Starting SSH Agent service..."
        Start-Service 'ssh-agent' -ErrorAction Stop
    } else {
        Write-Host "SSH Agent service is already running."
    }
    
    # Add the SSH key to the agent
    Write-Host "Adding SSH key to agent..."
    ssh-add $sshKeyPath
} catch {
    Write-Host "Error with SSH agent: $_"
    Write-Host "Please ensure OpenSSH Authentication Agent service is installed and you have admin rights."
    Write-Host "You can try setting up the SSH agent manually by running:"
    Write-Host "1. Open Services (services.msc)"
    Write-Host "2. Find 'OpenSSH Authentication Agent'"
    Write-Host "3. Set Startup type to Automatic"
    Write-Host "4. Start the service"
}

# Display the public key
Write-Host "`nYour public SSH key (add this to GitHub):`n"
Get-Content "$sshKeyPath.pub"

Write-Host "`nInstructions to add SSH key to GitHub:"
Write-Host "1. Copy the above public key"
Write-Host "2. Go to GitHub.com → Settings → SSH and GPG keys"
Write-Host "3. Click 'New SSH key'"
Write-Host "4. Paste your key and save"

# Configure SSH config file for GitHub
$sshConfig = "$env:USERPROFILE\.ssh\config"
if (-not (Test-Path $sshConfig)) {
    @"
Host github.com
    User git
    Hostname github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519
"@ | Out-File -FilePath $sshConfig -Encoding utf8
}

# Test SSH connection
Write-Host "`nTesting SSH connection to GitHub..."
ssh -T git@github.com

Write-Host "`nSetup complete! You can now use Git with SSH authentication."
