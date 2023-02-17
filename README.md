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
first result.

- Virtual Machine Platform
- Windows Subsystem for Linux

Restart your machine after installing both.

Open the Windows Store app and search for `Ubuntu 22.04.2 LTS` and install it.
You should also install `Windows Terminal` (search for "Terminal" and it should
be the first result).

Once the Windows Store says Ubuntu is installed, open the terminal app. It'll
open into a Powershell session by default. You'll likely want to change the
default to Ubuntu. You can open terminal settings using the shortcut `CTRL +
,`. The setting will be under `Startup > Default Profile`. Change it to "Ubuntu
22.04.2 LTS". You may see a second entry with a similar name an a Linux penguin
icon; ignore that one.
