#!/bin/bash

git clone git@github.com:{{public}}.git
rm -rf "$PWD/.git"
mv {{repo}}/.git "$PWD"
rm -rf {{repo}}
