# dotfiles

## Installation

* Install Fedora Workstation minimal (__source: https://github.com/benmat/fedora-install__)
* Get latest dotfiles

```bash
mkdir -pv ${HOME}/.home
git clone https://github.com/obatiuk/dotfiles.git ${HOME}/.home/.dotfiles.d
```

## Notes

### Fedora HP UEFI

**Using the "Customized Boot" path option (recommended)**

The latest HP firmware allows defining a “Customized Boot” path in the UEFI pre-boot graphical environment.
Select the “Customized Boot” option in the UEFI pre-boot graphical environment under “Boot Options” and set
the path to your OS boot loader on the ESP:

```
\EFI\fedora\grubx64.efi
```

__Source: https://wiki.archlinux.org/index.php/HP_EliteBook_840_G1#Using_the_%22Customized_Boot%22_path_option_(recommended)__

## TODO

* Add "updates are available" indicator to i3 status bar
