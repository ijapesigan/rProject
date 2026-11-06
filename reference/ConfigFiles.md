# Setup Config Files

Installs the shell, tmux, Vim, and xterm files from the package
(`inst/dotfiles`) into the home directory. A file it replaces is kept in
`~/.dotfiles-backup`. It runs `inst/shell/install-dotfiles.sh`, which
needs neither R nor a container on the host; `setup-machine.sh` calls
that script directly.

## Usage

``` r
ConfigFiles(check = FALSE)
```

## Arguments

- check:

  Logical. If `TRUE`, shows the differences and changes nothing.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
ConfigFiles(check = TRUE)
} # }
```
