# Cloudshell Init Script

This repo allows users to quickly setup an AWS Cloudshell with all the
necessary tools to run terraform.

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
