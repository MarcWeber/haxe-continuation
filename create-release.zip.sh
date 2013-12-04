#!/bin/sh
p=$(sed -n 's/"name"[ ]*:[ ]*"\([^"]*\)".*/\1/p ' haxelib.json)

mkdir -p release/$p
git archive --format=zip HEAD > $p.zip
rm -fr release
mkdir -p release/$p
(
  set -x
  cd release/$p
  unzip ../../$p.zip
  rm ../../$p.zip
  cd ..
  rm $p/.gitignore
  zip -r ../$p.zip .
)
