# Check the Public Export

Checks the working tree that `make auto` is about to publish (after
`clone.sh` swaps in the public `.git`): no private files (e.g.,
`.setup/ai/`, `.setup/logs/`, `AGENTS.md`), no file larger than 50 MB,
and no tokens
([`SecretScan()`](https://github.com/ijapesigan/rProject/reference/SecretScan.md))
in the files that would be published. `make auto` calls `Public()`
before `git add`, so a failed check stops the push.

## Usage

``` r
Public(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the files that would be published, invisibly.

## Author

Ivan Jacob Agaloos Pesigan
