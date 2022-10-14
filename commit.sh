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

files_to_process=$(find ./202? -name "*.md" | sort -r)
processed=false
# convert each unprocessed markdown note to html and pdf
for file in $files_to_process; do
  base=${file//\.md/}
  html=${base}.html
  if [ ! -f "$html" ]; then
    processed=true
    echo "Generating $html"
    pandoc -s ${file} -o ${html} --template=template.html --metadata title="Public note"
  fi
  pdf=${base}.pdf
  if [ ! -f "$pdf" ]; then
    processed=true
    echo "Generating $pdf"
    ./gen_pdf.sh ./${file}
  fi
done

# bail out if nothing was processed
if [ $processed = false ]; then
  echo "Nothing was processed"
  exit 0
fi

# get all file names and contents
contents=()
files=$(find ./202? -name "*.md" | sort -r)
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

# generate the tag index
echo "# Tag index" > tags.md
for tag in ${all_tags[@]}; do
  echo "## ${tag}" >> tags.md
  for ((i=0; i<${#contents[@]}; i+=2)); do
    content=${contents[$i+1]}
    if [[ $content =~ .*Tags.*\#${tag}.* ]]; then
      base=${contents[$i]//\.md/}
      name=${base//*\//}
      echo "* [${name}](${contents[$i]})" >> tags.md
    fi
  done
done

# generate the markdown index
echo "# Index" > README.md
last_date=''
for file in ${files}; do
  [[ $file =~ \.\/([0-9]{4}\/[0-9]{2}\/[0-9]{2})\/ ]] && date=${BASH_REMATCH[1]}
  base=${file//\.md/}
  name=${base//*\//}
  if (( ${#date} > 0 )); then
    if [[ $last_date != $date ]]; then
      if [ "$platform" = 'linux' ]; then
        echo -e "## $(date -d$date +"%A, %B %-d, %Y")" >> README.md
      elif [ "$platform" = 'bsd' ]; then
        echo -e "## $(date -j -f%Y/%m/%d $date +"%A, %B %-d, %Y")" >> README.md
      fi
      last_date=$date
    fi
  fi
  echo "* [${name}](${file})" >> README.md
done

# generate the index.html
echo "" > index.md
last_date=''
for file in ${files}; do
  [[ $file =~ \.\/([0-9]{4}\/[0-9]{2}\/[0-9]{2})\/ ]] && date=${BASH_REMATCH[1]}
  base=${file//\.md/}
  name=${base//*\//}
  if (( ${#date} > 0 )); then
    if [[ $last_date != $date ]]; then
      if [ "$platform" = 'linux' ]; then
        echo -e "\n## $(date -d$date +"%A, %B %-d, %Y")" >> index.md
      elif [ "$platform" = 'bsd' ]; then
        echo -e "\n## $(date -j -f%Y/%m/%d $date +"%A, %B %-d, %Y")" >> index.md
      fi
      last_date=$date
    fi
  fi
  echo "* [${name}](${base}.html)" >> index.md
done
pandoc -s index.md -o index.html --template=template.html --metadata title="Public notes"

# push changes to github
git add .
git commit -m "Update content"
git push origin main
