# cloudshell
Scripts to init a users AWS cloudshell

```
git clone https://github.com/prophix-cloud/cloudshell.git
./cloudshell/setup-cloudshell.sh
```

Change your shell to zsh
```
zsh
```

## Manually Starting SSH Agent

```
eval $(ssh-agent -s)
ssh-add ~/.ssh/private_key
```
