#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

# obtain platform where the script is running
platform='unknown'
unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then
   platform='linux'
elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
   platform='bsd'
fi

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
if [ "$platform" = 'linux' ]; then
  date=$(date -d$date +"%A, %B %-d, %Y")
elif [ "$platform" = 'bsd' ]; then
  date=$(date -j -f%Y/%m/%d $date +"%A, %B %-d, %Y")
fi
echo "---
title: Public note
author: Bruno Pedro
date: $date
---
$(cat ${filename})
" | \
pandoc --from=markdown+raw_tex \
  --pdf-engine=xelatex\
  --template=template.tex \
  --metadata=papersize:a5paper \
  --metadata=fontsize:10pt \
  --output=$pdf
