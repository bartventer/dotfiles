.SHELLFLAGS = -ec
.ONESHELL:
SHELL = /bin/bash

# Devcontainer variables
IMAGE_NAME?=archlinux## The name of the base image. Options: archlinux, debian, fedora, ubuntu. Defaults to "archlinux"
DEVCONTAINER_WORKSPACE_FOLDER=.## The workspace folder to mount in the devcontainer. Defaults to "." (current directory)
TEST_DIR:=tests## The directory to run tests from. Defaults to "tests"
TEST_PROJECT_PATH?="$(TEST_DIR)/test_project"## The path to the test project. Defaults to "test_project"
DEVCONTAINER_CONFIG_PATH?="$(TEST_PROJECT_PATH)/$(IMAGE_NAME)/.devcontainer/devcontainer.json"## The path to the devcontainer build context. Defaults to "test_project/$(IMAGE_NAME)/.devcontainer"
DEVCONTAINER_TEST_SCRIPT?="test.sh"## The test script to run in the devcontainer. Defaults to "test.sh"
LABEL_KEY=test-container## The label key to use for the test container. Defaults to "test-container"

# Install variables
OHMYZSH_THEME_REPO?="romkatv/powerlevel10k"## The Zsh theme repository to install. Defaults to "romkatv/powerlevel10k"
DOTFILES_FONT?="MesloLGS NF"## The font to install. Defaults to "MesloLGS NF"

# Dotfiles path variables
DOTFILES_CONFIG_DIR=config
DOTFILES_TOOLS_DIR=tools
DOTFILES_UPDATE_FONTS_SCRIPT=$(DOTFILES_TOOLS_DIR)/update_fonts.sh
DOTFILES_INSTALL_SCRIPT=install.sh
ifeq ($(CI),true)
	DOTFILES_REPO_FLAGS=\
		--dotfiles-repository $(GITHUB_REPOSITORY) \
		--dotfiles-target-path ~/dotfiles \
		--dotfiles-install-command $(DOTFILES_INSTALL_SCRIPT)
else
	DOTFILES_REPO_FLAGS=
endif

# Devcontainer command
DEVCONTAINER=npx devcontainer
DEVCONTAINER_BUILD=$(DEVCONTAINER) build
DEVCONTAINER_UP=$(DEVCONTAINER) up
DEVCONTAINER_EXEC=$(DEVCONTAINER) exec

# Devcontainer flags
DEVCONTAINER_BUILD_FLAGS=\
	--workspace-folder $(DEVCONTAINER_WORKSPACE_FOLDER) \
	--config $(DEVCONTAINER_CONFIG_PATH) \
	--image-name $(IMAGE_NAME)
DEVCONTAINER_EXEC_FLAGS=\
	--workspace-folder $(DEVCONTAINER_WORKSPACE_FOLDER) \
	--config $(DEVCONTAINER_CONFIG_PATH) \
	--id-label $(LABEL_KEY)=$(IMAGE_NAME)
DEVCONTAINER_UP_FLAGS=$(DEVCONTAINER_EXEC_FLAGS) $(DOTFILES_REPO_FLAGS)

# Docker variables
CONTAINER_ID=$(shell docker ps -q -f label=$(LABEL_KEY)=$(IMAGE_NAME) | head -n 1)
# Extract the remoteUser from the devcontainer.metadata label (defaults to "vscode")
REMOTE_USER=$(if $(CONTAINER_ID),\
$(shell docker inspect -f '{{index .Config.Labels "devcontainer.metadata"}}' $(CONTAINER_ID) | \
jq -r '.[] | select(.remoteUser // .containterUser) | .remoteUser // .containterUser'),\
vscode)
DOCKER_EXEC_CMD?=/bin/zsh## The command to run in the devcontainer shell. Defaults to "/bin/zsh"

# Docker command
DOCKER=docker
DOCKER_EXEC=$(DOCKER) exec

