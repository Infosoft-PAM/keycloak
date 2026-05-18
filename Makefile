# ═══════════════════════════════════════════════════════════════
# Keycloak Helm — Makefile
# Package & Push to OCI Registry
# ═══════════════════════════════════════════════════════════════

CHART_NAME    := $(shell grep '^name:' Chart.yaml | awk '{print $$2}')
CHART_VERSION := $(shell grep '^version:' Chart.yaml | awk '{print $$2}')
DOCKER_HUB_USER := amitbbd
REGISTRY_URL := registry-1.docker.io
OCI_REPO := oci://$(REGISTRY_URL)/$(DOCKER_HUB_USER)


# ─── Colors ───────────────────────────────────────────────────
BLUE   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RESET  := \033[0m

.PHONY: all lint package push clean help

help: ## Show available targets
	@echo "$(BLUE)Keycloak Helm — Available targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-12s$(RESET) %s\n", $$1, $$2}'

all: lint package push

lint: ## Lint Helm chart
	@echo "$(BLUE)==> Linting Helm chart...$(RESET)"
	@helm lint .
	@echo "$(GREEN)✓ Lint passed$(RESET)"

package: ## Package Helm chart
	@echo "$(BLUE)==> Packaging Helm chart...$(RESET)"
	@helm package .
	@echo "$(GREEN)✓ Packaged: $(CHART_NAME)-$(CHART_VERSION).tgz$(RESET)"

push: ## Push to OCI registry
	@echo "$(BLUE)==> Pushing to $(OCI_PATH)...$(RESET)"
	@helm push $(CHART_NAME)-$(CHART_VERSION).tgz $(OCI_REPO)
	@rm $(CHART_NAME)-$(CHART_VERSION).tgz
	@echo "$(GREEN)✓ Pushed: $(OCI_PATH)/$(CHART_NAME):$(CHART_VERSION)$(RESET)"

clean: ## Remove packaged tgz files
	@echo "$(BLUE)==> Cleaning...$(RESET)"
	@rm -f $(CHART_NAME)-*.tgz
	@echo "$(GREEN)✓ Cleaned$(RESET)"

login: ## Login to Docker registry (interactive)
	@echo "$(BLUE)==> Logging in to $(REGISTRY)...$(RESET)"
	@helm registry login $(REGISTRY)

logout: ## Logout from Docker registry
	@echo "$(BLUE)==> Logging out from $(REGISTRY)...$(RESET)"
	@helm registry logout $(REGISTRY)