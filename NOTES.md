# Notes

## Fedora HP UEFI

### Using the "Customized Boot" path option (recommended)

The latest HP firmware allows defining a “Customized Boot” path in the UEFI pre-boot graphical environment.
Select the “Customized Boot” option in the UEFI pre-boot graphical environment under “Boot Options” and set
the path to your OS bootloader on the ESP:

```bash
\EFI\fedora\grubx64.efi
```

Source: https://wiki.archlinux.org/index.php/HP_EliteBook_840_G1#Using_the_%22Customized_Boot%22_path_option_(recommended)

## Avahi

- Use the following command to verify that Avahi is running:

```bash
# systemctl status avahi-daemon.service
```

- Use the following to show that the mdns port is open in the firewall to the local (multicast) network:

```bash
# sudo iptables --table filter --list | grep mdns
```

- Use the following command on another system on the network to show that no private information or additional services
  have been displayed.

```bash
$ avahi-browse --all
```

Source: https://fedoraproject.org/wiki/Features/AvahiDefaultOnDesktop#How_To_Test

## HPLIP

- Preferred way to use wireless HP printer is to specify IP address during setup:

```bash
sudo hp-setup <ip_address>
```

- If you want to use `hp-scan` utility, you *must* install proprietary plugin first:

```bash
sudo hp-plugin
```

- You can check missing or broken dependencies by running `hp-check` utility:

```bash
hp-check
```

## Bluetooth

To make your headset auto connect you need to enable PulseAudio's switch-on-connect module. Do this by adding the
following lines to `/etc/pulse/default.pa`:

```bash
# automatically switch to newly-connected devices
load-module module-switch-on-connect
```

and check in `/etc/bluetooth/main.conf`:

```bash
[Policy]
AutoEnable=true
```

Source: https://wiki.archlinux.org/index.php/Bluetooth_headset#Setting_up_auto_connection

Enable possible autoswitch to HSP from A2DP

The "auto_switch" option of module-bluetooth-policy got a new mode: mode "2" can be used to enable automatic profile
switching from A2DP to HSP when a recording stream appears without any role set.

```bash
### Automatically load driver modules for Bluetooth hardware
.ifexists module-bluetooth-policy.so
load-module module-bluetooth-policy auto_switch=2
.endif
```

Source: https://freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Bluetooth/#index1h2

## How much swap do I need?

        RAM(MB) No hibernation  With Hibernation  Maximum
         256     256              512               512
         512     512             1024              1024
        1024    1024             2048              2048

        RAM(GB) No hibernation  With Hibernation  Maximum
          1      1                2                   2
          2      1                3                   4
          3      2                5                   6
          4      2                6                   8
          5      2                7                  10
          6      2                8                  12
          8      3               11                  16
         12      3               15                  24
         16      4               20                  32
         24      5               29                  48
         32      6               38                  64
         64      8               72                 128
        128     11              139                 256

Source: https://help.ubuntu.com/community/SwapFaq#How_much_swap_do_I_need.3F