# Docker flags
DOCKER_EXEC_FLAGS=-it -u $(shell id -u):$(shell id -g) -w $(shell pwd) $(CONTAINER_ID)

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
COVERAGE_REPORT_FORMAT ?= html  # Default to HTML coverage report
UNITTEST_DISCOVER=unittest discover

# Virtual environment
VENV_ACTIVATE=. $(HOME)/.venvs/dotfiles/bin/activate

# Python commands
PYTHON_TEST=$(VENV_ACTIVATE); python3 -m $(UNITTEST_DISCOVER)
PYTHON_COVERAGE=$(VENV_ACTIVATE); coverage run --source=. -m $(UNITTEST_DISCOVER)
PYTHON_COVERAGE_REPORT=$(VENV_ACTIVATE); coverage $(COVERAGE_REPORT_FORMAT)

# Python flags
PYTHON_TEST_FLAGS=-s $(TEST_DIR)/
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

# Config variables
DOTFILES_CONFIG_PATH=$(DOTFILES_CONFIG_DIR)/config.json
CONFIG_SCHEMA=$(DOTFILES_CONFIG_DIR)/config.schema.json

# Config Validation Command
AJV=npx ajv
AJV_VALIDATE=$(AJV) validate

# Config Validation Flags
AJV_VALIDATE_FLAGS=\
	-s $(CONFIG_SCHEMA) \
	-d $(DOTFILES_CONFIG_PATH) \
	-c ajv-formats \
	--verbose

