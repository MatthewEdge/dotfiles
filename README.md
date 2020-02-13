# Dotfiles

## Key Maps

<C-h/j/k/l> - navigate tmux / vim splits

## GPG and Github

First get the public key
```
keybase pgp export | gpg --import
```

Next get the private key
```
keybase pgp export --secret | gpg --allow-secret-key --import
```

Verify progress:
```
gpg --list-secret-keys
```

Trust the key:
```
$ gpg --edit-key KEYHERE
gpg> trust
Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 4
Do you really want to set this key to ultimate trust? (y/N) y
```

Configure Git
```
$ git config --global user.signingkey C9D8E1A1
$ git config --global commit.gpgsign true
```

Github profile:
```
gpg --armor --export KEYHERE
```

