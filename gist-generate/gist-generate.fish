#!/usr/bin/env fish

set --local initial_dir (pwd)
set --local gist_dir ../targets/gist

./asciidoc-include-preprocessor.fish
rm -rf $gist_dir/*
cp out.adoc $gist_dir/sin-cos-approximations-gist.adoc
rm out.adoc
cd $gist_dir

set --local commit_message (date)
set commit_message (string join ""\
  "automated commit for newly generated gist (" (date) ")")
git commit -am $commit_message
git push

cd $initial_dir

