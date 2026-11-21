#!/bin/bash
#
# Populates pywb collections, then hands over to the pywb entrypoint.
#
# Environment:
#   ARCHIVES            Space separated collection names to serve, or "none".
#                       Default: all known years.
#   ARCHIVE_GIT_BASE    Where per-year repos live (<base>/go-archive-<name>).
#   ARCHIVE_UPDATE      Set to 0 to skip updating already cloned repos.
#
# For each name a non-empty /local-archives/<name> (bind mounted by docker
# compose) is used as is. Otherwise the collection is fetched from git.
# Collections are symlinked into place, not copied.

set -u

WORKDIR=$(pwd)
SOURCES=${SOURCES_DIR:-$WORKDIR/sources}
COLLECTIONS=${COLLECTIONS_DIR:-$WORKDIR/collections}
LOCAL=${LOCAL_ARCHIVES_DIR:-/local-archives}
GIT_BASE=${ARCHIVE_GIT_BASE:-https://github.com/gathering}
ARCHIVE_UPDATE=${ARCHIVE_UPDATE:-1}
ARCHIVES=${ARCHIVES:-tg21 tg22 tg23 tg24 tgno}
[ "$ARCHIVES" = "none" ] && ARCHIVES=""

# Path of the collection inside each source repo (layout differs between years)
collection_subpath() {
  case "$1" in
    tg21) echo "browsertrix-crawler/crawls/collections/tg21" ;;
    tg22) echo "browsertrix-crawler/tg22" ;;
    *) echo "$1" ;;
  esac
}

fetch_source() {
  local dir="$SOURCES/go-archive-$1"
  if [ -d "$dir/.git" ]; then
    [ "$ARCHIVE_UPDATE" = "1" ] || return 0
    # pywb autoindex may have modified tracked index files, so reset instead of pull
    (cd "$dir" && git fetch --depth 1 origin HEAD && git reset --hard FETCH_HEAD && git lfs pull)
  else
    git clone --depth 1 "$GIT_BASE/go-archive-$1" "$dir" && (cd "$dir" && git lfs pull)
  fi
}

install_collection() {
  local dest="$COLLECTIONS/$1"
  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    ln -sfn "$2" "$dest"
  else
    echo "WARN: $dest is a real directory (older copy), refreshing it with cp"
    cp -a "$2/." "$dest/"
  fi
}

mkdir -p "$SOURCES" "$COLLECTIONS"
git lfs install

# Collections persist in a volume: drop links to archives that are no longer
# requested (only symlinks, never real directories)
for link in "$COLLECTIONS"/*; do
  [ -L "$link" ] || continue
  case " $ARCHIVES " in
    *" $(basename "$link") "*) ;;
    *) echo "Removing link to unrequested archive $(basename "$link")"; rm "$link" ;;
  esac
done

echo "Populating collections: ${ARCHIVES:-<none>}"
for name in $ARCHIVES; do
  if [ -d "$LOCAL/$name" ] && [ -n "$(ls -A "$LOCAL/$name" 2>/dev/null)" ]; then
    echo "[$name] using local $LOCAL/$name"
    src="$LOCAL/$name"
  else
    echo "[$name] fetching from git"
    fetch_source "$name" || echo "WARN: [$name] fetch failed, using existing checkout if any"
    src="$SOURCES/go-archive-$name/$(collection_subpath "$name")"
  fi

  if [ -d "$src" ]; then
    install_collection "$name" "$src" || echo "WARN: [$name] could not install collection"
  else
    echo "WARN: [$name] $src not found, skipping"
  fi
done

exec "${PYWB_ENTRYPOINT:-/docker-entrypoint.sh}" "$@"
