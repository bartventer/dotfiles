# Install variables
DOTFILES_REPO ?= "romkatv/powerlevel10k"
DOTFILES_LANGUAGES ?= "golang"
DOTFILES_FONT ?= "MesloLGS NF"

# Act input variables (https://nektosact.com/usage/index.html#usage-guide)
ACT_EVENT_JSON=event.json
ACT_FLAGS=-e $(ACT_EVENT_JSON) --action-offline-mode
ACT_FLAGS_LINUX=$(ACT_FLAGS) -P ubuntu-latest=catthehacker/ubuntu:full-latest
ACT_FLAGS_MACOS=$(ACT_FLAGS) -P macos-latest=sickcodes/docker-osx:latest

# Act output variables
ACT_REDIRECT_OUTPUT ?= 1  # Set to 1 to redirect output to a file, set to any other value to print output to the console
ACT_OUTPUT_DIR=output
ACT_OUTPUT_FORMAT=%Y%m%d%H%M%S

# Dependencies
DOTFILES_COMMON_DEPS = init.sh scripts

# Run the install.sh script with the specified repo, languages, and font
install: $(DOTFILES_COMMON_DEPS) .config config.json fonts.json install.sh .tmux.conf .zshrc ## Run the install.sh script (optional args: DOTFILES_REPO, DOTFILES_LANGUAGES, DOTFILES_FONT)
	chmod +x install.sh || (echo "Failed to make install.sh executable" && exit 1)
	./install.sh -r $(DOTFILES_REPO) -l $(DOTFILES_LANGUAGES) -f $(DOTFILES_FONT) || (echo "Failed to run install.sh" && exit 1)

# Pull the latest changes from the repository
.PHONY: update
update: ## Pull the latest changes from the repository
	git pull origin master

# Install tmux plugins
.PHONY: install-tmux-plugins
install-tmux-plugins: ## Install tmux plugins
	@echo "Installing tmux plugins..."
	@if ! tmux has-session 2>/dev/null; then \
		tmux new-session -d; \
		tmux run-shell "$HOME/.tmux/plugins/tpm/bindings/install_plugins"; \
		tmux kill-server; \
	else \
		tmux run-shell "$HOME/.tmux/plugins/tpm/bindings/install_plugins"; \
	fi

# Run the update_fonts.sh script
update-fonts: $(DOTFILES_COMMON_DEPS) update_fonts.sh requirements.txt ## Run the update_fonts.sh script
	chmod +x update_fonts.sh || (echo "Failed to make update_fonts.sh executable" && exit 1)
	./update_fonts.sh || (echo "Failed to run update_fonts.sh" && exit 1)

# Run the specified test job with act and save the output to a file
define act-test
	@echo "Running act test: $(1)..."
	if [ "$(ACT_REDIRECT_OUTPUT)" = "1" ]; then \
		OUTPUT_FILE=$(ACT_OUTPUT_DIR)/$(1)/`date +$(ACT_OUTPUT_FORMAT)`.txt; \
		echo "Redirecting output to $$OUTPUT_FILE"; \
		mkdir -p $(ACT_OUTPUT_DIR)/$(1); \
		act -j test-$(1) $(2) | tee $$OUTPUT_FILE || (echo "Failed to run act test" && exit 1); \
		echo "Act test output saved to: $$OUTPUT_FILE"; \
	else \
		act -j test-$(1) $(2) || (echo "Failed to run act test" && exit 1); \
	fi
endef

# Run the test-linux job with act. If ACT_REDIRECT_OUTPUT is set to 1, the output will be redirected to a file.
.PHONY: act-test-linux
act-test-linux: ## Run the test-linux job with act (optional args: ACT_REDIRECT_OUTPUT=1 to redirect output to a file)
	$(call act-test,linux,$(ACT_FLAGS_LINUX))

# Run the test-macos job with act. If ACT_REDIRECT_OUTPUT is set to 1, the output will be redirected to a file.
.PHONY: act-test-macos
act-test-macos: ## Run the test-macos job with act (optional args: ACT_REDIRECT_OUTPUT=1 to redirect output to a file)
	$(call act-test,macos,$(ACT_FLAGS_MACOS))

# Clean up the act output directory
.PHONY: clean
clean: ## Clean up the act output directory
	rm -rf $(ACT_OUTPUT_DIR)/*.txt $(ACT_OUTPUT_DIR)

# List available test jobs
.PHONY: act-list-tests
act-list-tests: ## List available test jobs
	@echo "Available test jobs:"
	@act -l || (echo "Failed to list act tests" && exit 1)

# Displays a series of colored squares if true color is supported
.PHONY: true-color
true-color: ## Displays a series of colored squares if true color is supported
	@echo "True color test:"
	@echo -e "\n\n   24-bit color test"
	@/bin/bash -c 'for i in {0..255}; do \
		printf "\x1b[48;2;%d;0;0m \x1b[0m" "$$i"; \
		if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then \
			echo; \
		fi; \
	done'

# Display help message
.PHONY: help
help: ## Display this help message
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)