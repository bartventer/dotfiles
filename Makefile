.PHONY: test-linux test-macos semantic-release list-tests help

ACT_FLAGS=-P macos-latest=sickcodes/docker-osx:latest

test-linux:
	act -j test-linux

test-macos:
	act -j test-macos $(ACT_FLAGS)

list-tests:
	@echo "Available test jobs:"
	@act -l

help:
	@echo "Usage: make [TARGET]"
	@echo "Targets:"
	@echo "  test-linux        Run the test-linux job"
	@echo "  test-macos        Run the test-macos job"
	@echo "  list-tests        List available test jobs"
	@echo "  help              Display this help message"