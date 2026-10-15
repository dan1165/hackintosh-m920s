# ThinkCentre M920s — Hackintosh
# Convenience targets. Run `make` (no args) to see everything.

SHELL := /bin/bash
.PHONY: help check verify validate stage release docs clean

help:            ## list targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n",$$1,$$2}'

check:           ## pre-install checks (hardware + EFI)
	./PreInstall/preflight.sh

check-all:       ## pre-install checks incl. MSR (root) + upstream hashes (network)
	./PreInstall/preflight.sh --all

verify:          ## supply-chain: bundled binaries vs official upstream (SHA-256)
	./PreInstall/verify-upstream.sh

validate:        ## validate config.plist with ocvalidate
	./PostInstall/ocvalidate.linux EFI/OC/config.plist

stage:           ## stage an installer USB folder (EFI + recovery)
	./PreInstall/stage-installer.sh

docs:            ## check markdown relative links
	./scripts/check-links.sh

lint:            ## shellcheck the bundled scripts (skips vendored)
	@files=$$(ls PreInstall/*.sh PostInstall/*.sh | grep -v '/ResourceConverter.sh$$'); shellcheck --severity=warning $$files && echo "shellcheck clean"

release:         ## package ThinkCentre-M920s-<ver>.zip from EFI + docs
	@v=$$(git describe --tags --always 2>/dev/null || echo dev); \
	zip -qr "ThinkCentre-M920s-$$v.zip" EFI docs PreInstall PostInstall README.md CHANGELOG.md LICENSE; \
	echo "wrote ThinkCentre-M920s-$$v.zip"

clean:           ## remove staging + release artefacts
	rm -rf installer-usb ThinkCentre-M920s-*.zip
