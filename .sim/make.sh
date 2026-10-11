#! /bin/bash

cd /scratch/ibp5092/Work/rProject
apptainer exec /scratch/ibp5092/Work/rProject/.sif/docs-plus.sif make all
apptainer exec /scratch/ibp5092/Work/rProject/.sif/docs-plus.sif make auto
