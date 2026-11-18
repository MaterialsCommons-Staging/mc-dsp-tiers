# Materials Commons Tiers

Four levels of participation in the Materials Commons data space, built on
DCAT-AP, DCAT-3 and the Dataspace Protocol (DSP), for publishing datasets and
services. Published at
<https://materialscommons-staging.github.io/mc-dsp-tiers/>.

| Document | State |
|---|---|
| [The tier model](docs/tiers.md) | what a tier is, the ladder, and what is still open |
| [Tier 0](docs/materials-commons-dcat-ap-get-protocol-tier-0.md) | early pre-release, DCAT-AP catalogue as a file over HTTP GET, outside DSP |
| [Tier 1](docs/materials-commons-dsp-tier1.md) | early pre-release, catalogue endpoint with pagination, DSP catalogue only, no DSP conformance claim |
| [Tier 2](docs/materials-commons-dsp-tier2.md) | outline only, the required DSP feature set |
| [Tier 3](docs/materials-commons-dsp-tier3.md) | outline only, what DSP leaves optional |

A catalogue or a download may be gated behind a bearer token at any tier.
Document file names still carry the earlier `dsp` naming so that published URLs
keep resolving; the tier model records that as open.

## Documentation

The documentation site is built with [zensical](https://github.com/zensical/zensical).
The source Markdown lives in [`docs/`](docs/).

## Building the docs

```bash
make docs             # serve the documentation site locally with live reload
make check-extensions # verify zensical.toml restates Zensical's default Markdown extensions
make check            # check extensions + build the site (what CI runs)
```

The docs build runs on Python via [uv](https://docs.astral.sh/uv/), no local
Python setup is required. Optionally run `uvx pre-commit install` to enable
the extensions guard as a pre-commit hook.

CI (`.github/workflows/main.yml`) builds the docs and deploys them to GitHub
Pages via [mike](https://github.com/jimporter/mike). `.github/workflows/linkcheck.yml`
checks Markdown links with [lychee](https://github.com/lycheeverse/lychee).
