---
name: geckograph
description: Keeps a customer's GeckoGraph graph in sync with their code. On first use it edits AGENTS.md or CLAUDE.md. Use when adding or changing a feature, route, or API, before opening a pull request, or when GeckoGraph is mentioned.
---

# GeckoGraph

This skill edits the repo's agent instructions (`AGENTS.md` or `CLAUDE.md`) the first time it runs.

`geckograph.yml` stays the contract file `geckograph scan` writes. Do not add permissions, descriptions, or GeckoGraph ids to it.

## Install the CLI

If `geckograph` is not on PATH:

macOS and Linux:

```bash
curl -fsSL https://app.geckograph.com/cli/install.sh | bash
```

Windows, from this skill's repo:

```powershell
irm https://raw.githubusercontent.com/felipeo-ag/geckograph-skill/main/install.ps1 | iex
```

The Windows script checks the download against the published `SHA256SUMS`. The release is not signed. If the Windows build is not published yet, the script stops.

Then run `geckograph login`.

## First run

1. If this repo is not linked, run `geckograph init --app <slug>`.
2. Find the agent instructions file this repo uses (`AGENTS.md` or `CLAUDE.md`). If there is none, create `AGENTS.md`.
3. Add a GeckoGraph section: every new feature or change must update GeckoGraph, and a pull request waits for a full `geckograph check --runtime`.

## On every feature change

1. Run `geckograph scan` to refresh `geckograph.yml`.
2. Run `geckograph check` and fix what it reports. When the file disagrees with the routes, run `geckograph scan` again.

## Before opening a pull request

Run a full `geckograph check --runtime` with no feature scope. It reports. It does not change the graph. If it prints `0 tested`, stop. Do not open the pull request.
