#!/usr/bin/env fish

# Simple include-directive processor for asciidoc to work around the fact that
# GitHub currently doesn't support include-directives. This script doesn't work
# recursively, instead it simply looks for files to include in $include_dir only

set --local include_dir ../includes/
set --local out_file out.adoc
set --local intermediate_file intermediate.adoc

#rm $out_file
cp sin-cos-approximations-gist.adoc $out_file


set --local finished no

while test $finished = no
  set finished yes
  for line in (cat $out_file)
    if test (string sub --length 9 -- "$line") = include::
      set finished no
      cat $include_dir(basename (string trim --right --chars "[]" (string sub --start 10 -- "$line"))) >> $intermediate_file
    else
      echo $line >> $intermediate_file
    end
  end
  #rm $out_file
  cp $intermediate_file $out_file
  rm $intermediate_file
end
