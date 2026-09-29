# Dotfiles

## System Preparation

Before bootstrapping the environment, ensure the base system is configured and your decryption keys are available:

1. **Install Fedora:** Install your preferred release from the [Fedora Project](https://www.fedoraproject.org/).
	* *Note:* The [Fedora Everything](https://alt.fedoraproject.org/en/everything/) ISO is highly recommended if you want to start with a minimal, custom base.
2. **Import Keys:** Import your private PGP/GPG keys into your local keyring (this is strictly required for `git-crypt` to decrypt the repository secrets).
3. **Restore Backups:** Restore backups to your home directory

## Initial setup

```bash
# Install prerequisites
sudo dnf install -y git git-crypt make gnupg2

# Prepare directory and clone the repository
mkdir -pv "${HOME}/.home"
git clone https://github.com/obatiuk/dotfiles.git "${HOME}/.home/.dotfiles.d"

# Execute the setup script
bash "${HOME}/.home/.dotfiles.d/setup"
```
