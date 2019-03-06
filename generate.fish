#!/usr/bin/env fish
# Usually not a wise dependency, but this is no software library 😄

set --local execute_scripts yes
set --local doctype article
set --local wolframscript_command wolframscript

for i in $argv
  if test $i = --skip-scripts
    set execute_scripts no
end
end

if not type -q $wolframscript_command
  set wolframscript_command /Applications/Mathematica.app/Contents/MacOS/wolframscript
end

if test $execute_scripts = yes
  eval $wolframscript_command scripts/generate-approximation-sections.wls
  eval $wolframscript_command scripts/generate-error-summary-plot.wls
end

asciidoctor-pdf --doctype $doctype sin-cos-approximations.adoc
asciidoctor --doctype $doctype sin-cos-approximations.adoc

