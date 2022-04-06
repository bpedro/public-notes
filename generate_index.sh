#!/bin/bash

files=$(find ./20?? -name "*.md")
for file in ${files}; do
  filename=${file//\.md/.html}
  base=${file//\.md/}
  html=${base}.html
  echo $base $html
  #note_cut=`head -c 280 $file`
  #snippet=${note_cut//---*/}
  #echo $snippet
done