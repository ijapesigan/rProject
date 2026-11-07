#! /bin/bash

cd /scratch/ibp5092/Work/rProject || exit
apptainer exec -B ~/work:"$(readlink -f ~/work)" -B /scratch/ibp5092 /scratch/ibp5092/Work/rProject/.sif/docs-plus.sif make all
apptainer exec -B ~/work:"$(readlink -f ~/work)" -B /scratch/ibp5092 /scratch/ibp5092/Work/rProject/.sif/docs-plus.sif make auto
