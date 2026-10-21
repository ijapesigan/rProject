# Install Global AI Instructions

Copies the global AI instructions and Claude settings from
`.setup/ai/global` in the project to the configuration folders of Claude
Code, Codex, and GitHub Copilot in the home directory. Files are written
only when their content changed. Existing files that differ are backed
up with the suffix `.bak`.

## Usage

``` r
AIGlobal(path, home = Sys.getenv("HOME"))
```

## Arguments

- path:

  Character string. Project path.

- home:

  Character string. Home directory.

## Value

Returns the paths of the files that were written.

## Details

|                        |                                      |
|------------------------|--------------------------------------|
| Source                 | Installed to                         |
| `AGENTS.md`            | `~/.claude/CLAUDE.md`                |
| `AGENTS.md`            | `~/.codex/AGENTS.md`                 |
| `AGENTS.md`            | `~/.copilot/copilot-instructions.md` |
| `claude-settings.json` | `~/.claude/settings.json`            |

`claude-settings.json` is merged into an existing `settings.json`: its
keys win, permission rules are added to the existing ones, and other
keys are kept.

## Author

Ivan Jacob Agaloos Pesigan
