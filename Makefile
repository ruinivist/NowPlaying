# Makefile for KDE 6 Plasma Widget Development

# Variables
PACKAGE_DIR := package
METADATA_FILE := $(PACKAGE_DIR)/metadata.json
WIDGET_ID := $(shell grep -oP '"Id": "\K[^"]+' $(METADATA_FILE))
BUILD_DIR := build
PLASMOID_FILE := $(WIDGET_ID).plasmoid

# Default target
.PHONY: help
help:
	@echo "KDE Plasma 6 Widget Developer Tools"
	@echo ""
	@echo "Usage:"
	@echo "  make dev           Run widget in plasmoidviewer from local package (MODE=panel|desktop|hidpi)"
	@echo "  make watch         Start Development Mode with Hot Reload"
	@echo "  make install       Install/upgrade widget in local Plasma package store"
	@echo "  make uninstall     Remove widget from local system"
	@echo "  make package       Build .plasmoid file for distribution"
	@echo "  make clean         Remove build artifacts"
	@echo "  make format        Format QML, JSON, YAML, and Markdown files"
	@echo "  make lint          Run non-mutating lint and formatting checks"
	@echo "  make hooks-install Configure Git to use versioned hooks from .githooks/"

# Git Hooks
# Configure Git to use versioned hooks stored in this repository.
.PHONY: hooks-install
hooks-install:
	git config core.hooksPath .githooks
	@echo "Configured core.hooksPath=.githooks"

# Testing Targets
# Run plasmoidviewer from the local package directory.
# Optional MODE values: panel, desktop, hidpi (omit MODE for default).
.PHONY: dev
dev:
	@mode="$(MODE)"; \
	case "$$mode" in \
		""|default) \
			plasmoidviewer -a $(PACKAGE_DIR) ;; \
		panel) \
			plasmoidviewer -a $(PACKAGE_DIR) -l topedge -f horizontal ;; \
		desktop) \
			plasmoidviewer -a $(PACKAGE_DIR) -l floating -f planar ;; \
		hidpi) \
			QT_SCALE_FACTOR=2 plasmoidviewer -a $(PACKAGE_DIR) ;; \
		*) \
			echo "Invalid MODE='$$mode'. Allowed: panel, desktop, hidpi (or omit MODE)."; \
			exit 1 ;; \
	esac

# Development Tools
# Start file watcher for iterative development and reload workflow.
.PHONY: watch
watch:
	./scripts/watch.sh

# Format all QML files in the package directory in-place.
.PHONY: format-qml
format-qml:
	@command -v qmlformat >/dev/null 2>&1 || { echo "Missing required tool: qmlformat"; exit 1; }
	find $(PACKAGE_DIR) -name "*.qml" -type f -exec qmlformat -i {} +

# Format JSON/YAML/Markdown files with prettier.
.PHONY: format-prettier
format-prettier:
	@command -v prettier >/dev/null 2>&1 || { echo "Missing required tool: prettier"; exit 1; }
	find . -type f \
		\( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name ".prettierrc" \) \
		-not -path "./.git/*" \
		-not -path "./build/*" \
		-print0 | xargs -0 -r prettier --write

# Run all formatting passes.
.PHONY: format
format: format-qml format-prettier

# Linting
# Check QML formatting without changing files.
.PHONY: lint-qml-format
lint-qml-format:
	@command -v qmlformat >/dev/null 2>&1 || { echo "Missing required tool: qmlformat"; exit 1; }
	@status=0; \
	find $(PACKAGE_DIR) -name "*.qml" -type f -print0 | \
	xargs -0 -r -I{} sh -c 'tmp_file="$$(mktemp)"; qmlformat "$$1" > "$$tmp_file"; if ! cmp -s "$$1" "$$tmp_file"; then echo "QML format mismatch: $$1"; rm -f "$$tmp_file"; exit 1; fi; rm -f "$$tmp_file"' _ {} || status=1; \
	if [ "$$status" -ne 0 ]; then \
		echo "Run 'make format-qml' to fix QML formatting."; \
		exit 1; \
	fi

# Run semantic QML lint checks.
.PHONY: lint-qml
lint-qml:
	@command -v qmllint >/dev/null 2>&1 || { echo "Missing required tool: qmllint"; exit 1; }
	find $(PACKAGE_DIR) -name "*.qml" -type f -print0 | xargs -0 -r qmllint

# Check JSON/YAML/Markdown formatting without changing files.
.PHONY: lint-prettier
lint-prettier:
	@command -v prettier >/dev/null 2>&1 || { echo "Missing required tool: prettier"; exit 1; }
	find . -type f \
		\( -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name ".prettierrc" \) \
		-not -path "./.git/*" \
		-not -path "./build/*" \
		-print0 | xargs -0 -r prettier --check

# Run all lint and formatting checks.
.PHONY: lint
lint: lint-qml-format lint-qml lint-prettier

# Installation
# Install/upgrade widget in local Plasma package store.
.PHONY: install
install:
	@if kpackagetool6 --type Plasma/Applet --show $(WIDGET_ID) >/dev/null 2>&1; then \
		echo "Upgrading existing package: $(WIDGET_ID)"; \
		kpackagetool6 --type Plasma/Applet --upgrade $(PACKAGE_DIR); \
	else \
		echo "Installing new package: $(WIDGET_ID)"; \
		kpackagetool6 --type Plasma/Applet --install $(PACKAGE_DIR); \
	fi

# Upgrade an already installed widget package with local changes.
.PHONY: upgrade
upgrade:
	kpackagetool6 --type Plasma/Applet --upgrade $(PACKAGE_DIR)

# Remove installed widget package from local system.
.PHONY: uninstall
uninstall:
	@if kpackagetool6 --type Plasma/Applet --show $(WIDGET_ID) >/dev/null 2>&1; then \
		echo "Removing package registration: $(WIDGET_ID)"; \
		kpackagetool6 --type Plasma/Applet --remove $(WIDGET_ID); \
	else \
		echo "Package not registered: $(WIDGET_ID)"; \
	fi

# Packaging
# Create distributable .plasmoid archive from current package contents.
.PHONY: package
package:
	mkdir -p $(BUILD_DIR)
	rm -f $(BUILD_DIR)/$(PLASMOID_FILE)

	# Zip package contents
	cd $(PACKAGE_DIR) && zip -r ../$(BUILD_DIR)/$(PLASMOID_FILE) .

	@echo ""
	@echo "Package built at: $(BUILD_DIR)/$(PLASMOID_FILE)"

# Delete all generated build artifacts for a clean workspace.
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
