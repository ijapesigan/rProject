#! /bin/bash

cd ~/Downloads/rProject || exit
apptainer exec -B ~/work:"$(readlink -f ~/work)" -B ~/Downloads ~/work/sif/docs.sif make all
apptainer exec -B ~/work:"$(readlink -f ~/work)" -B ~/Downloads ~/work/sif/docs.sif make auto

