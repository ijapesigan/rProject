#!/bin/bash

git clone git@github.com:ijapesigan/lib-2020-2029-article.git
rm -rf "$PWD.git"
mv lib-2020-2029-article/.git "$PWD"
rm -rf lib-2020-2029-article
