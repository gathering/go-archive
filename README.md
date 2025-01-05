# The Gathering - Archive


A Wayback-machine (Internet Archive) style archive service of gathering.org.
Relies on one or more WARC collections under the hood that are fetched from
public sources (git repos provided by us).

Heavily based on services provided by [Webrecorder project](https://github.com/webrecorder)

## Run locally

1. `docker-compose up`
2. Visit `localhost:8080` in browser (example, since default search is a bit tricky, `http://localhost:8080/all/https://www.gathering.org/tg21/`)

To capture a new collection run this, replacing `<your url>` with the page you want to start crawling

`docker-compose run --rm crawler crawl --url <your url> --generateWACZ --collection my-new-collection`

This is essentially the same steps as [Browsertrix crawler - getting started](https://github.com/webrecorder/browsertrix-crawler#getting-started), but with our default volumes

## Basic structure

### Services

- web service - Uses `Webrecorder/pywb` to expose a web interface that can be used to navigate archive
- crawler service - Uses `Webrecorder/browsertrix-crawler` to (on demand) crawl one or more urls and generate a WARC collection from it
- proxy service - Not in place, would act as entrypoint for web service (nginx, apache, or similar)

### Logic

On startup web service runs `wayback/startup.sh` script. This populates the
`sources` folder with WARC collections from various sources (such as our
archive github repositories) and copies the relevant files into `collections`
for use by web service / `pywb`.

The web service expose pages to search and navigate through archive, as well as
a "landing page" with shortcuts to per year gathering.org versions. The landing
page is useful since we tend to change url each year and we don't want to force
users to know this and apply the right search terms.

[TG.no live version](https://archive.tg.no/all/*/https://www.tg.no/)

## Adding new archive sources

A clean version of this archive does not have any contents of it's own. These
are instead fetched and/or updated on startup via `wayback/startup.sh`. This is
done instead of expecting a pre-populated volume on first run, to make it work
in a variety of different setups without requiring a bunch of manual setup
steps.

Add additional repositories or other sources there.

## Adding new "permanent" crawl target

1. Add one or more custom configs to the `browsertrix-crawler/configs` folder
2. Add cron-job that runs this container with docker-compose and a command like `crawl --config /app/configs/my-crawl-config.yaml`

Full example command (without scheduling): `docker-compose run --rm crawler crawl --config /app/configs/my-crawl-config.yaml`

## Known issues and debugging

### Crawling container hangs

The crawling container will consume "a lot" of system resources. In some
circumstances or configurations leading to container or VM running it to crash
or hang.

Exact mitigation steps will vary based on setup, but generally check if disk
space, memory, or CPU available to container (or the container runner itself)
can be increased. Or if another runner can be used.

Ex. on M1 Mac using Colima the following fixes were used
- Delete existing colima config `colima delete`
- Create a new colima config `colima start --config`
    - Higher CPU
    - More memory
    - More disk space
    - Change VM type from `qemu` to `vz` \* Most likely the most important change
    - Change mount type from `sshd` to `virtiofs` (side effect of VM type)
