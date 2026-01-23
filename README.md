# dotfiles

## Installation

* Install whatever version your need from https://www.fedoraproject.org/
  * Note the [Fedora Everything](https://www.fedoraproject.org/misc#everything) version
* Import private PGP keys
* Restore backup
* Run the following script:

```bash
sudo dnf install git git-crypt make
mkdir -pv "${HOME}/.home"
git clone https://github.com/obatiuk/dotfiles.git "${HOME}/.home/.dotfiles.d"
pushd "${HOME}/.home/.dotfiles.d"
git-crypt unlock <keyfile>
make init --trace 2>&1 | tee -a ~/init.log
popd
cat ~/init.log
``
