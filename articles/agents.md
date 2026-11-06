# Working with AI Agents

This vignette describes how coding agents work on an rProject project:
who does what, which keywords start which work, and how a machine is set
up for them.

## Who does what

| Who | Does |
|----|----|
| The user | decides; edits in Overleaf; pushes from Overleaf; runs `make all` and `make auto` |
| The main session | specs, decisions, code, prose, upload folders, and logs |
| Claude agents (Sonnet, Haiku) | work that waits, reads long logs, or repeats across projects |
| Codex, Copilot, Antigravity | run the same keywords inline when they are the agent in use |

Agents never push to Overleaf, and push to GitHub only when the user’s
message or keyword asks for it.

## Keywords

| Keyword | Does | Engine in Claude Code |
|----|----|----|
| `O2G` | verify and record the user’s Overleaf push | `verify` (Haiku) |
| `PUB` | check the public repository and its CI | `pub-check` (Sonnet) |
| `build docs`, `build docs only`, `build sif` | publish the docker images and rebuild `docs.sif` and `docs-plus.sif` | `build-docs` (Sonnet) |
| `build rProject` | build and publish rProject from a verified private push | the main session |
| `build lib` | publish the lib-\* libraries and rebuild the bibliographies | the main session |
| `CI <project>` | wait for the last push’s runs and read the failed logs | `ci-watch` (Sonnet) |
| `rollout <set> <target>` | run a make target across projects, stopping at the first failure | `rollout` (Sonnet) |
| `sim status <project>` | count a simulation’s jobs against its design | `sim-status` (Haiku) |
| `EX`, `handoff` | update `claude.txt` and `.setup/ai/handoff.md` | the main session |
| `start` | a fresh session: read the handoff and `todo.txt`, check what is pending, wait | the main session |

An upload folder also starts the `o2g-watch` agent (Haiku). A keyword is
the request to spawn its agent. Other work is spawned only when the user
asks.

`make aiglobal`, in rProject, installs the global instructions and the
agent files of `inst/ai/agents/` into `~/.claude/agents/`. An agent that
leaves rProject is removed there; one the user added stays.

## When to delegate

A subagent starts cold, so it pays only for work that waits (over about
five minutes), reads a lot (logs and diffs over about 200 lines), or
repeats (three or more projects). A short check stays in the main
session, as do edits, prose, decisions, and upload folders.

## Rules for delegated work

- Read-only, except the records `make verify RECORD=TRUE` writes.
- Evidence, not inference: quote a failure from the log and a deletion
  from `git diff --name-status`.
- Never edit a running script. Wait in the shell, not in a model.
- A report of under 300 words; a stopped run is never restarted without
  the user.

## Long jobs

Start a long job detached, write the handoff, and end the session; a new
session reads the status file. `build-docs.sh` and `build-rproject.sh`
run from a copy of themselves, so an edit to the file cannot reach a
running build. The images build as a Slurm job (account `open`, 1 core,
16 GB, 12 h), and `make all` in “build rProject” runs on a compute node;
`BUILD=host` overrides either.

## Session habits

- One release per session: after a verified `O2G` or `PUB`, write the
  handoff and start fresh.
- Upload folders are final once given. A later change goes in a new
  folder.
- A cheaper model for a whole session of routine steps: `/model sonnet`.

## Running in the image

R runs only inside Apptainer. Write the binds in every command:

``` bash
apptainer exec -B ~/work:$(readlink -f ~/work) <image> make <target>
```

`~/work` is a symlink on some machines and a folder on others. A bare
`-B ~/work` fails where it is a symlink, because the container sees the
link but not its target. On Roar, add `-B /scratch/ibp5092`.
`APPTAINER_BIND`, set in `~/.bash-variables`, covers commands typed in
an interactive shell; with both, Apptainer warns that the destination is
already in the mount list, and the command still runs. `apptainer build`
fails with the variable set, because `%post` applies the bind: use
`env -u APPTAINER_BIND apptainer build ...`, as `build-docs.sh` does.

## Setting up a machine

``` bash
bash inst/shell/setup-machine.sh [--force] [--check] [--image <sif>]
```

On the host, this installs the machine tools and the command line tools,
moves the large ones to `~/work/tools` (linked from home) where `~/work`
exists, installs the dotfiles, and runs `make local` in the image.
`--check` also runs `make all`: not on a submit node. Then sign in to
each command line tool once.

``` bash
bash inst/shell/install.sh machine   # apptainer claude codex copilot antigravity herdr gh
bash inst/shell/install.sh cli       # fzf zoxide bat fd eza delta
bash inst/shell/install.sh --list    # versions, and where each tool lives
bash inst/shell/install.sh --move    # move what is installed to ~/work/tools
```

The dotfiles are in `inst/dotfiles`. `make dotfiles` or
`bash inst/shell/install-dotfiles.sh` installs them, keeping each file
it replaces in `~/.dotfiles-backup`; `--check` shows the differences and
changes nothing. `make all` does not install them. `~/.bash-local` is
for what belongs to one machine.

## Changing a decision

Each decision here is a line in `.setup/ai/global/AGENTS.md`, an agent
file in `inst/ai/agents/`, or a script option. Change the source, then
run `make aiglobal` on each machine.
