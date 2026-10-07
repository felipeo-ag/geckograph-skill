# GeckoGraph skill

A skill other people install in their own repo. On first use it edits `AGENTS.md` or `CLAUDE.md`. After that, a feature change runs `geckograph scan` and `geckograph check`. Opening a pull request waits for a full `geckograph check --runtime`.

Install the skill:

```bash
npx skills add felipeo-ag/geckograph-skill
```

Claude Code loads this repo as a plugin from `.claude-plugin/plugin.json`.

The CLI is a separate binary. macOS and Linux use `https://app.geckograph.com/cli/install.sh`. Windows uses `install.ps1` in this repo, which checks the download against the published `SHA256SUMS`. The release is not signed. The Windows build is not on that release yet, so the script stops until it is.
