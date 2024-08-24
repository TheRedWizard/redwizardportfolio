#!/bin/bash

# Exit immediately if any command fails
set -e

# Determine the base directory (two levels up from the scripts/native directory)
BASE_DIR=$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")

# Create the bin directory if it doesn't exist
BIN_DIR="$BASE_DIR/bin"
mkdir -p "$BIN_DIR"

echo "Running all projects..."

# Function to run Python projects
run_python_project() {
    project_path=$1
    echo "Running Python project: $project_path"
    
    # Navigate to the project directory
    cd "$project_path"
    
    # Create and activate a virtual environment
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    
    # Ensure dependencies are installed
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt 2>/dev/null || { echo "Failed to install dependencies"; exit 1; }
    fi
    
    # Run the project
    python main.py
    
    # Deactivate the virtual environment and return to the root directory
    deactivate
    cd - > /dev/null
}

# Function to run Rust projects
run_rust_project() {
    project_path=$1
    echo "Running Rust project: $project_path"
    
    # Navigate to the project directory
    cd "$project_path"
    
    # Ensure the project is built and place the binary in bin/
    cargo build --release --target-dir "$BIN_DIR/rust" 2>&1 | grep -v "Finished" || true
    
    # Run the project
    ./target/release/hello_world
    
    # Return to the root directory
    cd - > /dev/null
}

# Function to run Go projects
run_go_project() {
    project_path=$1
    echo "Running Go project: $project_path"
    
    # Navigate to the project directory
    cd "$project_path"

    # Determine the binary name based on the project directory name
    project_name=$(basename "$project_path")
    output_binary="$BIN_DIR/$project_name"
    
    # Build and place the Go binary in bin/
    go build -o "$output_binary"
    "$output_binary"
    
    # Return to the root directory
    cd - > /dev/null
}

# Run all Python projects
for project in "$BASE_DIR"/python/*/; do
    run_python_project "$project"
done

# Run all Rust projects
for project in "$BASE_DIR"/rust/*/; do
    run_rust_project "$project"
done

# Run all Go projects
for project in "$BASE_DIR"/go/*/; do
    run_go_project "$project"
done

echo "All projects ran successfully!"
