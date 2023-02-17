# Cloudshell Init Script

This repo allows users to quickly setup an AWS Cloudshell with all the
necessary tools to run terraform.

## 1Pass Pre-req

In order to fetch our private repos you need to add a secret to your 1Pass
private vault called `ssh-key`. In the "notes" section of that secret add your
ssh private key.

## Init'ing the Script

Run the following to setup your AWS Cloudshell. It is safe to run multiple
times.

```
git clone https://github.com/prophix-cloud/cloudshell.git
./cloudshell/setup-cloudshell.sh
```

Change your shell to zsh
```
zsh
```
