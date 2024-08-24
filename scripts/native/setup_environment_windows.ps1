# Exit immediately if any command fails
$ErrorActionPreference = "Stop"

Write-Host "Setting up the development environment..."

function Install-Python {
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host "Python is already installed, skipping installation."
    } else {
        Write-Host "Installing Python..."
        Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.5/python-3.11.5-amd64.exe -OutFile python-installer.exe
        Start-Process -FilePath python-installer.exe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item python-installer.exe
    }
}

function Install-Rust {
    if (Get-Command rustc -ErrorAction SilentlyContinue) {
        Write-Host "Rust is already installed, skipping installation."
    } else {
        Write-Host "Installing Rust..."
        Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
        Start-Process -FilePath rustup-init.exe -ArgumentList "-y" -Wait
        Remove-Item rustup-init.exe
    }
}

function Install-Go {
    if (Get-Command go -ErrorAction SilentlyContinue) {
        Write-Host "Go is already installed, skipping installation."
    } else {
        Write-Host "Installing Go..."
        Invoke-WebRequest -Uri https://go.dev/dl/go1.21.1.windows-amd64.msi -OutFile go-installer.msi
        Start-Process msiexec.exe -ArgumentList "/i go-installer.msi /quiet" -Wait
        Remove-Item go-installer.msi
    }
}

Install-Python
Install-Rust
Install-Go

Write-Host "Development environment setup completed!"
