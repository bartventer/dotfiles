# [3.3.0](https://github.com/bartventer/dotfiles/compare/v3.2.0...v3.3.0) (2024-03-11)


### Bug Fixes

* **golang.sh:** resolve sudo issue on CI ([2c26e79](https://github.com/bartventer/dotfiles/commit/2c26e793c43d22062ce9d86abd09596d7ba72292))
* **install.sh:** resolve sudo issue on CI ([9707ff2](https://github.com/bartventer/dotfiles/commit/9707ff2f28fd71a8f98d6b3ca8e206005286a29a))


### Features

* **install.sh:** add enhancements for prompts, locale setup, and logging ([45705aa](https://github.com/bartventer/dotfiles/commit/45705aaa4526f7985a0ba6296a419a7c94f78288))
* **install.sh:** add locale generation support for multiple platforms ([1c2b43f](https://github.com/bartventer/dotfiles/commit/1c2b43fcf4cce5ef6c33d98d3644ea14f672475b))
* **install.sh:** enhance locale generation for Docker environments ([0779ca4](https://github.com/bartventer/dotfiles/commit/0779ca4bc6a306fe460fb91fd52d3d095bcf82b7))
* **logging:** Enhance logging with levels and traceability ([4a50c8c](https://github.com/bartventer/dotfiles/commit/4a50c8caec29eb6715455ebb0d790e943e5226c5))
* **scripts:** add init.sh for common initialization across scripts ([8179c4c](https://github.com/bartventer/dotfiles/commit/8179c4c243c88c8e7798a78c9e39c5f0734bf13a))
* **update_fonts.sh:** add scripts for retrieving latest fonts ([47ce66d](https://github.com/bartventer/dotfiles/commit/47ce66dd305e8d6794c922a548b07a3eddc757b9))

# [3.2.0](https://github.com/bartventer/dotfiles/compare/v3.1.1...v3.2.0) (2024-03-10)


### Bug Fixes

* **install.sh:** Correct sourcing of log script ([ad1edad](https://github.com/bartventer/dotfiles/commit/ad1edad492733bcc95ca7d0933e456bebd381c99))
* **install.sh:** fix repo directory for CI ([15a258e](https://github.com/bartventer/dotfiles/commit/15a258e518d039d72bedd3db13f45fe1f20fdb5e))


### Features

* **logging:** add color logging with log.sh ([5dadd39](https://github.com/bartventer/dotfiles/commit/5dadd399000921c2067d4828e799aea544f9f1a4))

## [3.1.1](https://github.com/bartventer/dotfiles/compare/v3.1.0...v3.1.1) (2024-03-09)


### Bug Fixes

* **install.sh:** remove duplicate declared defaults ([8ce8365](https://github.com/bartventer/dotfiles/commit/8ce8365b9469a1e9953a8cc1fd183144202178e7))

# [3.1.0](https://github.com/bartventer/dotfiles/compare/v3.0.0...v3.1.0) (2024-03-09)


### Features

* **install.sh:** enhance user interface with colored prompts ([ffd1baa](https://github.com/bartventer/dotfiles/commit/ffd1baa282b48ba9efb4c4e6619f1734a7d5199f))

# [3.0.0](https://github.com/bartventer/dotfiles/compare/v2.8.0...v3.0.0) (2024-03-09)


### Features

* **install.sh:** add interactive mode to installation script, remove clipboard config script path option ([1db271f](https://github.com/bartventer/dotfiles/commit/1db271f0eb8555178ed4cc80df7659930cdcebaa))


### BREAKING CHANGES

* **install.sh:** The option flag for setting the clipboard config script path has been removed. Interactive mode has been added, which allows users to specify custom options for the installation script. It can be enabled with the `--it` or `--interactive command`-line arguments. By default, the script runs in non-interactive mode.

# [2.8.0](https://github.com/bartventer/dotfiles/compare/v2.7.1...v2.8.0) (2024-03-09)


### Features

* **install.sh:** expand Neovim configuration ([1a02c0d](https://github.com/bartventer/dotfiles/commit/1a02c0d55517c6e58fdb2d7c1e2d94033891e1da))
* **install.sh:** Streamline package installation ([6b608b9](https://github.com/bartventer/dotfiles/commit/6b608b977e1ebe0a6f4015d713b1e11e5133f877))

## [2.7.1](https://github.com/bartventer/dotfiles/compare/v2.7.0...v2.7.1) (2024-03-09)


### Bug Fixes

* **install.sh:** Reorder main section and refactor shell checks ([46864cb](https://github.com/bartventer/dotfiles/commit/46864cb595a03c7e94db20fdb98ea7ca61bc58d2))
* **install.sh:** update archlinux distro specific dependencies ([a622504](https://github.com/bartventer/dotfiles/commit/a622504ddb7cc6de94149fc2479749af73b0b6a7))

# [2.7.0](https://github.com/bartventer/dotfiles/compare/v2.6.0...v2.7.0) (2024-03-09)


### Features

* **install.sh:** add shell parameter to install_packages function ([26bd996](https://github.com/bartventer/dotfiles/commit/26bd9964db537ec9ffe694a480414fde051a75ea))

# [2.6.0](https://github.com/bartventer/dotfiles/compare/v2.5.1...v2.6.0) (2024-03-08)


### Features

* **install.sh, neovim/scripts:** Add detailed logging to improve traceability and debugging ([94ebaeb](https://github.com/bartventer/dotfiles/commit/94ebaeb7b6159879966a91a63cc326439ba4f211))

## [2.5.1](https://github.com/bartventer/dotfiles/compare/v2.5.0...v2.5.1) (2024-03-08)


### Bug Fixes

* **install.sh:** resolve incorrect scripts path on CI ([f6c802e](https://github.com/bartventer/dotfiles/commit/f6c802ebbdfc32a0ff2c2ea8733e01b8e890fdeb))

# [2.5.0](https://github.com/bartventer/dotfiles/compare/v2.4.0...v2.5.0) (2024-03-08)


### Features

* **install.sh:** update distro-specific packages parsing ([337057e](https://github.com/bartventer/dotfiles/commit/337057ebf7f84acdde942bdc7cd60eb16c9cc949))

# [2.4.0](https://github.com/bartventer/dotfiles/compare/v2.3.1...v2.4.0) (2024-03-08)


### Bug Fixes

* **golang.sh:** add no-confirm install option ([8f37617](https://github.com/bartventer/dotfiles/commit/8f37617de392e67b1f561881d7799768a0891b78))


### Features

* **install.sh:** Enhance package installation, Neovim configuration, and shell detection ([834a5b2](https://github.com/bartventer/dotfiles/commit/834a5b2c8e7ff383f94ec5ed37ed6eee6e46c7ad))

## [2.3.1](https://github.com/bartventer/dotfiles/compare/v2.3.0...v2.3.1) (2024-03-08)


### Bug Fixes

* **install.sh:** remove printenv logs ([c058b7d](https://github.com/bartventer/dotfiles/commit/c058b7da61b1ae354bd45f41ef474e7fb2d958fb))

# [2.3.0](https://github.com/bartventer/dotfiles/compare/v2.2.2...v2.3.0) (2024-03-08)


### Features

* **install.sh:** Simplify package manager commands ([4f41db0](https://github.com/bartventer/dotfiles/commit/4f41db0b61d6ffb949695fc05168469ca1494f88))

## [2.2.2](https://github.com/bartventer/dotfiles/compare/v2.2.1...v2.2.2) (2024-03-08)


### Bug Fixes

* **install.sh:** Correct install_packages parsing ([571268b](https://github.com/bartventer/dotfiles/commit/571268b6472204c5088f5616cd04ebfd03442a61))

## [2.2.1](https://github.com/bartventer/dotfiles/compare/v2.2.0...v2.2.1) (2024-03-08)


### Bug Fixes

* **install.sh:** Correct command execution in install_packages function ([82d7214](https://github.com/bartventer/dotfiles/commit/82d72141976d4207c39957791945674468082454))

# [2.2.0](https://github.com/bartventer/dotfiles/compare/v2.1.2...v2.2.0) (2024-03-08)


### Bug Fixes

* **install.sh:** adjust command parsing in install_packages function for POSIX shells ([19f75bb](https://github.com/bartventer/dotfiles/commit/19f75bba5515f97255a2ba4e9cb4eb92afbd9eb8))
* **install.sh:** correct package manager command parsing in install_packages function ([769f7e1](https://github.com/bartventer/dotfiles/commit/769f7e1bd4c4d2d770d56c3f216829c5061e0fdc))
* **install.sh:** resolve command parsing and execution in install_packages function ([bf31b27](https://github.com/bartventer/dotfiles/commit/bf31b270d1f127d76b3e51ce5a636973ae4f7851))
* **install.sh:** skip nvim headless commands in CI ([eeb71cb](https://github.com/bartventer/dotfiles/commit/eeb71cb403d613b47e8c03586ac6c0e4cd7f9ce2))
* **install.sh, clipboard.sh:** Update script paths for CI environment ([e6f0a1b](https://github.com/bartventer/dotfiles/commit/e6f0a1b7b88eeb1ad9aa4592dd9cab18c39cab77))


### Features

* **install.sh:** add conditional execution of language-specific Neovim headless mode ([2b7b9ca](https://github.com/bartventer/dotfiles/commit/2b7b9ca8a3731e77ae1ece16c9253330a8f465bf))
* add conditional execution of language-specific Neovim script ([6e94415](https://github.com/bartventer/dotfiles/commit/6e94415540a3f0b8efd94d6766b21291adde2f98))

## [2.1.2](https://github.com/bartventer/dotfiles/compare/v2.1.1...v2.1.2) (2024-03-08)


### Bug Fixes

* **install.sh:** Use `ps` for shell detection for improved compatibility ([064cc83](https://github.com/bartventer/dotfiles/commit/064cc832d5b4283e2e321b556d1ce1aa64554ae8))

## [2.1.1](https://github.com/bartventer/dotfiles/compare/v2.1.0...v2.1.1) (2024-03-08)


### Bug Fixes

* **install.sh:** Update package manager detection to use `command -v` for improved compatibility across different environments. ([b084175](https://github.com/bartventer/dotfiles/commit/b084175d506ff6e9d4f1b48ff9fc74cb469c99e3))

# [2.1.0](https://github.com/bartventer/dotfiles/compare/v2.0.3...v2.1.0) (2024-03-08)


### Features

* **install.sh:** Improve package manager detection for CI environments ([1df065b](https://github.com/bartventer/dotfiles/commit/1df065bd7803c4baddd0687acbca3dbd642a4426))

## [2.0.3](https://github.com/bartventer/dotfiles/compare/v2.0.2...v2.0.3) (2024-03-08)


### Bug Fixes

* **install.sh:** Use 'type' command for package manager detection ([c1671e2](https://github.com/bartventer/dotfiles/commit/c1671e26eb0d0f2803c2f60f2279aa170c17b56a))

## [2.0.2](https://github.com/bartventer/dotfiles/compare/v2.0.1...v2.0.2) (2024-03-08)


### Bug Fixes

* Use 'which' command for package manager detection ([ca0ade6](https://github.com/bartventer/dotfiles/commit/ca0ade677a263fcc1ba66fca5e185200b6320e73))

## [2.0.1](https://github.com/bartventer/dotfiles/compare/v2.0.0...v2.0.1) (2024-03-08)


### Bug Fixes

* **install.sh:** Add condition to check for CI environment variable before updating package lists ([682cb05](https://github.com/bartventer/dotfiles/commit/682cb057a65b22c7557c8e500bd92ace15d415e0))
* **install.sh:** Use `$0` to determine shell type instead of 'ps' command ([af7b28b](https://github.com/bartventer/dotfiles/commit/af7b28b670631bcfe008e02038867d66457cb5dd))

# [2.0.0](https://github.com/bartventer/dotfiles/compare/v1.2.0...v2.0.0) (2024-03-08)


### Bug Fixes

* **install.sh:** Resolved 'bad option: -a' error in script ([abf381f](https://github.com/bartventer/dotfiles/commit/abf381f27bd7f56e0355a228bd24fc423ec0d6ca))
* **install.sh:** Update install.sh for compatibility with both Bash and Zsh ([e125492](https://github.com/bartventer/dotfiles/commit/e125492f2bf77fad1f8a21561a7acc64841d626c))
* **install.sh:** Update option parsing in install.sh and update documentation ([7adb196](https://github.com/bartventer/dotfiles/commit/7adb1964a7f59cf7e6409a5774262e4093ca034b))


### Features

* **CI:** set shell to  zsh for install script step on Macos and Linux distros ([58b83c8](https://github.com/bartventer/dotfiles/commit/58b83c80c969db5ca77d18ebe02273ffaf960956))
* **install.sh:** Enhance plugin cloning compatibility for Bash and Zsh ([33ae22a](https://github.com/bartventer/dotfiles/commit/33ae22a1a7df1c70997d60073e0b81ad134c361c))
* **install.sh:** Enhance script compatibility with macOS and CI environments ([aabb26e](https://github.com/bartventer/dotfiles/commit/aabb26ece2a797bb5c341ed8cd1b3c002b18287a))
* **install.sh:** Improve shell detection and package manager iteration ([ac5d093](https://github.com/bartventer/dotfiles/commit/ac5d093cd8553af96aa72dcb1e12b1d368d14e62))


### BREAKING CHANGES

* **install.sh:** The script no longer supports long command-line options. Users who were using long options will need to switch to short options. Scripts that rely on the old `getopt` command may need to be updated.

# [1.2.0](https://github.com/bartventer/dotfiles/compare/v1.1.7...v1.2.0) (2024-03-08)


### Bug Fixes

* **.zshrc:** Update file with new paths and sources ([3dd6963](https://github.com/bartventer/dotfiles/commit/3dd69633455561f53debe0f959eee1cbd2f27afc))
* **dap-go.lua, keymaps.lua:** move keymaps to dap-go.lua to resolve multiple require issue ([fb6be07](https://github.com/bartventer/dotfiles/commit/fb6be0764979ede520f39f7ba15a1706c122ec03))
* **install.sh:** move distro packages installation before oh-my-zsh and fonts setup ([a2756ae](https://github.com/bartventer/dotfiles/commit/a2756aeea9fbb157ca0ab72401145b3560b518f5))
* **install.sh:** move neovim configuration to after oh-my-zsh setup ([43ee885](https://github.com/bartventer/dotfiles/commit/43ee885f1c88aa26c3e5c1b5adec9d9fff02fe22))
* **nvim-dap-virtual-text.lua, settings.json:** suppress `shellcheck` warnings ([110bc31](https://github.com/bartventer/dotfiles/commit/110bc31d43b2e518772ba6c97553c097e67550e9))


### Features

* **install.sh:** enhance neovim installation and configuration ([b054fd0](https://github.com/bartventer/dotfiles/commit/b054fd0fb1445dfedc91ed2703555b3e8ae3ff86))
* **tmux:** enable mouse mode and add pane navigation ([65d1ad9](https://github.com/bartventer/dotfiles/commit/65d1ad9e664b6247ae26f9048f3eeaa34c60fb22))

## [1.1.7](https://github.com/bartventer/dotfiles/compare/v1.1.6...v1.1.7) (2024-03-07)


### Bug Fixes

* **install.sh:** Refactor Neovim configuration to execute commands individually in headless mode ([82b7533](https://github.com/bartventer/dotfiles/commit/82b7533989fe99c8f4d4ba186838f36f3ded2aa3))
* **install.sh:** update `configure_neovim` function ([5658d4c](https://github.com/bartventer/dotfiles/commit/5658d4ccbd01d4a910dd681a3b44f4cccdc4515c))

## [1.1.6](https://github.com/bartventer/dotfiles/compare/v1.1.5...v1.1.6) (2024-03-07)


### Bug Fixes

* **CI:** handle different distributions in CI setup ([8df1068](https://github.com/bartventer/dotfiles/commit/8df106805bc964bc7d7f6e97a00196fbd97f1135))
* **CI:** use case statement for package manager in CI setup ([61a5e72](https://github.com/bartventer/dotfiles/commit/61a5e7202d8986f52a2fc4e62d861ff9e67a2d3f))

## [1.1.5](https://github.com/bartventer/dotfiles/compare/v1.1.4...v1.1.5) (2024-03-07)


### Bug Fixes

* **install.sh:** correct command execution in install_packages function ([97da2e7](https://github.com/bartventer/dotfiles/commit/97da2e7b8f6e25421511cd4fa803d95864e26e5c))

## [1.1.4](https://github.com/bartventer/dotfiles/compare/v1.1.3...v1.1.4) (2024-03-07)


### Bug Fixes

* **install.sh:** replace `command_exists` function with direct command check ([3c49458](https://github.com/bartventer/dotfiles/commit/3c494589669821f20a2fa492c999df2b84165d1b))

## [1.1.3](https://github.com/bartventer/dotfiles/compare/v1.1.2...v1.1.3) (2024-03-07)


### Bug Fixes

* **install.sh:** update pacman neovim installation case branch ([facb416](https://github.com/bartventer/dotfiles/commit/facb416b8484161c214362df5fb2a5b95ad3aaa1))

## [1.1.2](https://github.com/bartventer/dotfiles/compare/v1.1.1...v1.1.2) (2024-03-07)


### Bug Fixes

* **install.sh/pkg_managers:** store `install`, `update`, and `is_installed` commands as comma-separated string ([f49a437](https://github.com/bartventer/dotfiles/commit/f49a4378f19273f9ef54e7e9f166c04b184d926e))

## [1.1.1](https://github.com/bartventer/dotfiles/compare/v1.1.0...v1.1.1) (2024-03-07)


### Bug Fixes

* **.config/nvim:** correct the path for the Delve debugger in dap-go configuration ([b79f4db](https://github.com/bartventer/dotfiles/commit/b79f4db2bb5a80ac1292d68983906c348bbe9892))

# [1.1.0](https://github.com/bartventer/dotfiles/compare/v1.0.0...v1.1.0) (2024-03-07)


### Features

* **install.sh, .config/nvim:** enhance Neovim installation with new scripts and options ([1220a31](https://github.com/bartventer/dotfiles/commit/1220a31aecb455125b6649d91f5faea62b57d400))
* **neovim:** add new Neovim debugging plugins ([1ab7c97](https://github.com/bartventer/dotfiles/commit/1ab7c9779380affe7170d50acc3b89e138cc1928))

# 1.0.0 (2024-03-05)


### Features

* Initial release of dotfiles ([0c52adf](https://github.com/bartventer/dotfiles/commit/0c52adf6112ac0dfe95bda85d3d1fe141cc466bd))
