# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Get the base directory (two levels up from the scripts/native directory)
$BASE_DIR = (Get-Item -Path "$PSScriptRoot\..\..").FullName

Write-Host "Running all projects..."

# Function to run Python projects
function Run-PythonProject {
    param (
        [string]$projectPath
    )
    Write-Host "Running Python project: $projectPath"

    # Navigate to the project directory
    Set-Location -Path $projectPath

    # Create and activate a virtual environment
    if (-Not (Test-Path "venv")) {
        python -m venv venv
    }
    & $projectPath\venv\Scripts\Activate.ps1

    # Ensure dependencies are installed
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt
    }

    # Run the project
    python main.py

    # Deactivate the virtual environment and return to the base directory
    & $projectPath\venv\Scripts\Deactivate.ps1
    Set-Location -Path $BASE_DIR
}

# Function to run Rust projects
function Run-RustProject {
    param (
        [string]$projectPath
    )
    Write-Host "Running Rust project: $projectPath"

    # Navigate to the project directory
    Set-Location -Path $projectPath

    # Ensure the project is built
    cargo build --release

    # Run the project
    & .\target\release\hello_world.exe

    # Return to the base directory
    Set-Location -Path $BASE_DIR
}

# Function to run Go projects
function Run-GoProject {
    param (
        [string]$projectPath
    )
    Write-Host "Running Go project: $projectPath"

    # Navigate to the project directory
    Set-Location -Path $projectPath

    # Build and run the Go project
    go build -o hello_world.exe
    & .\hello_world.exe

    # Return to the base directory
    Set-Location -Path $BASE_DIR
}

# Run all Python projects
Get-ChildItem -Directory -Path "$BASE_DIR\python" | ForEach-Object {
    Run-PythonProject $_.FullName
}

# Run all Rust projects
Get-ChildItem -Directory -Path "$BASE_DIR\rust" | ForEach-Object {
    Run-RustProject $_.FullName
}

# Run all Go projects
Get-ChildItem -Directory -Path "$BASE_DIR\go" | ForEach-Object {
    Run-GoProject $_.FullName
}

Write-Host "All projects ran successfully!"
