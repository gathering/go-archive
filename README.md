# The Gathering - Archive

A Wayback-machine (Internet Archive) style archive of our web pages
(gathering.org, and tg.no from TG25 on), served at https://archive.tg.no.
All captures of tg.no: [archive.tg.no](https://archive.tg.no/all/*/https://www.tg.no/)

Built on the [Webrecorder](https://github.com/webrecorder) tools:

- **pywb**: replays WARC archives in a Wayback-style web interface
- **browsertrix-crawler**: crawls a site into WARC files

This repo is the **tooling**. The archives themselves live in separate repos
(WARC files in Git LFS), one per year, for example
[go-archive-tgno](https://github.com/gathering/go-archive-tgno) for tg.no.

## Quick start

Requires Docker with Compose (and Git LFS for the archive repos).

```
cp env.example .env     # then edit, see below
./archive serve         # http://localhost:8080
```

`.env` settings:

| Variable | Meaning |
|---|---|
| `ARCHIVE_DIR` | Directory containing collection folders, for example your clone of `go-archive-tgno` (which contains `tgno/`). Default `./collections`. |
| `ARCHIVES` | Which archives to serve. Empty means all years (`tg21 tg22 tg23 tg24 tgno`), like production. |

For each name in `ARCHIVES`, a non-empty `ARCHIVE_DIR/<name>` is served as is.
Anything else is cloned from `github.com/gathering/go-archive-<name>`.

Try for example `http://localhost:8080/tgno/https://www.tg.no/`, or
`http://localhost:8080/all/<url>` which searches across all loaded archives.

`./archive serve tg24 tgno` overrides `ARCHIVES` for one run. Variables set in
the environment take precedence over `.env`, e.g. `ARCHIVE_DIR=/tmp/x ./archive publish ...`.

## Running a crawl

```
./archive crawl --label tg27-opening      # full crawl, config tgno.yaml
./archive crawl --label test -- --limit 10  # arguments after -- go to the crawler
./archive crawl --config tg24             # a historical config
```

Add `--watch` to follow a crawl in the browser at http://localhost:9037. It
is the crawler's built-in screencast: a grid of live screenshots, one per
worker. Useful for a quick check that pages actually load; the log output
remains the better source for details.

Each crawl runs in its own staging directory `work/<timestamp>-<label>/`
(gitignored). Nothing is written to the archive repo while crawling.

### Stopping and resuming

A crawl can be stopped at any time (Ctrl-C, or `docker stop`): the crawler saves
its state before exiting. Continue it later with:

```
./archive crawl resume            # the newest unfinished crawl
./archive crawl resume work/<dir> # a specific one
./archive crawl status            # list crawls and their progress
```

Resume uses the saved state file, and reuses the config and the extra crawler
arguments (such as `--limit`) from the original command. New WARCs are added to
the same crawl directory, so publish it once, when it is finished.

Resume works from the crawl directory in `work/`, so it needs the same machine
and the directory kept. If the crawler was killed hard (`docker kill`, power
loss) it resumes from its last periodic save and crawls the pages after that
again, which gives duplicate captures but no gaps.

`publish` refuses an unfinished crawl; `--force` publishes what exists.

When the crawl has finished:

```
./archive publish work/<timestamp>-<label>
```

This copies the new WARC files into `ARCHIVE_DIR/tgno/archive/` (never
overwriting existing ones) and writes a small record of the crawl to
`ARCHIVE_DIR/tgno/records/<crawl>/`, built from files the crawler already
produces:

- the crawler's state file (`*.yaml`): the config as run, plus the finished URLs,
- `pages.jsonl` and `extraPages.jsonl`: every crawled page with title and status,
- `record.json`: what the others don't say: label, config name, crawler image
  digest, commit of this repo (and whether it had uncommitted changes), and
  extra crawler arguments.

Then commit and push in the archive repo (`*.warc.gz` is tracked by Git LFS).
Logs, browser profile and indexes are not copied; pywb builds indexes from the
WARCs when serving.

### Milestone crawl checklist

1. `git pull` in the archive repo, `git pull` here.
2. `./archive crawl --label <milestone>`; wait for it to finish.
3. `./archive publish work/<dir>`.
4. `./archive serve tgno` and spot check key pages (front page, schedule, map, a few sub pages).
5. Commit only the new WARC files and the record in the archive repo, message like `feat: tg27 opening crawl`, and push.

## Crawl configurations

`browsertrix-crawler/configs/tgno.yaml` is the current config for tg.no.
Older configs (`tg22`, `tg23`, `tg24`, `go-example`) are kept for reference in
`browsertrix-crawler/configs/archive/`, see the README there. Adding a new
target: copy a config, set `collection:` and use `./archive crawl --config <name>`.

Options are documented in the
[browsertrix-crawler docs](https://crawler.docs.browsertrix.com/user-guide/cli-options/).

## How the archive service works

The web image is built from `wayback/Dockerfile` (pywb plus git and git-lfs)
and published to ghcr by GitHub Actions on pushes to `main`. At startup,
`wayback/startup.sh`:

1. reads `ARCHIVES` (default: all years),
2. for each archive uses a mounted local directory, or shallow-clones/updates the archive repo,
3. links the collection into pywb's `collections/` folder,
4. starts pywb (`wayback/config.yaml`; collection `all` searches across every collection).

Production runs this image as a single container serving all years. It is
updated by pulling the new image manually.

## Known issues and notes

See [docs/debugging.md](docs/debugging.md) for crawler hangs on Mac (Colima),
the `diskUtilization` workaround, leftover state between crawl runs, consent
dialogs showing up in archived pages (browser profiles), and useful queries.
