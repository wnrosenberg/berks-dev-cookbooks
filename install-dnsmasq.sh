#!/bin/bash

# Check that user is asking for an action
if [ ! $1 ]; then
	echo >&2 "Pass the initials you want for your localhost address, ex: *.<your-initials>.dsdev."
  	exit 1;
fi

# Check for existence/accessibility of mysql and sed
echo ":: Checking dependencies.."
hash brew 2>&- || { echo >&2 "Homebrew is required but is either not installed or not in your PATH.  Aborting."; exit 1; }

# Install dnsmasq
echo ":: Installing dnsmasq with homebrew.."
brew install dnsmasq

echo ":: Configuring dnsmasq.."
# Create config file
cp /usr/local/opt/dnsmasq/dnsmasq.conf.example /usr/local/etc/dnsmasq.conf
echo "address=/$1.dsdev/33.33.33.10" >> /usr/local/etc/dnsmasq.conf
# Make sure network uses the new nameserver
sudo mkdir /etc/resolver
sudo touch /etc/resolver/dsdev
sudo echo "nameserver 127.0.0.1" > /etc/resolver/dsdev

# Make it load at start
echo ":: Registering dnsmasq as a startup daemon..
Your sudo password will be required."
sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
# We will unload it, in case it was already installed and enabled.
sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

echo ":: You're all set!

*.$1.dsdev will now point to your vagrant machine at 33.33.33.10.
Edit /usr/local/etc/dnsmasq.conf if you need to make configuration adjustments."
