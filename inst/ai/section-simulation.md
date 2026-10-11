
## Simulation

- Scripts are in `.sim/`; read `.sim/README.md` first.
- Jobs run with SLURM and GNU Parallel inside the image
  (`apptainer exec`). The user submits jobs on the compute nodes or the local
  nodes; you never submit a job.
- Before handing over a job: a smoke test with one or two replications on the
  submit node, inside the image, and `sbatch --test-only` on the job script
  (it checks the script and submits nothing).
- Summaries must be compressed and under 50 MB, and must not repeat raw output.
  Run `make sizecheck` before uploading.
- When a run fails, read the SLURM output and the error files, and list the
  failed tasks and replications with the first error of each.