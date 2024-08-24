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

    # Determine the binary name based on the project directory name
    project_name=$(basename "$project_path")
    output_binary="$BIN_DIR/$project_name"

    # Ensure the project is built and place the binary in bin/
    if ! cargo build --release --target-dir "$BIN_DIR/rust" > /dev/null 2>&1; then
        echo "Rust project build failed. Exiting."
        exit 1
    fi

    # Find the built binary and copy it to the bin directory
    built_binary=$(find "$BIN_DIR/rust/release" -type f -perm +111 -name "$project_name")
    if [ -n "$built_binary" ]; then
        cp "$built_binary" "$output_binary"
    else
        echo "Binary not found for project: $project_name"
        exit 1
    fi

    # Run the binary if it was built successfully
    if [ -f "$output_binary" ]; then
        "$output_binary"
    else
        echo "Binary not found at expected location: $output_binary"
        exit 1
    fi

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

    # Build the Go project and capture all output
    if ! go build -o "$output_binary" 2>&1; then
        echo "Failed to build Go project"
        # Remove the existing binary if it exists
        if [ -f "$output_binary" ]; then
            echo "Removing existing binary: $output_binary"
            rm "$output_binary"
        fi
        exit 1
    fi

    # Run the project if it was built successfully
    if [ -f "$output_binary" ]; then
        "$output_binary"
    else
        echo "Binary not found at expected location: $output_binary"
        exit 1
    fi

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