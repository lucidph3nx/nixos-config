# Agents Project Guidance: nixos-config

This document provides guidance for AI agents on how to interact with this NixOS configuration repository.

## Project Overview

- **Primary Goal:** This repository manages the personal NixOS configurations for multiple machines, all intended for a single user ("lucidph3nx").
- **Design Philosophy:**
    - Configurations are managed with Nix Flakes.
    - Home Manager and NixOS options are often configured together within the same module for simplicity.
    - The system aims for impermanence, with state managed via `impermanence`.
    - Secrets are managed with `sops-nix` and an age key.
    - The `unstable` channel is preferred for packages. Overlays are used to pin packages to `stable` or other versions only when necessary.

## Common Commands

- **Building/Testing Changes:** To validate configuration changes without applying them, use the `nh` helper command. This is the preferred method for checking for errors.
    - `nh os build`
- **Linting/Formatting:** Code is formatted with `alejandra`.
    - `alejandra .`
- **Flake Validation:** To check the flake for correctness across all defined systems, use:
    - `nix flake check --all-systems`
- **Updating Inputs:** To update all flake inputs, use:
    - `nix flake update`
- **Applying Configuration:** The user will typically handle applying the configuration manually with `nh os switch`. Do not attempt to apply changes unless explicitly asked.
- **Editing Secrets:** Secrets are encrypted with `sops`. To edit a secret, use the `sops` command.
    - `sops <path/to/secret.sops.yaml>`

## Code Structure & Conventions

### Adding New Packages/Applications

1.  **Machine-Specific (Limited Use):** If a package is needed on only one machine, add it directly to that machine's `configuration.nix` (e.g., `machines/navi/configuration.nix`).
2.  **Global (Simple Package):** If a package should be available on all machines and requires no special configuration, add it to the main list in `modules/programs/default.nix`.
3.  **Global (With Configuration):** For applications that require configuration, files, or persisted state:
    - Create a new module file (e.g., `modules/programs/new-app.nix`).
    - In this file, define the necessary NixOS and/or Home Manager options.
    - Import the new module into `modules/programs/default.nix`.
    - Enable the module where needed (e.g., in a specific machine's configuration).

### Adding New Services

- Follow the same pattern as for applications with configuration, but place the new module within the `modules/services/` directory.

### Naming Conventions

- **Files:** Use lowercase for file and directory names.
- **Nix Options:** Use either camelCase or kebab-case, maintaining consistency with the surrounding code.

### Secrets Management

- Secrets are co-located with the modules that use them (e.g., `modules/qutebrowser/secrets/`).
- The public age key for encryption is located in the root `.sops.yaml` file. Do not ask for this key.
- When adding a new secret, create a new `.sops.yaml` file in the appropriate module directory.

## Workflows

### Committing and Deploying Changes

When changes are ready to be committed and deployed, follow this specific sequence:

1.  **Commit:** Stage the changes and write a descriptive commit message.
2.  **Build:** Verify the configuration builds successfully with `nh os build`.
3.  **Check:** Run the flake checker with `nix flake check --all-systems`.
4.  **Switch:** Apply the new configuration with `nh os switch`.
5.  **Push:** If all previous steps succeed, push the changes with `git push`.

### Temporary Testing Changes

The user may request changes for testing purposes that should not be committed. In these cases, modify the necessary files and run `nh os switch` to apply the changes, but do not stage or commit them.

### General Workflow Principles

- **Atomic Changes:** Group all related modifications (e.g., creating a new module, importing it, and removing the old package entry) into a single logical change and commit them together.
- **Git Tracking for Nix:** New files must be added to Git (and ideally committed) *before* Nix commands (like `nh os switch` or `nix flake check`) can recognize them.
- **Efficiency of `nh os switch`/`nh os build`:** These commands can be time-consuming. Use them judiciously, only after a complete set of related changes has been applied, and then await user feedback before further iterations. Do not use them as part of an iterative debugging process unless explicitly instructed.
- **Trusting User Feedback:** If the user confirms a fix, trust that feedback and move on, rather than attempting further "fixes" based on assumptions.
