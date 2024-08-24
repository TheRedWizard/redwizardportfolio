#!/bin/bash

# Exit immediately if any command fails
set -e

# Determine the OS
OS="$(uname -s)"

echo "Setting up the development environment..."

install_python() {
    echo "Installing Python..."
    
    case "$OS" in
        Linux*)
            sudo apt-get update
            sudo apt-get install -y python3 python3-venv python3-pip
            ;;
        Darwin*)
            brew install python3
            ;;
        *)
            echo "Unsupported OS for this script: $OS"
            exit 1
            ;;
    esac
}

install_rust() {
    if command -v rustc >/dev/null 2>&1; then
        echo "Rust is already installed, skipping installation."
    else
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
}

install_go() {
    if command -v go >/dev/null 2>&1; then
        echo "Go is already installed, skipping installation."
    else
        echo "Installing Go..."
        
        case "$OS" in
            Linux*)
                wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz
                sudo tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz
                rm go1.21.1.linux-amd64.tar.gz
                ;;
            Darwin*)
                brew install go
                ;;
            *)
                echo "Unsupported OS for this script: $OS"
                exit 1
                ;;
        esac
        
        export PATH=$PATH:/usr/local/go/bin
    fi
}

install_python
install_rust
install_go

echo "Development environment setup completed!"
