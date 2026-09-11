# Materials Commons DSP Tiers

Tiered profiles of the Dataspace Protocol (DSP), DCAT-3 and DCAT-AP for the
Materials Commons project, for publishing open, publicly readable datasets and
services. Published at
<https://materialscommons-staging.github.io/mc-dsp-tiers/>.

| Document | State |
|---|---|
| [The tier model](docs/tiers.md) | what a tier is, the ladder, and what is still open |
| [DCAT-AP GET Protocol Tier 0](docs/materials-commons-dcat-ap-get-protocol-tier-0.md) | prototype draft, DCAT-AP over HTTP GET, not DSP |
| [DSP Tier 1](docs/materials-commons-dsp-tier1.md) | prototype draft, the first DSP level |
| [DSP Tier 2](docs/materials-commons-dsp-tier2.md) | outline only |
| [DSP Tier 3](docs/materials-commons-dsp-tier3.md) | outline only |

## Documentation

The documentation site is built with [zensical](https://github.com/zensical/zensical).
The source Markdown lives in [`docs/`](docs/).

## Building the docs

```bash
make docs             # serve the documentation site locally with live reload
make check-extensions # verify zensical.toml restates Zensical's default Markdown extensions
make check            # check extensions + build the site (what CI runs)
```

The docs build runs on Python via [uv](https://docs.astral.sh/uv/) — no local
Python setup is required. Optionally run `uvx pre-commit install` to enable
the extensions guard as a pre-commit hook.

CI (`.github/workflows/main.yml`) builds the docs and deploys them to GitHub
Pages via [mike](https://github.com/jimporter/mike). `.github/workflows/linkcheck.yml`
checks Markdown links with [lychee](https://github.com/lycheeverse/lychee).
