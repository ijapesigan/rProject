
## Container image

- This project builds a Docker image. `Dockerfile` and `scripts/` are specific
  to this image; `scripts/setup.sh` runs the other scripts in order.
- The workflows in `.github/workflows/` are written by `make`
  (`rProject::Template()`) from rProject's `inst/template/`: `make`,
  `shellcheck`, and `non-ascii-check` for every image, plus the ones named
  in `workflows` in `.setup/scripts/project.R` (the catalog is
  `inst/template/workflows/`). The daily build's file suffix and title
  are `workflow_daily` and `workflow_title`. The daily builds are a chain:
  only the first image has `workflow_cron`; each build that succeeds
  starts the next image (`workflow_next`, a `repository_dispatch` event).
  Change workflows in rProject, not here.
- Images build for linux/amd64 and linux/arm64. Every download must pick the
  right binary for `uname -m`; skip software that has no arm64 build (and say
  so in the build log) instead of installing the x86_64 one.
- GitHub access inside the build uses `GITHUB_PAT`, passed in as a build
  secret (`/run/secrets/GITHUB_PAT`, exported by `setup.sh`). Never call the
  GitHub API without it; prefer the `releases/latest` redirect, which needs
  no token.
- Make failures stop the build: `set -e`, `set -o pipefail` with pipes,
  `curl -f`, no `try()` around installs, and a check after each install (for
  example `<tool> --version`).
- An image may build `FROM` another of the user's images. A change here
  reaches the images built on it at their next build.
- PUB: check that the "Docker Build and Push" workflow passes on both
  platforms, and read the build log for each architecture.
