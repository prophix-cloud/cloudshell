# Cloudshell Init Script

This repo allows users to quickly setup an AWS Cloudshell with all the
necessary tools to run terraform. Cloudshell configuration is regional, so if
you setup your Cloudshell in ca-central-1, that same setup won't exist in any
other region that you open Cloudshell in.

## 1Pass Pre-req

In order to fetch our private repos you need to add a secret to your 1Pass
private vault called `ssh-key`. In the "notes" section of that secret add your
ssh private key.

- [Generating an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux)
- [Adding your SSH key to your GitHub account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account)

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

## Getting Temporary AWS API Keys

If your Cloudshell is setup you can run `get-temp-aws-creds` from the shell
which will run `get-temp-aws-creds.sh` script that's in this repo.
