#!/usr/bin/env bash
# Setup script for Codex testing environment

# Install PowerShell if not already installed
if ! command -v pwsh >/dev/null 2>&1; then
    echo "Installing PowerShell..."
    apt-get update -y || echo "apt-get update failed"
    apt-get install -y wget apt-transport-https software-properties-common || echo "dependency install failed"
    wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb || echo "wget failed"
    dpkg -i packages-microsoft-prod.deb >/dev/null 2>&1 || echo "dpkg install failed"
    apt-get update -y || echo "apt-get update failed"
    apt-get install -y powershell || echo "PowerShell install failed"
fi

# Run the existing PowerShell setup script if pwsh is available
if command -v pwsh >/dev/null 2>&1; then
    pwsh -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "$(dirname "$0")/setup.ps1" || echo 'PowerShell setup script failed'
else
    echo "pwsh not found; skipping PowerShell setup script."
fi

