#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

# convert each untracked markdown note to html
for file in $(git ls-files --others --exclude-standard | grep ".md"); do
  base=`echo ${file} | sed 's/\.md$//'`
  html=${base}.html
  pandoc --self-contained -s ${file} -o ${html}
done

# get all file names and contents
contents=()
files=$(find ./2022 -name "*.md")
for file in ${files}; do
  OLDIFS=$IFS
  IFS=""
  contents+=($file $(<${file}))
  IFS=$OLDIFS
done

# get a unique list of tags
all_tags=()
for ((i=0; i<${#contents[@]}; i+=2)); do
  content=${contents[$i+1]}
  all_tags+=($(echo "$content" | grep 'Tags' | grep -o '#[^#]*' | sed 's/#//'))
done
all_tags=($(echo ${all_tags[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))

# generate the index
echo "# Tag index" > tags.md
for tag in ${all_tags[@]}; do
  echo "## ${tag}" >> tags.md
  for ((i=0; i<${#contents[@]}; i+=2)); do
    content=${contents[$i+1]}
    if [[ $content =~ .*Tags.*\#${tag}.* ]]; then
      base=`echo ${contents[$i]} | sed 's/\.md$//' | sed 's/^.*\///'`
      echo "* [${base}](${contents[$i]})" >> tags.md
    fi
  done
done

# push changes to github
git add .
git commit -m "Update content"
git push origin main
