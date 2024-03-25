.SHELLFLAGS = -ec
.ONESHELL:

# Devcontainer variables
IMAGE_NAME?=archlinux## The name of the base image. Options: archlinux, debian, fedora, ubuntu. Defaults to "archlinux"
DEVCONTAINER_WORKSPACE_FOLDER=.## The workspace folder to mount in the devcontainer. Defaults to "." (current directory)
TEST_PROJECT_PATH?="test_project"## The path to the test project. Defaults to "test_project"
DEVCONTAINER_CONFIG_PATH?="$(TEST_PROJECT_PATH)/$(IMAGE_NAME)/.devcontainer/devcontainer.json"## The path to the devcontainer build context. Defaults to "test_project/$(IMAGE_NAME)/.devcontainer"
DEVCONTAINER_TEST_SCRIPT?="test.sh"## The test script to run in the devcontainer. Defaults to "test.sh"

# Install variables
INSTALL_ZSH_THEME_REPO?="romkatv/powerlevel10k"## The Zsh theme repository to install. Defaults to "romkatv/powerlevel10k"
INSTALL_LANGUAGES?="golang"## The languages to install. Defaults to "golang"
INSTALL_FONT?="MesloLGS NF"## The font to install. Defaults to "MesloLGS NF"

# Dotfiles path variables
DOTFILES_CONFIG_DIR=config
DOTFILES_UPDATE_FONTS_SCRIPT=update_fonts.sh
DOTFILES_INSTALL_SCRIPT=install.sh
ifeq ($(CI),true)
	DOTFILES_REPO_FLAGS="--dotfiles-repository $(GITHUB_REPOSITORY) --dotfiles-target-path ~/dotfiles --dotfiles-install-command $(DOTFILES_INSTALL_SCRIPT)"
else
	DOTFILES_REPO_FLAGS=
endif

# Devcontainer command
DEVCONTAINER=devcontainer
DEVCONTAINER_BUILD=$(DEVCONTAINER) build
DEVCONTAINER_UP=$(DEVCONTAINER) up
DEVCONTAINER_EXEC=$(DEVCONTAINER) exec

# Devcontainer flags
DEVCONTAINER_BUILD_FLAGS=--workspace-folder $(DEVCONTAINER_WORKSPACE_FOLDER) --config $(DEVCONTAINER_CONFIG_PATH) --image-name $(IMAGE_NAME)
DEVCONTAINER_EXEC_FLAGS=--workspace-folder $(DEVCONTAINER_WORKSPACE_FOLDER) --config $(DEVCONTAINER_CONFIG_PATH) --id-label test-container=$(IMAGE_NAME)
DEVCONTAINER_UP_FLAGS=$(DEVCONTAINER_EXEC_FLAGS) $(DOTFILES_REPO_FLAGS)

# Tmux
TMUX=tmux
TMUX_HASSESSION=$(TMUX) has-session
TMUX_NEWSESSION=$(TMUX) new-session
TMUX_KILLSERVER=$(TMUX) kill-server
TMUX_RUNSHELL=$(TMUX) run-shell
TMUX_PLUGIN_MANAGER_DIR=$(HOME)/.tmux/plugins/tpm
TMUX_PLUGIN_MANAGER_BIN=$(TMUX_PLUGIN_MANAGER_DIR)/bin/install_plugins

# Tmux flags
TMUX_NEWSESSION_FLAGS=-d
TMUX_RUNSHELL_FLAGS="$(TMUX_PLUGIN_MANAGER_BIN)"

# Python
VENV=venv
ifeq ($(CI),true)
	VENV_ACTIVATE= # In CI, by default we don't activate the virtual environment
else
	VENV_ACTIVATE=. $(VENV)/bin/activate;
endif
COVERAGE_REPORT_FORMAT ?= html  # Default to HTML coverage report
UNITTEST_DISCOVER=unittest discover

# Python commands
PYTHON_TEST=$(VENV_ACTIVATE) python3 -m $(UNITTEST_DISCOVER)
PYTHON_COVERAGE=$(VENV_ACTIVATE) coverage run --source=. -m $(UNITTEST_DISCOVER)
PYTHON_COVERAGE_REPORT=$(VENV_ACTIVATE) coverage $(COVERAGE_REPORT_FORMAT)

