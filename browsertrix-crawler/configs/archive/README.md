# Historical crawl configs

Kept for reference. They were used for earlier years and are not maintained.
Run one with `./archive crawl --config tg24` (the wrapper also looks here).

| File | Used for | Notes |
|---|---|---|
| `tg22.yaml` | gathering.org/tg22 | |
| `tg23.yaml` | gathering.org/tg23 | Sitemap was broken, so search result pages are listed as seeds. Used a consent profile. |
| `tg24.yaml` | gathering.org | Used a consent profile. |
| `go-example.yaml` | Example crawling several yearly sites into one collection | |

`newContext` and `screencastPort` are for the live view and may not be valid in
current crawler versions, check before reusing.

The consent profiles these configs refer to (`profile:`) are not in the repo.
To run them, create a profile as described in docs/debugging.md.
