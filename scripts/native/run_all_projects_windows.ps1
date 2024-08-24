# Exit immediately if any command fails
$ErrorActionPreference = "Stop"

# Determine the base directory (two levels up from the scripts/native directory)
$BASE_DIR = (Get-Item (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent)).FullName

# Create the bin directory if it doesn't exist
$BIN_DIR = Join-Path $BASE_DIR "bin"
New-Item -ItemType Directory -Force -Path $BIN_DIR | Out-Null

Write-Host "Running all projects..."

# Function to run Python projects
function Run-PythonProject {
    param($projectPath)
    Write-Host "Running Python project: $projectPath"

    # Navigate to the project directory
    Push-Location $projectPath

    # Create and activate a virtual environment
    if (-not (Test-Path "venv")) {
        python -m venv venv
    }
    .\venv\Scripts\Activate.ps1

    # Ensure dependencies are installed
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install dependencies"
            exit 1
        }
    }

    # Run the project
    python main.py

    # Deactivate the virtual environment and return to the root directory
    deactivate
    Pop-Location
}

# Function to run Rust projects
function Run-RustProject {
    param($projectPath)
    Write-Host "Running Rust project: $projectPath"

    # Navigate to the project directory
    Push-Location $projectPath

    # Determine the binary name based on the project directory name
    $projectName = Split-Path $projectPath -Leaf
    $outputBinary = Join-Path $BIN_DIR "$projectName.exe"

    # Ensure the project is built and place the binary in bin/
    $buildOutput = cargo build --release --target-dir "$BIN_DIR\rust" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Rust project build failed. Exiting."
        Write-Host $buildOutput
        exit 1
    }

    # Find the built binary and copy it to the bin directory
    $builtBinary = Get-ChildItem -Path "$BIN_DIR\rust\release" -Filter "$projectName.exe" -Recurse | Select-Object -First 1
    if ($builtBinary) {
        Copy-Item $builtBinary.FullName -Destination $outputBinary -Force
    } else {
        Write-Host "Binary not found for project: $projectName"
        exit 1
    }

    # Run the binary if it was built successfully
    if (Test-Path $outputBinary) {
        & $outputBinary
    } else {
        Write-Host "Binary not found at expected location: $outputBinary"
        exit 1
    }

    # Return to the root directory
    Pop-Location
}

# Function to run Go projects
function Run-GoProject {
    param($projectPath)
    Write-Host "Running Go project: $projectPath"

    # Navigate to the project directory
    Push-Location $projectPath

    # Determine the binary name based on the project directory name
    $projectName = Split-Path $projectPath -Leaf
    $outputBinary = Join-Path $BIN_DIR "$projectName.exe"

    # Build the Go project and capture all output
    $buildOutput = go build -o $outputBinary 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to build Go project"
        Write-Host $buildOutput
        # Remove the existing binary if it exists
        if (Test-Path $outputBinary) {
            Write-Host "Removing existing binary: $outputBinary"
            Remove-Item $outputBinary -Force
        }
        exit 1
    }

    # Run the project if it was built successfully
    if (Test-Path $outputBinary) {
        & $outputBinary
    } else {
        Write-Host "Binary not found at expected location: $outputBinary"
        exit 1
    }

    # Return to the root directory
    Pop-Location
}

# Run all Python projects
Get-ChildItem -Path (Join-Path $BASE_DIR "python") -Directory | ForEach-Object {
    Run-PythonProject $_.FullName
}

# Run all Rust projects
Get-ChildItem -Path (Join-Path $BASE_DIR "rust") -Directory | ForEach-Object {
    Run-RustProject $_.FullName
}

# Run all Go projects
Get-ChildItem -Path (Join-Path $BASE_DIR "go") -Directory | ForEach-Object {
    Run-GoProject $_.FullName
}

Write-Host "All projects ran successfully!"