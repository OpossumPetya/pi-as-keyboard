# Raspberry Pi as USB Keyboard (HID)

### Example Use Case

You are working remotely on a PC, which has BIOS or BitLocker password enabled. The PC ocasionaly needs to be rebooted (for example for OS updates). You cannot connect to it remotely until the password is entered (before OS boots).

### Possible Solution

A "programmable keyboard" physically connected to that remote PC, which is also connected to the internet, and can be "instructed" to send keystrokes (a password) to the PC. A Raspberry Pi device can be configured to act as such "keyboard". The **Raspberry Pi Zero W** is inexpensive ($5 at the time of writing, Apr 2019), and has WiFi module built-in.

## Raspberry Pi Setup

**Required Parts:**

* Raspberry Pi Zero W
* MicroSD memory card (16 GB)
* USB-to-Micro USB cable to both power the device and communicate to the PC

**Setup:**

1. Configure the Raspberry Pi Zero W for headless use, and to automatically connect to WiFi network on boot *(see Links for the link to instructions)*
2. Configure the Raspberry Pi Zero W act as a USB Keyboard *(see Links for the link to instructions)*
3. Login to the device (PuTTY), and install Perl dependencies & modules:
    * sudo apt-get install libssl-dev
    * sudo apt-get install libnet-ssleay-perl
    * sudo apt-get install libcrypt-ssleay-perl
    * sudo cpan [module-name]
        - `Mojolicious`, `Mojolicious::Plugin::Authentication`, `IO::Socket::SSL`, `Try::Tiny`, `Cpanel::JSON::XS`, `Proc::Daemon`
        
## Software Setup

### Option (A): 
**Client script is running on Raspberry Pi**, checking an external webservice for a "flag" as a signal to enter the password.

This solution consists of two parts: a client on Raspberry Pi running as daemon, periodically checking the external resource for a flag, and an external web service, which would provide such flag (self-hosted app running on a shared hosting account, or a inexpensive VPS account. A third party JSON storage/bin/mock service can alrernatively be used too).

__*Client script:*__

- Upload `piclient` folder to your home directory
- Edit the `config.json` (more on URL below)
- You can delete `clientd.pl` and `controller.sh` files -- they were created to daemonize the client script, but we'll use `systemd` for that.

*For security reasons the client script will only poll for a flag using POST requests. It will also pass Authentication header.*

Using `systemd` to run the script as daemon:

- Copy `piclient.service` file into `/etc/systemd/system` as root:

`sudo cp piclient.service /etc/systemd/system/piclient.service`

Note, the "`User=`" directive is not specified in the `.service` file -- this will make the script run under `root` user account, which is required to "perform key presses".

Now you can manually start/stop the service as follows:

```
sudo systemctl start piclient.service
sudo systemctl stop piclient.service
```

- To set up the service to start at boot / disable it:

```
sudo systemctl enable piclient.service
sudo systemctl disbalbe piclient.service
```

__*A Flag:*__

A "flag" url is any url that can return `{ "flag": 1 }` to a POST request (`1` = go ahead, enter enter the pass; `0` = do nothing).

__*Flag Management via included app:*__

The included `piui` app is configured to be run on CPanel-based shared hosting account, but it should also run without modifications using Mojlicious' built-in webserver.

To run on shared hosting:

- Copy the `piui` folder as a subfolder in your account ( https://yourdoamin.com/path/piui )
- Change permissions for `piui/app.pl` to 755
- Edit the `piui/app.json` file: make sure the `auth_key` parameter is the same in this app and the client script above
- In your CPanel admin got to Perl Modules section
    - "Using Your Perl Module" will list the shabang that must be used in the script: if it's different than in the `piui/app.pl` - replace it.
    - Install `Mojolicious` and `Mojolicious::Plugin::Authentication` modules.
    
This app now should be accessible directly via https://yourdoamin.com/path/piui url. Once you confirm login screen is displayed, you're able to login and toggle the flag, add `https://yourdoamin.com/path/piui/processflag` URL to the client script config (`url` key).

__*Flag Management via third party JSON bin/mock service:*__

There are many free services exist that help you mock a JSON responses. To use one with this setup you'll need one that: accepts POST requests & can ignore the headers, allows editing previously created "mock" without changing the URL, keeps the "mock" private, does not require additional headers for authentication, has UI interface for easy manual editing of the "mock", is free (this does not require many requests per day - under 300/day if you check for the flag every 5 minutes).

Out of 7-8 services I tried only beeceptor.com met these criteria... Except for the number of requests -- free account only allows 50; which means you can only check once every 30 minutes, which may still be acceptable, depending on your case.



### Option (B): 
**Web server running on the Raspberry Pi**, and can be configured to be accessed from outsite network.

*This was the original idea, but it may not be suitable for everyone due to your network provider's security policies.*

1. Copy the `web` folder to the device (via WinSCP, for example). Start it via `hypnotoad` web server (as described in the readme file)
2. Configure the web server to be accessible from outside of local network ( good luck! :-) )


## Links
* [How To Setup Raspberry Pi Zero W Headless WiFi](https://core-electronics.com.au/tutorials/raspberry-pi-zerow-headless-wifi-setup.html)
* [Turn Your Raspberry Pi Zero into a USB Keyboard (HID)](https://randomnerdtutorials.com/raspberry-pi-zero-usb-keyboard-hid/)
