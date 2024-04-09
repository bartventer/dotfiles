# Go Setup

This document provides instructions for setting up the Go development environment.

> [!IMPORTANT]
> The following is assumed:
>
> * The [install.sh](../install.sh) script has been executed.
> * [Go](https://golang.org/) is installed on the system and [golangci-lint](https://golangci-lint.run/) is available in the PATH. The [Go setup script](../.config/nvim/scripts/lang/golang.sh) would have automatically installed these if `go` was detected on the system.

## VSCode Setup

1. Install the Go extension for VSCode.
2. If the default [golangci configuration](../.config/.golangci.yaml) is sufficient for the project's linting requirements, configure the `settings.json` file as follows:

```json
"go.lintTool": "golangci-lint",
"go.lintFlags": [
    "--config",
    "~/dotfiles/.config/.golangci.yaml",
    "--fast",
    "--fix"
]
```

> [!NOTE]
> If you require project-specific configuration, you can create symbolic links to the `.golangci-lint.yaml` file in the root of your project where `go.mod` is located.
>
> ```bash
> ln -sf ~/dotfiles/.config/.golangci-lint.yaml ./.golangci-lint.yaml
> ```
>
> You'll also need to remove the `--config` flag from the `go.lintFlags` setting in the `settings.json` file.
>
> If you're using a Go workspace, you can create symbolic links to the `.golangci-lint.yaml` file in the root of your repo (referred to as the workspace root). Then, for each package in your workspace that contains a `go.mod` file, create a symbolic link to the `.golangci-lint.yaml` file in the workspace root.
>
> ```bash
> ln -sf ~/dotfiles/.config/.golangci-lint.yaml ./.golangci-lint.yaml
> ln -sf ../.golangci-lint.yaml ./package1/.golangci-lint.yaml
> ln -sf ../.golangci-lint.yaml ./package2/.golangci-lint.yaml
> ```
>
> This way, you can have a single configuration file for the entire workspace and override it for specific packages.
>
> Remember to remove the `--config` flag from the `go.lintFlags` setting in the `settings.json` file.
