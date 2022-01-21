#!/bin/bash
echo $1
git add .
git commit -m "Update content"
git push origin main
