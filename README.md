# Materials Commons DSP Tiers

Tiered profiles of the Dataspace Protocol (DSP), DCAT-3 and DCAT-AP for the
Materials Commons project. This repository holds two prototype "Tier 1"
specifications for publishing open, publicly readable datasets and services:
a DSP Tier 1 profile and a DCAT-AP GET protocol Tier 1 profile.

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

The sibling prototype-server repository is `materialscommons-dsp-dcat-ap-tiers`.
