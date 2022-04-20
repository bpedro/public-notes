#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

# get arguments from command line
if (( $# == 0 )); then
  echo "Usage: $0 <input markdown file>"
  exit 1
fi
filename=$1
base=${filename//\.md/}
pdf=${base}.pdf

# get date
[[ $filename =~ \.\/([0-9]{4}\/[0-9]{2}\/[0-9]{2})\/ ]] && date=${BASH_REMATCH[1]}

echo "---
title: Public note
author: Bruno Pedro
date: $(date -j -f%Y/%m/%d $date +"%A, %B %-d, %Y")
---
$(cat ${filename})
" | \
pandoc --from=markdown+raw_tex \
  --pdf-engine=xelatex\
  --template=template.tex \
  --metadata=papersize:a5paper \
  --metadata=fontsize:10pt \
  --output=$pdf