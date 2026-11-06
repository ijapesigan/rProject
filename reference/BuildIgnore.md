# Build `.Rbuildignore`

Build `.Rbuildignore`

## Usage

``` r
BuildIgnore(path, project, add = NULL)
```

## Arguments

- path:

  Character string. Project path.

- project:

  Character string. Project name.

- add:

  Character vector. Items to add to `.Rbuildignore`.

## Value

Called for its side effects; the value is not meaningful.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (FALSE) { # \dontrun{
BuildIgnore(path = getwd(), project = "myProject")
} # }
```
