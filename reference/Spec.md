# Create a Spec

Creates `.setup/ai/specs/YYYY-MM-DD-<topic>.md` from a template. Every
change set starts with a spec that the user approves.

## Usage

``` r
Spec(path, topic, title = topic)
```

## Arguments

- path:

  Character string. Project path.

- topic:

  Character string. Short topic in kebab case (e.g., `"log-spec"`). The
  change-set log uses the same topic.

- title:

  Character string. Title of the spec.

## Value

Returns the path of the spec invisibly.

## Author

Ivan Jacob Agaloos Pesigan
