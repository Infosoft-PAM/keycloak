# ═══════════════════════════════════════════════════════════════════════════════
# Makefile — PAM Web UI build, push, and deploy automation
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Variables (override from CLI: make build IMAGE_REGISTRY=myregistry.io) ──
DOCKER_USER := amitbbd
DOCKER_PASSWORD := [PASSWORD]
IMAGE_REGISTRY ?= docker.io/$(DOCKER_USER)
NAMESPACE      ?= pam
HELM_RELEASE   ?= pam-keycloak
HELM_CHART_DIR := .
DIST_DIR       := ./dist
CHART_NAME     := $(shell grep '^name:' $(HELM_CHART_DIR)/Chart.yaml | awk '{print $$2}')
CHART_VERSION  := $(shell grep '^version:' $(HELM_CHART_DIR)/Chart.yaml | awk '{print $$2}')

# Full image reference
.DEFAULT_GOAL := help

# ─── Help ─────────────────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help message
	@echo ""
	@echo "  PAM Keycloak — helm chart build"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Variables (current values):"
	@echo "    REGISTRY  = $(REGISTRY)"
	@echo "    NAMESPACE = $(NAMESPACE)"
	@echo ""

# ─── Lint ─────────────────────────────────────────────────────────────────────
.PHONY: helm-lint
helm-lint: ## Lint the Helm chart
	@echo "→ Linting Helm chart $(HELM_CHART_DIR)"
	helm lint $(HELM_CHART_DIR) --strict
	@echo "✓ Helm lint passed"

# ─── Package ──────────────────────────────────────────────────────────────────
.PHONY: helm-package
helm-package: helm-lint ## Package the Helm chart into dist/
	@mkdir -p $(DIST_DIR)
	@echo "→ Packaging helm chart into $(DIST_DIR)/"
	helm package $(HELM_CHART_DIR) -d $(DIST_DIR)
	@echo "✓ Helm package complete"

# ----- helm push -----------------------
.PHONY: helm-push
helm-push: helm-package ## Push the Helm chart to the repository
	@echo "→ Pushing Helm chart $(DIST_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz to repository"
	helm push $(DIST_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz oci://registry-1.docker.io/$(DOCKER_USER)
	@rm $(DIST_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz
	@echo "✓ Helm push complete"


# ─── Diff (requires helm-diff plugin) ────────────────────────────────────────
.PHONY: helm-diff
helm-diff: ## Show diff of pending Helm changes
	helm diff upgrade $(HELM_RELEASE) $(HELM_CHART_DIR) \
		--namespace $(NAMESPACE) \
		--set image.repository=$(IMAGE_REGISTRY)/$(IMAGE_NAME) \
		--set image.tag=$(IMAGE_TAG)

# ─── All ──────────────────────────────────────────────────────────────────────
.PHONY: all
all: helm-package helm-push
	@echo "✓ All targets complete."
