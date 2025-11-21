# Add `.library` to Library Paths

- creates a folder `.library` on the project path if it does not exist

- creates a `.gitignore` file inside `.library` if it does not exist

- adds `.library` to
  [`.libPaths()`](https://rdrr.io/r/base/libPaths.html)

- sets `R_LIBS_USER` to `.library`

## Usage

``` r
LibPaths(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the path of `.library`.

## Author

Ivan Jacob Agaloos Pesigan
