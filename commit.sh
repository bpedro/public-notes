#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

# convert each untracked markdown note to html
for file in $(git ls-files --others --exclude-standard | grep ".md"); do
  base=`echo ${file} | sed 's/\.md$//'`
  html=${base}.html
  pandoc --self-contained -s ${file} -o ${html}
done

git add .
git commit -m "Update content"
git push origin main
