# Record What Built the Project

Writes `.setup/scripts/rproject.lock` at `make auto`, before the project
is published. The lock records

- the rProject that is running (`rproject_sha`, `rproject_version`);

- the image (`image`, a registry digest, and `image_name`), read from
  the running sif's labels;

- the Posit Package Manager snapshot (`snapshot`, the image's date) for
  packages the image lacks, and the R version (`r_version`);

- the packages the project adds in `project.R` (`extra_cran`,
  `extra_github`), with their versions or commits;

- for a proprietary add-on sif (`<name>-plus.sif`, built from the public
  image with `Bootstrap: localimage`): the sif's name, source, checksum
  (`sif_sha256`), and date. CI runs the public image.

`make project` restores the lock, locally and in GitHub Actions;
`make upgrade` moves rProject forward, and the next `make auto` records
the running image.

## Usage

``` r
Lock(path)
```

## Arguments

- path:

  Character string. Project path.

## Value

Returns the path of the lock file, invisibly, or `NULL` when nothing was
written.

## Details

docker-\* projects have no lock: their recurring image builds take the
newest upstream base and the newest rProject.

Nothing is written in rProject itself (its CI builds rProject from
source), or when the running rProject has no commit (installed from a
local source).

## Author

Ivan Jacob Agaloos Pesigan
