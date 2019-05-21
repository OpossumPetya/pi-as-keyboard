# Raspberry Pi as USB Keyboard (HID)
**Example Use Case:**

You are working remotely on a PC, which has BIOS or BitLocker password enabled. The PC ocasionaly needs to be rebooted (for example for OS updates). You cannot remotely connect before OS boots.

**Possible Solution:**

A "programmable keyboard" physically connected to that remote PC, which is also connected to the internet, and can be "instructed" to send keystrokes (a password) to the PC. A Raspberry Pi device can be configured to act as such "keyboard". The **Raspberry Pi Zero W** is inexpensive ($5 at the time of writing, Apr 2019), and has WiFi module built-in.

**Required Parts:**

* Raspberry Pi Zero W
* MicroSD memory card (16 GB)
* USB-to-Micro USB cable to both power the device and communicate to the PC

**Raspberry Pi Setup:**

1. Configure the Raspberry Pi Zero W for headless use, and to automatically connect to WiFi network on boot *(see Links for the link to instructions)*
2. Configure the Raspberry Pi Zero W act as a USB Keyboard *(see Links for the link to instructions)*
3. Login to the device (PuTTY), and install Perl dependencies & modules:
    * sudo apt-get install libssl-dev
    * sudo apt-get install libnet-ssleay-perl
    * sudo apt-get install libcrypt-ssleay-perl
    * sudo cpan <module-name>
        - `Mojolicious`, `Mojolicious::Plugin::Authentication`, `IO::Socket::SSL`, `Try::Tiny`, `Cpanel::JSON::XS`, `Proc::Daemon`
        
**Software Setup:**

**(A)** Client script is running on Raspberry Pi, periodically checking an external webservice for a "flag" to "type" in the password.

This solution consists of two parts: an external web service (can be running on a shared hosting account, or a very cheap VPS account. or third party JSON storage?), and a client on Raspberry Pi running as deamon, checking the external server for a "flag" when to Ok type in the password.

Note, the "User=" directive is not specified in the `.service` file -- this will make it run under `root` user, which is required to "perform key presses".

Copy this file into `/etc/systemd/system` as root, for example:

`sudo cp myscript.service /etc/systemd/system/piclient.service`

Manually Start/stop the service:

`sudo systemctl start piclient.service`
`sudo systemctl stop piclient.service`

Set up the service to start at boot:

`sudo systemctl enable piclient.service`
`sudo systemctl disbalbe piclient.service`

**(B)** Web server running on the Raspberry Pi, and can be configured to be accessed from outsite network.

*This was the original idea, but it may not be suitable for everyone due to network security policies.*

1. Copy the `web` folder to the device (via WinSCP, for example). Start it via `hypnotoad` web server (as described in the readme file)
2. Configure the web server to be accessible from outside of local network ( good luck! :-) )


### Links
* [How To Setup Raspberry Pi Zero W Headless WiFi](https://core-electronics.com.au/tutorials/raspberry-pi-zerow-headless-wifi-setup.html)
* [Turn Your Raspberry Pi Zero into a USB Keyboard (HID)](https://randomnerdtutorials.com/raspberry-pi-zero-usb-keyboard-hid/)
