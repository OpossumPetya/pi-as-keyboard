# Raspberry Pi as USB Keyboard (HID)
**Example use case:**

You are working remotely on a PC, which has BIOS or BitLocker password enabled. The PC ocasionaly needs to be rebooted (for example for OS updates). You cannot remotely connect before OS boots.

**Possible solution:**

A "programmable keyboard" physically connected to that remote PC, which is also connected to the internet, and can be commanded to send keystrokes (a password) to the PC. A Raspberry Pi device can be configured to act as such "keyboard". The **Raspberry Pi Zero W** is inexpensive ($5 at the time of writing, Apr 2019), and has WiFi module built-in.

**Required parts:**

* Raspberry Pi Zero W
* USB-to-Micro USB cable to both power the device and communicate to the PC
* MicroSD memory card (16 GB)

**Steps:**

1. Configure the Raspberry Pi Zero W for headless use and to automatically connect to WiFi network on boot *(see Links for the link to instructions)*
2. Configure the Raspberry Pi Zero W act as a USB Keyboard *(see Links for the link to instructions)*
3. Login to the device (PuTTY), and install Perl Dependencies: `Mojolicious`, `Mojolicious::Plugin::Authentication`
4. Copy the `web` folder to the device (via WinSCP, for example). Start it via `hypnotoad` web server (as described in the readme file)
5. Configure the web server to be accessible from outside of local network ( good luck! :-) )


### Links
* [How To Setup Raspberry Pi Zero W Headless WiFi](https://core-electronics.com.au/tutorials/raspberry-pi-zerow-headless-wifi-setup.html)
* [Turn Your Raspberry Pi Zero into a USB Keyboard (HID)](https://randomnerdtutorials.com/raspberry-pi-zero-usb-keyboard-hid/)
