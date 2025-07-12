#!/usr/bin/env bash
# Setup script for Codex testing environment
set -e

# Install PowerShell if not already installed
if ! command -v pwsh >/dev/null 2>&1; then
    echo "Installing PowerShell..."
    apt-get update -y
    apt-get install -y wget apt-transport-https software-properties-common
    wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update -y
    apt-get install -y powershell
fi

# Run the existing PowerShell setup script
pwsh -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "$(dirname "$0")/setup.ps1"

