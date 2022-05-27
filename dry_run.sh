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

echo $GITHUB_SHA
git show $GITHUB_SHA

# convert each untracked markdown note to html
for file in $(git show $GITHUB_SHA --name-only --format="" 2022 | grep ".md"); do
  base=${file//\.md/}
  html=${base}.html
  echo $base
done
