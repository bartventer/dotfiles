.PHONY: test-linux test-macos semantic-release list-tests help install update-fonts

# Test job variables
ACT_FLAGS=-P macos-latest=sickcodes/docker-osx:latest

# Install script variables
REPO ?= "romkatv/powerlevel10k"
LANGUAGES ?= "golang"
FONT ?= "MesloLGS NF"

test-linux:
	act -j test-linux

test-macos:
	act -j test-macos $(ACT_FLAGS)

install:
	chmod +x install.sh
	./install.sh -r $(REPO) -l $(LANGUAGES) -f $(FONT)

update-fonts:
	chmod +x update_fonts.sh
	./update_fonts.sh

list-tests:
	@echo "Available test jobs:"
	@act -l

help:
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@echo "  test-linux        Run the test-linux job"
	@echo "  test-macos        Run the test-macos job"
	@echo "  install           Run the install.sh script <REPO> <LANGUAGES> <FONT>"
	@echo "  update-fonts      Run the update_fonts.sh script"
	@echo "  list-tests        List available test jobs"
	@echo "  help              Display this help message"