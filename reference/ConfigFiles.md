# Setup Config Files

Clones a public `dotfiles` GitHub repository and runs `make` in it. The
clone ignores the global Git configuration, so URL rewrites to SSH host
aliases do not apply and the repository is fetched anonymously over
HTTPS. This also works inside a container without access to SSH keys.

## Usage

``` r
ConfigFiles(repo = "ijapesigan/dotfiles")
```

## Arguments

- repo:

  Character string. GitHub repository in the form `owner/name`.

## Author

Ivan Jacob Agaloos Pesigan
