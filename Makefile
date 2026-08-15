# Pin zensical to match .github/workflows/main.yml for reproducible
# documentation builds. Override on the command line, e.g. `make docs ZENSICAL_VERSION=0.0.47`.
ZENSICAL_VERSION ?= 0.0.46
ZENSICAL := uvx zensical@$(ZENSICAL_VERSION)

.PHONY: docs
docs: ## Serve the documentation site locally with live reload
	@$(ZENSICAL) serve

.PHONY: check-extensions
check-extensions: ## Check zensical.toml still restates Zensical's default Markdown extensions
	@uv run --with zensical==$(ZENSICAL_VERSION) scripts/check_markdown_extensions.py

.PHONY: check
check: check-extensions ## Check the restated extensions and build the site (what CI runs)
	@$(ZENSICAL) build --clean

.PHONY: clean
clean: ## Remove build artifacts (./site)
	@rm -rf site

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
