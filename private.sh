#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

file=$1

git reset "$file"
git add --intent-to-add "$file"
git update-index --assume-unchanged "$file"
