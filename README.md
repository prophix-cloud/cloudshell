# Cloudshell Init Script

This repo allows users to quickly setup an AWS Cloudshell with all the
necessary tools to run terraform.

## 1Pass Pre-req

In order to fetch our private repos you need to add a secret to your 1Pass
private vault called `ssh-key`. In the "notes" section of that secret add your
ssh private key.

## AWS Cloudshell Setup

Run the following command to setup your AWS Cloudshell. It is safe to run this
script multiple times.

```
git clone https://github.com/prophix-cloud/cloudshell.git
./cloudshell/setup-cloudshell.sh
```

Change your shell to zsh
```
zsh
```

## WSL2 Setup on Windows 11

Ensure the following Windows features are enabled. You can enable them by
pressing the Windows key and searching for "features on"; it should be the
first result that says "Turn Windows Features on or off". Enable the following
features:

- Virtual Machine Platform
- Windows Subsystem for Linux

Restart your machine after installing both.

Once rebooted, open the Windows Store app and search for and install:

- `Ubuntu 22.04.2 LTS`
- `Windows Terminal` (search for "Terminal" and it should be the first result)

Once the Windows Store says Ubuntu is installed, open the terminal app. It'll
open into a Powershell session by default. Switch to Ubuntu by clicking the
down arrow beside the "new tab (+)" button and selecting "Ubuntu 22.04.2 LTS".

Linux should begin starting and configuring itself. It'll prompt you to create
a username and password; make sure you remember both of these as you'll need
the password anytime you run `sudo`.

Once it's done setting up and you have a terminal prompt you can clone this
repo and run the `ubuntu-22.04-setup.sh` script which will install all the
basic tools we use.

```
mkdir -p ~/workspace/prophix
cd ~/workspace/prophix
git clone https://github.com/prophix-cloud/cloudshell.git
./cloudshell/ubuntu-22.04-setup.sh
```

### Change Terminal's default profile
You'll likely want to change the default terminal profile from Powershell to
Ubuntu. You can open terminal settings using the shortcut `CTRL + ,`. The
setting will be under `Startup > Default Profile`. Change it to "Ubuntu 22.04.2
LTS". You may see a second entry with a similar name and a Linux penguin icon;
ignore that one.
