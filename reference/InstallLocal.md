# Install Applications on Local Machine

Install Applications on Local Machine

## Usage

``` r
InstallLocal(
  what = c("tmux", "julia", "mpdemo", "lazygit", "pfetch", "quarto"),
  all = FALSE,
  force = FALSE
)
```

## Arguments

- what:

  Character string. Vector of applications to install. Valid values
  include `"tmux"`, `"julia"`, `"mpdemo"`, `"lazygit"`, `"pfetch"`, and
  `"quarto"`.

- all:

  Logical. If `all = TRUE`, ignore `what` and install all valid `what`
  values.

- force:

  Logical. If `force = TRUE`, install whether or not the application is
  available in the system.

## Author

Ivan Jacob Agaloos Pesigan
