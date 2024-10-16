#!/bin/bash

echo "Creating and updating sources"

WORKDIR=$(pwd)
SOURCES="$WORKDIR/sources"
COLLECTIONS="$WORKDIR/collections"

mkdir -p "$SOURCES"
cd "$SOURCES"

git lfs install

echo "Cloning archive sources from git"
git clone https://github.com/gathering/go-archive-tg21 || (cd go-archive-tg21 ; git pull ; git lfs pull ; cd ..)
git clone https://github.com/gathering/go-archive-tg22 || (cd go-archive-tg22 ; git pull ; git lfs pull ; cd ..)
git clone https://github.com/gathering/go-archive-tg23 || (cd go-archive-tg23 ; git pull ; git lfs pull ; cd ..)
git clone https://github.com/gathering/go-archive-tg24 || (cd go-archive-tg24 ; git pull ; git lfs pull ; cd ..)
git clone https://github.com/gathering/go-archive-tgno || (cd go-archive-tgno ; git pull ; git lfs pull ; cd ..)

cd "$WORKDIR"

# Copying files isn't very disk usage friendly, PR's for better strategies are welcome ;)
echo "Populating collections from archive sources"
cp -r "$SOURCES/go-archive-tg21/browsertrix-crawler/crawls/collections/tg21/" "$COLLECTIONS/"
cp -r "$SOURCES/go-archive-tg22/browsertrix-crawler/tg22/" "$COLLECTIONS/"
cp -r "$SOURCES/go-archive-tg23/tg23/" "$COLLECTIONS/"
cp -r "$SOURCES/go-archive-tg24/tg24/" "$COLLECTIONS/"
cp -r "$SOURCES/go-archive-tgno/tgno/" "$COLLECTIONS/"

exec /docker-entrypoint.sh $@
