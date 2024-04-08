# Go Setup

This document provides instructions for setting up the Go development environment.

> [!IMPORTANT]
> The following is assumed:
>
> * The [install.sh](../install.sh) script has been executed.
> * [Go](https://golang.org/) is installed on the system and [golangci-lint](https://golangci-lint.run/) is available in the PATH. The [Go setup script](../.config/nvim/scripts/lang/golang.sh) would have automatically installed these if `go` was detected on the system.

## VSCode Setup

1. Install the Go extension for VSCode.
2. Configure the `settings.json` file as follows:

```json
"go.lintTool": "golangci-lint",
"go.lintFlags": [
    "--config",
    "~/.config/.golangci.yaml",
    "--fast",
    "--fix"
]
```
