#!/bin/bash

# Setup GitHub SSH and Git Configuration
# This script helps set up Git and SSH keys on Linux/macOS or Git Bash

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git manually."
    exit 1
fi

# Get Git user configuration
read -p "Enter your Git username: " gitUserName
read -p "Enter your Git email: " gitEmail

# Configure Git global settings
git config --global user.name "$gitUserName"
git config --global user.email "$gitEmail"

# Set default branch name to main
git config --global init.defaultBranch main

# Generate SSH key if it doesn't exist
sshKeyPath="$HOME/.ssh/id_ed25519"
if [ ! -f "$sshKeyPath" ]; then
    echo "Generating new SSH key..."
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate SSH key using Ed25519 algorithm
    ssh-keygen -t ed25519 -C "$gitEmail" -f "$sshKeyPath" -N ""
fi

# Ensure SSH agent is running
echo "Starting SSH Agent..."
eval "$(ssh-agent -s)"

# Add the SSH key to the agent
echo "Adding SSH key to agent..."
ssh-add "$sshKeyPath"

# Display the public key
echo -e "\nYour public SSH key (add this to GitHub):\n"
cat "${sshKeyPath}.pub"

echo -e "\nInstructions to add SSH key to GitHub:"
echo "1. Copy the above public key"
echo "2. Go to GitHub.com -> Settings -> SSH and GPG keys"
echo "3. Click 'New SSH key'"
echo "4. Paste your key and save"

# Configure SSH config file for GitHub
sshConfig="$HOME/.ssh/config"
if [ ! -f "$sshConfig" ] || ! grep -q "Host github.com" "$sshConfig"; then
    echo "Configuring SSH for GitHub..."
    cat <<EOT >> "$sshConfig"

Host github.com
    User git
    Hostname github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519
EOT
    chmod 600 "$sshConfig"
fi

# Test SSH connection
echo -e "\nTesting SSH connection to GitHub..."
ssh -T git@github.com

echo -e "\nSetup complete! You can now use Git with SSH authentication."
