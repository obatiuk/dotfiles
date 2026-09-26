# Agents Guide

## Core Workflow

This repository manages a Fedora system configuration using `make`. Most operations are driven by `Makefile` targets.

## Essential Commands

- **Initial Setup**: `make init` (runs primary installation/configuration)
- **Update System**: `make update-dnf`, `make update-flatpak`, `make update-snap`
- **Verify State**: Use `make check-<name>` targets (e.g., `make check-security-updates`, `make check-disk-space`)
- **Perform Backups**: `make backup-<conf>-<env>` (e.g., `make backup-home-primary`)
- **Clean System**: `make clean-<name>` (e.g., `make clean-dnf`, `make clean-docker`)

## Architecture

- **Source of Truth**: `fsroot/` and `include/` contain the intended system state.
- **Symlinking**: Files in `fsroot/home/obatiuk` are symlinked to `$HOME`.
- **Templating**: Files ending in `.template` are processed using `envsubst` before installation.
- **Modularity**: Device and DE specific configs are located in `include/device/` and `include/DE/`.
- **Custom Bins**: Tooling scripts are installed to `${HOME}/.home/bin/`.

## Constraints & Quirks

- **Privileges**: Never run `make` as root; the Makefile explicitly forbids it.
- **Secrets**: Encrypted files are managed via `git-crypt`. Ensure they are unlocked before running `make init`.
- **Dependencies**: Heavily reliant on Fedora's `dnf`, `flatpak`, and `snap`.
- **Verification**: When adding new packages or files, add a corresponding `CHECK` target in the `Makefile` to automate verification.
