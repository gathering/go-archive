#!/bin/bash

echo "Creating and updating sources"

WORKDIR=$(pwd)
SOURCES="$WORKDIR/sources"
COLLECTIONS="$WORKDIR/collections"

mkdir -p "$SOURCES"
cd "$SOURCES"

git clone https://github.com/gathering/go-archive-tg21 || (cd go-archive-tg21 ; git pull ; cd ..)

cd "$WORKDIR"

echo "Populating collections from sources"
cp -r "$SOURCES/go-archive-tg21/browsertrix-crawler/crawls/collections/tg21/" "$COLLECTIONS/"

exec /docker-entrypoint.sh $@
