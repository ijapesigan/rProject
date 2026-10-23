# Setup RStudio Package Manager Repository Based on the Current Operating System

The repository is the Posit Package Manager snapshot of the image's
date, so that a package the image lacks matches the image's other
packages: the environment variable `RPROJECT_SNAPSHOT` (set in GitHub
Actions from the lock), the date of the running sif, the lock's
`snapshot`, or `latest`.

## Usage

``` r
PkgRepo(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the repository url.

## Author

Ivan Jacob Agaloos Pesigan
