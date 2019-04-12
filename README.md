# dotfiles

## Installation

* Install Fedora Workstation minimal (__source: https://github.com/benmat/fedora-install__)
* Get latest dotfiles

```bash
mkdir -pv ${HOME}/.home
git clone https://github.com/obatiuk/dotfiles.git ${HOME}/.home/.dotfiles.d
git remote set-url origin git@github.com:obatiuk/dotfiles.git
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

### Avahi

* Use the following command to verify that Avahi is running:

```bash
# systemctl status avahi-daemon.service
```

* Use the following to show that the mdns port is open in the firewall to the local (multicast) network:

```bash
# sudo iptables --table filter --list | grep mdns
```

* Use the following command on another system on the network to show that no private information or additional services have been displayed.

```bash
$ avahi-browse --all
```

__Source: https://fedoraproject.org/wiki/Features/AvahiDefaultOnDesktop#How_To_Test__

### HPLIP

* Preferred way to use wireless HP printer is to specify IP address during setup:

```bash
sudo hp-setup <ip_address>
```

* If you want to use `hp-scan` utility, you *must* install proprietary plugin first:

```bash
sudo hp-plugin
```

* You can check missing or broken dependencies by running `hp-check` utility:

```bash
hp-check
```

## TODO

* Add "updates are available" indicator to i3 status bar
