#!/bin/bash
# Compile each .setup/latex/*.Rtex as Overleaf does: from the root of a folder
# with only the private repository's files, and with no rProject installed.
# Run it in the image, on a copy (it writes there), after `verify.sh`:
#
#   cp -r .verify <copy>; rm -rf <copy>/.git
#   apptainer exec <binds> <image> bash <rProject>/inst/shell/overleaf-check.sh <copy>
#
# It prints the pages of each PDF, or what stopped it; it exits 1 if any failed.
set -uo pipefail

cd "${1:?usage: overleaf-check.sh <copy of the private repository>}" || exit 2
lib="$(mktemp -d)"
trap 'rm -rf "${lib}"' EXIT
for pkg in /usr/local/lib/R/site-library/* /usr/lib/R/site-library/*; do
  [[ -e "${pkg}" && "$(basename "${pkg}")" != "rProject" ]] && ln -sfn "${pkg}" "${lib}/$(basename "${pkg}")"
done
export R_LIBS_SITE="${lib}" R_LIBS_USER=/nonexistent

status=0
for file in .setup/latex/*.Rtex; do
  name="$(basename "${file}" .Rtex)"
  printf '%s: ' "${name}"
  if ! Rscript --vanilla -e "knitr::knit('${file}', output = '${name}.tex', quiet = TRUE)" > "${name}.knit" 2>&1; then
    printf 'KNIT FAILED\n'
    grep -E 'Error|cannot open|could not find' "${name}.knit" | head -n 3
    status=1
    continue
  fi
  latexmk -pdf -interaction=nonstopmode -f "${name}.tex" > "${name}.mk" 2>&1
  if [[ -f "${name}.pdf" ]] && ! grep -q '^! ' "${name}.log"; then
    pdfinfo "${name}.pdf" | grep Pages
  else
    printf 'LATEX FAILED\n'
    grep -E '^! ' "${name}.log" | sort -u | head -n 3
    status=1
  fi
done
exit "${status}"
