#!/bin/bash

echo "Creating and updating sources"

WORKDIR=$(pwd)
SOURCES="$WORKDIR/sources"
COLLECTIONS="$WORKDIR/collections"

mkdir -p "$SOURCES"
cd "$SOURCES"

echo "Cloning archive sources from git"
git clone https://github.com/gathering/go-archive-tg21 || (cd go-archive-tg21 ; git pull ; cd ..)
git clone https://github.com/gathering/go-archive-tg22 || (cd go-archive-tg22 ; git pull ; cd ..)

cd "$WORKDIR"

echo "Populating collections from archive sources"
cp -r "$SOURCES/go-archive-tg21/browsertrix-crawler/crawls/collections/tg21/" "$COLLECTIONS/"
cp -r "$SOURCES/go-archive-tg22/browsertrix-crawler/tg22/" "$COLLECTIONS/"

exec /docker-entrypoint.sh $@
