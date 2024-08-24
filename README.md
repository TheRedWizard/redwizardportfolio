# RedWizard Portfolio

This repository serves as a public portfolio of skills, demonstrating proficiency in Python, Rust, and Go.

## Getting Started

### Prerequisites

- For Windows: PowerShell
- For Linux/macOS: Bash

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/TheRedWizard/redwizardportfolio.git
   cd redwizardportfolio
   ```

2. Set up the development environment:
   - For Linux/macOS:
     ```
     ./scripts/native/setup_environment_linux_osx.sh
     ```
   - For Windows:
     ```
     .\scripts\native\setup_environment_windows.ps1
     ```

   These scripts will install Python, Rust, and Go if they are not already present on your system.

### Running Projects

To run all projects:
- For Linux/macOS:
  ```
  ./scripts/native/run_all_projects_linux_osx.sh
  ```
- For Windows:
  ```
  .\scripts\native\run_all_projects_windows.ps1
  ```

These scripts will build and run all Python, Rust, and Go projects in the repository.

## Project Structure

- `/python`: Python projects
- `/rust`: Rust projects
- `/go`: Go projects
- `/scripts`: Setup and run scripts
- `/bin`: Compiled binaries (created when running projects)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.