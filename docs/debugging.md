# Debugging and notes

## Crawler container hangs (Mac)

The crawling container uses a lot of CPU, memory and disk. In some setups the
container or the VM running it crashes or hangs. Check if disk space, memory,
or CPU available to Docker can be increased, or if another runner can be used.

On an M1 Mac using Colima, this fixed it:

- Delete the existing config: `colima delete`
- Create a new one: `colima start --edit` (or `colima start --cpu N --memory N --disk N ...`) with
  - more CPU, memory and disk,
  - VM type `vz` instead of `qemu` (most likely the most important change),
  - mount type `virtiofs` instead of `sshfs` (a side effect of the VM type).

## `diskUtilization: 0` in tgno.yaml

During one crawl the crawler kept refusing to run over disk size, regardless of
actual free disk or Docker settings. Setting `diskUtilization: 0` made it work.
The docs list 0 (disabled) as the default, so the line should be a no-op;
the cause is unknown (possibly a combination of Docker, Colima and crawler
versions). Re-test without the line when upgrading the crawler or the Docker/Colima setup.

A likely cause is a full Colima VM disk: a crawler refusing to run "over disk
size" regardless of host disk space fits a VM disk at 100%. Check with
`colima ssh -- df -h /` and `docker system df`; `docker builder prune` and
`docker container prune` free space.

## Docker build uploads huge context

Without a `.dockerignore`, `docker compose build` uploads the whole repo
(including `collections/`, several GB) to the daemon and can fill the VM disk.
The repo now has a `.dockerignore` that only lets `wayback/startup.sh` through.

## Leftover state between crawl runs

Earlier, re-running the crawl container reused state from the previous run,
even when the mapped volume was reset. Likely causes (not confirmed): the
collection directory was reused (`crawls/` holds resume state, `saveState:
always`), and the crawl id defaults to container hostname + collection.
`./archive crawl` uses a fresh staging directory per crawl to avoid this, and
`./archive crawl resume` continues an unfinished one from its saved state.

## Useful queries

From earlier notes, a pywb index query for HTML pages on a domain (check the
port and path against your setup):

```
http://localhost:8081/tg24/*?url=www.gathering.org&filter==mime:text/html&matchType=domain&from=20241001
```