# Python flags
PYTHON_TEST_FLAGS=-s tests/
PYTHON_COVERAGE_FLAGS=$(PYTHON_TEST_FLAGS)

# ACT variables
ACT=act
ACT_JOB=$(ACT) -j
ACT_JOB_ID_PREFIX=test-
# Act input variables (https://nektosact.com/usage/index.html#usage-guide)
ACT_EVENT_JSON=$(DOTFILES_CONFIG_DIR)/event.json
ACT_FLAGS=-e $(ACT_EVENT_JSON) --action-offline-mode
ACT_FLAGS_LINUX=$(ACT_FLAGS) -P ubuntu-latest=catthehacker/ubuntu:full-latest
ACT_FLAGS_MACOS=$(ACT_FLAGS) -P macos-latest=sickcodes/docker-osx:latest
# Act output variables
ACT_REDIRECT_OUTPUT ?= 1  # Set to 1 to redirect output to a file, set to any other value to print output to the console
ACT_OUTPUT_DIR=output
ACT_OUTPUT_FORMAT=%Y%m%d%H%M%S

# Dependencies
DOTFILES_COMMON_DEPS = init.sh $(wildcard scripts/*)

# Error handling function
define error_exit
	@echo "Error: $(1)"
	@exit 1
endef

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m    %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)

install: $(DOTFILES_COMMON_DEPS) $(DOTFILES_CONFIG_DIR) .config $(DOTFILES_INSTALL_SCRIPT) .tmux.conf .zshrc ## Run the install.sh script (optional args: INSTALL_ZSH_THEME_REPO, INSTALL_LANGUAGES, INSTALL_FONT)
	chmod +x $(DOTFILES_INSTALL_SCRIPT) || $(call error_exit,"Failed to make $(DOTFILES_INSTALL_SCRIPT) executable")
	./$(DOTFILES_INSTALL_SCRIPT) -r $(INSTALL_ZSH_THEME_REPO) -l $(INSTALL_LANGUAGES) -f $(INSTALL_FONT) || $(call error_exit,"Failed to run $(DOTFILES_INSTALL_SCRIPT)")

.PHONY: update
update: ## Pull the latest changes from the repository
	git pull origin master

.PHONY: install-tmux-plugins
install-tmux-plugins: ## Install tmux plugins
	echo "Installing tmux plugins..."
	if ! command -v $(TMUX) >/dev/null 2>&1; then
		$(call error_exit,"$(TMUX) is not installed.")
	fi
	if ! $(TMUX_HASSESSION) 2>/dev/null; then
		$(TMUX_NEWSESSION) $(TMUX_NEWSESSION_FLAGS)
		$(TMUX_RUNSHELL) $(TMUX_RUNSHELL_FLAGS) || $(call error_exit,"Failed to run tmux plugin manager.")
		$(TMUX_KILLSERVER)
	else
		$(TMUX_RUNSHELL) $(TMUX_RUNSHELL_FLAGS) || $(call error_exit,"Failed to run tmux plugin manager.")
	fi

update-fonts: $(DOTFILES_COMMON_DEPS) $(DOTFILES_UPDATE_FONTS_SCRIPT) requirements.txt ## Run the update_fonts.sh script
	chmod -f +x $(DOTFILES_UPDATE_FONTS_SCRIPT)
	./$(DOTFILES_UPDATE_FONTS_SCRIPT)

# Run the specified test job with act and save the output to a file
define act-test
	@echo "Running act test: $(1)..."
	if [ "$(ACT_REDIRECT_OUTPUT)" = "1" ]; then
		OUTPUT_FILE=$(ACT_OUTPUT_DIR)/$(1)/`date +$(ACT_OUTPUT_FORMAT)`.txt
		echo "Redirecting output to $$OUTPUT_FILE"
		mkdir -p $(ACT_OUTPUT_DIR)/$(1)
		$(ACT_JOB) $(ACT_JOB_ID_PREFIX)$(1) $(2) | tee $$OUTPUT_FILE
		echo "Act test output saved to: $$OUTPUT_FILE"
	else
		$(ACT_JOB) $(ACT_JOB_ID_PREFIX)$(1) $(2)
	fi
endef

.PHONY: test
test: ## Run the tests
	$(PYTHON_TEST) $(PYTHON_TEST_FLAGS)

.PHONY: coverage
coverage: ## Run the tests with coverage
	$(PYTHON_COVERAGE) $(PYTHON_COVERAGE_FLAGS)

.PHONY: coverage-report
coverage-report: ## Generate the coverage report (optional args: COVERAGE_REPORT_FORMAT=xml to generate XML report, defaults to html)
	$(PYTHON_COVERAGE_REPORT)

.PHONY: act-test-linux
act-test-linux: ## Run the test-linux job with act (optional args: ACT_REDIRECT_OUTPUT=1 to redirect output to a file)
	$(call act-test,linux,$(ACT_FLAGS_LINUX))

.PHONY: act-test-macos
act-test-macos: ## Run the test-macos job with act (optional args: ACT_REDIRECT_OUTPUT=1 to redirect output to a file)
	$(call act-test,macos,$(ACT_FLAGS_MACOS))

.PHONY: act-list-tests
act-list-tests: ## List available test jobs
	@echo "Available test jobs:"
	@act -l || $(call error_exit,"Failed to list act tests")

.PHONY: true-color
true-color: ## Displays a series of colored squares if true color is supported
	echo "True color test:"
	echo -e "\n\n   24-bit color test"
	/bin/bash -c 'for i in {0..255}; do
		printf "\x1b[48;2;%d;0;0m \x1b[0m" "$$i"
		if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
			echo
		fi
	done'

.PHONY: devcontainer-up
devcontainer-up: ## Create and run the devcontainer image
	@echo "Creating and running the devcontainer image ($(IMAGE_NAME))..."
	$(DEVCONTAINER_UP) $(DEVCONTAINER_EXEC_FLAGS)
	@if [ -f "$(DOTFILES_INSTALL_SCRIPT)" ]; then \
		echo "⚠️ Running the install.sh script in the devcontainer as dotfiles repository is not set..."; \
		$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
			set -e; \
			if [ -f "$(DOTFILES_INSTALL_SCRIPT)" ]; then \
				chmod +x $(DOTFILES_INSTALL_SCRIPT); \
				./$(DOTFILES_INSTALL_SCRIPT); \
			fi'; \
	fi

.PHONY: devcontainer-test
devcontainer-test: devcontainer-up## Test the devcontainer image
	@echo "Testing the devcontainer image ($(IMAGE_NAME))..."
	$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
		set -e; \
		if [ -f "$(TEST_PROJECT_PATH)/$(DEVCONTAINER_TEST_SCRIPT)" ]; then \
			cd $(TEST_PROJECT_PATH); \
			chmod +x $(DEVCONTAINER_TEST_SCRIPT); \
			./$(DEVCONTAINER_TEST_SCRIPT); \
		else \
			ls -a; \
		fi'

.PHONY: clean
clean: ## Clean up the act output directory, any Python cache files, and the devcontainer image
	@echo "Cleaning up the act output directory ($(ACT_OUTPUT_DIR))..."
	@echo "ACT_OUTPUT_DIR = $(ACT_OUTPUT_DIR)"
	rm -rf $(ACT_OUTPUT_DIR)/*.txt $(ACT_OUTPUT_DIR) __pycache__ */__pycache__ */*/__pycache__ .coverage htmlcov

	echo "Cleaning up the devcontainer image ($(IMAGE_NAME))..."
	@image_id=$$(docker images -q $(IMAGE_NAME)); \
	if [ -n "$$image_id" ]; then \
		echo "Found image: $(IMAGE_NAME)"; \
		container_ids=$$(docker ps -aq -f ancestor=$(IMAGE_NAME)); \
		if [ -n "$$container_ids" ]; then \
			echo "Stopping and removing containers: $$container_ids"; \
			docker stop $$container_ids > /dev/null 2>&1; \
			docker rm $$container_ids > /dev/null 2>&1; \
		else \
			echo "No containers found for image: $(IMAGE_NAME)"; \
		fi; \
		echo "Removing image: $(IMAGE_NAME)"; \
		docker rmi $(IMAGE_NAME) > /dev/null 2>&1; \
	else \
		echo "Image not found: $(IMAGE_NAME)"; \
	fi