# Dependencies
DOTFILES_COMMON_DEPS = $(wildcard scripts/*)

# Error handling function
define error_exit
	@echo "Error: $(1)"
	@exit 1
endef

# Color variables
BLUE=\033[1;34m
RESET=\033[0m

define print-system-info
	@echo -e "$(BLUE)System info:$(RESET)"
	@echo "OS: $(shell uname -s)"
	@echo "Kernel: $(shell uname -r)"
	@echo "Architecture: $(shell uname -m)"
	@echo "Hostname: $(shell hostname)"
	@echo "Username: $(shell whoami)"
	@echo "Home directory: $(HOME)"
	@echo "Current directory: $(shell pwd)"
	@echo -e "$(BLUE)OS info:$(RESET)"
	@case "$(shell uname -s)" in \
		"Linux") cat /etc/os-release ;; \
		"Darwin") sw_vers ;; \
	esac
	@echo -e "$(BLUE)Environment variables:$(RESET)"
	@env | sort
	@echo -e "\n"
endef

.PHONY: help
help: ## Display this help message.
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m    %-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variables:"
	@awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+\s*\?=\s*.*?## / {split($$1, a, "\\s*\\?=\\s*"); printf "\033[33m   %-30s\033[0m %s\n", a[1], $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Variable Values:"
	@awk 'BEGIN {FS = "[ ?=]"} /^[a-zA-Z_-]+[ \t]*[?=]/ {print $$1}' $(MAKEFILE_LIST) | \
	while read -r var; do \
		printf "\033[35m    %-30s\033[0m %s\n" "$$var" "$$(make -s -f $(firstword $(MAKEFILE_LIST)) print-$$var)"; \
	done

.PHONY: print-%
print-%: ## Helper target to print a variable. Usage: make print-VARIABLE
	@printf '%s' "$($*)"

install: $(DOTFILES_COMMON_DEPS) $(DOTFILES_CONFIG_DIR) .config $(DOTFILES_INSTALL_SCRIPT) .tmux.conf .zshrc ## Run the install.sh script (optional args: OHMYZSH_THEME_REPO, DOTFILES_FONT)
	chmod +x $(DOTFILES_INSTALL_SCRIPT)
	./$(DOTFILES_INSTALL_SCRIPT) \
		-r $(OHMYZSH_THEME_REPO) \
		-f $(DOTFILES_FONT)

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

.PHONY: python-test
python-test: ## Run the tests
	$(call print-system-info)
	$(PYTHON_TEST) $(PYTHON_TEST_FLAGS)

.PHONY: coverage
coverage: ## Run the tests with coverage
	$(call print-system-info)
	$(PYTHON_COVERAGE) $(PYTHON_COVERAGE_FLAGS)

.PHONY: coverage-report
coverage-report: ## Generate the coverage report (optional args: COVERAGE_REPORT_FORMAT=xml to generate XML report, defaults to html)
	$(call print-system-info)
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
	$(DEVCONTAINER_UP) $(DEVCONTAINER_UP_FLAGS)
	@if [ -f "$(DOTFILES_INSTALL_SCRIPT)" ]; then \
		echo "⚠️ Running the install.sh script in the devcontainer as dotfiles repository is not set..."; \
		$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
		make install'; \
	fi

.PHONY: test
test: ## Run the dotfiles tests
	@echo "Running the dotfiles tests..."
	$(call print-system-info)
	set -e; \
	if [ -f "$(TEST_PROJECT_PATH)/$(DEVCONTAINER_TEST_SCRIPT)" ]; then \
		cd $(TEST_PROJECT_PATH); \
		chmod +x $(DEVCONTAINER_TEST_SCRIPT); \
		./$(DEVCONTAINER_TEST_SCRIPT); \
	else \
		echo "❌ Error. Dotfiles test script ($(DEVCONTAINER_TEST_SCRIPT)) not found."; \
		exit 1; \
	fi

.PHONY: devcontainer-test
devcontainer-test: ## Test the devcontainer image
	@echo "Testing the devcontainer image ($(IMAGE_NAME))..."
	$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
		make test'

.PHONY: devcontainer-python-test
devcontainer-python-test: ## Run the Python tests in the devcontainer (runs `make test`)
	$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/sh -c '\
		set -e; \
		make python-test'

.PHONY: devcontainer-exec
devcontainer-exec: ## Run a shell in the devcontainer.
	@echo "Running shell in devcontainer ($(IMAGE_NAME))..."
	$(DEVCONTAINER_EXEC) $(DEVCONTAINER_EXEC_FLAGS) /bin/zsh

.PHONY: docker-exec
docker-exec: ## Run a shell in the devcontainer image
	@echo "Running a shell in the devcontainer image ($(IMAGE_NAME))..."
	@if [ -z "$(CONTAINER_ID)" ]; then \
		echo "No container found with label: $(LABEL_KEY)=$(IMAGE_NAME)"; \
	else \
		$(DOCKER_EXEC) $(DOCKER_EXEC_FLAGS) $(DOCKER_EXEC_CMD); \
	fi

.PHONY: clean
clean: ## Clean up the act output directory and remove the devcontainers
	@echo "Cleaning up the act output directory ($(ACT_OUTPUT_DIR))..."
	rm -rf $(ACT_OUTPUT_DIR)/*.txt $(ACT_OUTPUT_DIR) __pycache__ */__pycache__ */*/__pycache__ .coverage htmlcov
	@printf "OK. Done cleaning up the act output directory.\n\n"

	@echo "Removing the devcontainers with label starting with: $(LABEL_KEY)..."
	@CONTAINER_IDS=$$(docker ps -a -q | xargs -I {} docker inspect {} | \
	jq -r 'select(any(.[0].Config.Labels | keys[]; startswith("$(LABEL_KEY)"))) | .[0].Id'); \
	if [ -z "$$CONTAINER_IDS" ]; then \
		echo "OK. No containers found to delete."; \
	else \
		echo $$CONTAINER_IDS | xargs -I {} sh -c 'echo "Removing container ID: {}" && docker rm -f {}'; \
		echo "OK. Done removing containers."; \
	fi

validate-config: $(DOTFILES_CONFIG_PATH) $(CONFIG_SCHEMA) ## Validate the config file
	@echo "🚀 Validating the configuration file ($(DOTFILES_CONFIG_PATH))..."
	$(AJV_VALIDATE) $(AJV_VALIDATE_FLAGS) || (echo "❌ Error. Config file is invalid." && exit 1)
	@echo "✅ OK. Config file is valid."