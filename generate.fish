#!/usr/bin/env fish
# Usually not a wise dependency, I should probably use something like make
# instead. But hey, this is no software library 😄

set --local execute_scripts yes
set --local generate_gist yes
set --local generate_pdf yes
set --local generate_html yes
set --local doctype article
set --local wolframscript_command wolframscript
set --local target_dir targets

for i in $argv
  switch $i
    case --skip-scripts
      set execute_scripts no
    case --skip-gist
      set generate_gist no
    case --skip-pdf
      set generate_pdf no
    case --skip-html
      set generate_html no
  end
end

if not type -q $wolframscript_command
  set wolframscript_command /Applications/Mathematica.app/Contents/MacOS/wolframscript
end

# Generate some parts of the documents using Wolfram Language
if test $execute_scripts = yes
  eval $wolframscript_command scripts/generate-approximation-sections.wls
  eval $wolframscript_command scripts/generate-error-summary-plot.wls
end

# Generate gist
if test $generate_gist = yes
  cd gist-generate
  ./gist-generate.fish
  cd ..
end

# Generate target files
if test $generate_pdf = yes
  asciidoctor-pdf --doctype $doctype\
    --out-file $target_dir/sin-cos-approximations.pdf sin-cos-approximations.adoc
end

if test $generate_html = yes
  asciidoctor --doctype $doctype --attribute data-uri --backend html5\
    --out-file $target_dir/sin-cos-approximations.html sin-cos-approximations.adoc
end
