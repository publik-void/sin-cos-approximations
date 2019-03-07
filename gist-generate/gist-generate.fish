#!/usr/bin/env fish

set --local wd (pwd)
rm -rf ../gist/*
cp sin-cos-approximations-gist.adoc ../gist/
cd ../gist
git commit -am "automated commit for newly generated gist \((date)\)"
git push
cd $wd

