# {{project}}

See `AGENTS.md` and `.setup/ai/project.md` for this project ({{types}}).

- R: BigCamelCase functions; snake_case objects; `pkg::fn()` with named
  arguments; no explicit `return()`; one function per file.
- Never edit generated files (`NAMESPACE`, `man/`, `README.md`, `.setup/latex/pdf/`).
- Run code only inside the image: `apptainer exec {{sif}} make <target>`.