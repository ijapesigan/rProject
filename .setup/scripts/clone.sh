#!/bin/bash

git clone git@github.com:ijapesigan/rProject.git
rm -rf "$PWD.git"
mv rProject/.git "$PWD"
rm -rf rProject
