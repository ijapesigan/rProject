#! /usr/bin/bash

git clone git@github.com:jeksterslab/rProject.git
rm -rf "$PWD.git"
mv rProject/.git $PWD
rm -rf rProject
