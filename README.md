# dotfiles

## Installation

* Install Fedora Workstation minimal (follow instructions [here](https://github.com/benmat/fedora-install))
* Download latest `dotfiles`
* Run `make install`

```bash
mkdir -pv "${HOME}/.home"
git clone https://github.com/obatiuk/dotfiles.git "${HOME}/.home/.dotfiles.d"
cd "${HOME}/.home/.dotfiles.d" && make install
``
