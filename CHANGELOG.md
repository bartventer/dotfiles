# [3.12.0](https://github.com/bartventer/dotfiles/compare/v3.11.0...v3.12.0) (2024-03-29)


### Features

* **scripts:** add additional go tools ([e3d018d](https://github.com/bartventer/dotfiles/commit/e3d018d99a683addaabc341604aadf469afe80ae))

# [3.11.0](https://github.com/bartventer/dotfiles/compare/v3.10.5...v3.11.0) (2024-03-29)


### Features

* **scripts:** add `cosmtrek/air` tool to golang script ([39f3a6c](https://github.com/bartventer/dotfiles/commit/39f3a6c28a348920f6e1aa02469c991e81404503))

## [3.10.5](https://github.com/bartventer/dotfiles/compare/v3.10.4...v3.10.5) (2024-03-29)


### Bug Fixes

* **install.sh:** correct `PATH` on ubuntu and debian ([52f140c](https://github.com/bartventer/dotfiles/commit/52f140c9c772e20a9384003d508ef12c26cf804f))
* **install.sh:** correct macOS permissions for npm-cache ([70f8cc3](https://github.com/bartventer/dotfiles/commit/70f8cc30d3f929e7b1bef2143333fa41b6605018))
* **install.sh:** export venv variables ([8fab623](https://github.com/bartventer/dotfiles/commit/8fab62359e320574827a3c7293fda02338dcb8ab))
* **install.sh:** fix package installation step ([a3a5ad6](https://github.com/bartventer/dotfiles/commit/a3a5ad612a1f775b01561e17190795a12420be68))
* **install.sh:** modify go install script and add `venv` for Neovim ([b5485dd](https://github.com/bartventer/dotfiles/commit/b5485ddb753ddb959a7a34ebfdda70820a418eae))
* **install.sh:** skip setting path on CI ([595a29d](https://github.com/bartventer/dotfiles/commit/595a29deb941c1b38b76d016d0b0051627a5629a))
* **neovim:** add check for `NVIM_VENV` ([4c7398e](https://github.com/bartventer/dotfiles/commit/4c7398ed957663f1fa5122230a8b31f6c9f3b159))
* **scripts:** adjust path modification on CI runner ([5fff859](https://github.com/bartventer/dotfiles/commit/5fff859e008bb98463319e2effb048e6fbecd0a9))

## [3.10.4](https://github.com/bartventer/dotfiles/compare/v3.10.3...v3.10.4) (2024-03-29)


### Bug Fixes

* **config:** correct syntax error in json file ([a4abdc9](https://github.com/bartventer/dotfiles/commit/a4abdc9a858e53676346840c5a18d9ef71c6c6af))
* **config:** update distro specific dependencies ([dc65f51](https://github.com/bartventer/dotfiles/commit/dc65f51d4cfb4dcc294ceec3bf8faf3a158d7818))

## [3.10.3](https://github.com/bartventer/dotfiles/compare/v3.10.2...v3.10.3) (2024-03-28)


### Bug Fixes

* **config:** modify default packages ([0aa36cc](https://github.com/bartventer/dotfiles/commit/0aa36cced55c45fd3cee64557470e8007d6517ef))
* **config.json:** remove python dependency on macOS ([349246e](https://github.com/bartventer/dotfiles/commit/349246ea75cff584bcf9c68fca0fc811d77aa103))
* **install.sh:** modify Homebrew package installation step ([e735b84](https://github.com/bartventer/dotfiles/commit/e735b84c95db070659aa1d11fbdca05b6ec83dcb))
* **install.sh:** modify package installation step ([bf42790](https://github.com/bartventer/dotfiles/commit/bf42790dccabc3489b0533a6d46156bd70d281c7))
* **install.sh:** remove setting of npm config ([ff87ba3](https://github.com/bartventer/dotfiles/commit/ff87ba363951d8cbece76866f4d8a263ca6d8d5d))
* **install.sh:** remove unused `packages` variable ([bc21188](https://github.com/bartventer/dotfiles/commit/bc21188689d47746b66c12b4833411bebaf1dd62))


### Reverts

* **install.sh:** add setting of npm config ([5929ca8](https://github.com/bartventer/dotfiles/commit/5929ca8796ca02744e2f22c1eb883735b9a34089))

## [3.10.2](https://github.com/bartventer/dotfiles/compare/v3.10.1...v3.10.2) (2024-03-26)


### Bug Fixes

* **install.sh:** add `--break-system-packages` flag for pip ([7d48584](https://github.com/bartventer/dotfiles/commit/7d48584144345076fe33ee2a6c3b860aff01d929))
* **install.sh:** correct macOS package installation ([4860a84](https://github.com/bartventer/dotfiles/commit/4860a8444be74d4ea4601a7f3992ccf8e2fe5e3c))
* **install.sh:** correct macOS packages installation ([3a53976](https://github.com/bartventer/dotfiles/commit/3a5397674889cd5b232d4a13a5211c2c58d45a3f))
* **install.sh:** fix neovim installation ([510126d](https://github.com/bartventer/dotfiles/commit/510126d7cb3a2046cc843da0ed09def231d91bc6))
* **install.sh:** update node and python dependencies ([d8cc93d](https://github.com/bartventer/dotfiles/commit/d8cc93d58bfa77f187f9df616cad6625902c9d1d))
* **main.sh:** remove which usage ([4ced985](https://github.com/bartventer/dotfiles/commit/4ced9857425ac5b046e58385abea541a1671dc0a))

## [3.10.1](https://github.com/bartventer/dotfiles/compare/v3.10.0...v3.10.1) (2024-03-25)


### Bug Fixes

* **install.sh:** add force flag to MasonInstall headless command ([79d7598](https://github.com/bartventer/dotfiles/commit/79d75988a62e8144d12834235303a824ca841f5a))
* **install.sh:** adjust shell flags ([d85ad70](https://github.com/bartventer/dotfiles/commit/d85ad70586b2d4dae6be1eac7bb513fb318daecd))
* **install.sh:** adjust shell flags ([6e3a481](https://github.com/bartventer/dotfiles/commit/6e3a481f278ce38baf2938ddf6869afc8ae3674a))
* **install.sh:** change kernal-name getter ([58de5bc](https://github.com/bartventer/dotfiles/commit/58de5bcd7c3165c9ff0ad346bbc754affedb7be9))
* **install.sh:** configure neovim profiles ([73a88c8](https://github.com/bartventer/dotfiles/commit/73a88c8124c5aded1904e13cebf2d806100f26fc))
* **install.sh:** correct kernel check logic ([96eb183](https://github.com/bartventer/dotfiles/commit/96eb183dda414f36970ca709b08de827564232cf))
* **install.sh:** correct permissions on macOS ([ffb9866](https://github.com/bartventer/dotfiles/commit/ffb9866277df028b3cbebcde2ead49a4f5469926))
* **main.sh:** correct distro detection ([b6f0b2f](https://github.com/bartventer/dotfiles/commit/b6f0b2ff62601f7e189b81eebc5885ac3f818321))
* **neovim/golang.sh:** exit if golang is not installed ([fd7ea80](https://github.com/bartventer/dotfiles/commit/fd7ea802b40df1f19f5fa6e0a0bbc8b93cb92ded))

# [3.10.0](https://github.com/bartventer/dotfiles/compare/v3.9.0...v3.10.0) (2024-03-21)


### Features

* **log.sh:** log absolute path of filename ([49ecc65](https://github.com/bartventer/dotfiles/commit/49ecc65091f11e81b1532d48c15835b572717268))

# [3.9.0](https://github.com/bartventer/dotfiles/compare/v3.8.0...v3.9.0) (2024-03-21)


### Bug Fixes

* **install.sh:** remove `root` check for CI environment ([d70a348](https://github.com/bartventer/dotfiles/commit/d70a348b37f8a0531d957e7c0cb0964bbb862796))
* **install.sh:** remove sudo check ([99007e1](https://github.com/bartventer/dotfiles/commit/99007e18cc62c5d66be014e6d73cdd5b02b21a21))


### Features

* **install.sh:** move logic to main.sh ([216234f](https://github.com/bartventer/dotfiles/commit/216234f9c4512e9d01e54f139e1d3a6d25de7360))
* **install.sh:** update uname logic check ([a29e066](https://github.com/bartventer/dotfiles/commit/a29e06689b8b2ccee57b3de2ef4941787f4c8088))

# [3.8.0](https://github.com/bartventer/dotfiles/compare/v3.7.1...v3.8.0) (2024-03-14)


### Bug Fixes

* Correctly populate relative_paths array ([11877cf](https://github.com/bartventer/dotfiles/commit/11877cfecdbaac22b639d3e1b0aec5d3c147e33b))


### Features

* **CI:** optimize coverage generation and reporting ([c3afa32](https://github.com/bartventer/dotfiles/commit/c3afa32208a92327ca1d6edd8d9b6265cf2aaf8b))
* **CI:** update matrix for `coverage` inclusion ([b552ace](https://github.com/bartventer/dotfiles/commit/b552ace3f83893c0dbf9abe57620d21d6d576611))
* **config:** organization configuration files ([312f3eb](https://github.com/bartventer/dotfiles/commit/312f3eb5cf17dd99ee9a4257ea35a7e307584da6))
* **env_setup.py:** add script to initialize environment variables ([027518a](https://github.com/bartventer/dotfiles/commit/027518ad7e096160209d5bfa85a304c983b95bb0))
* **fetch_fonts.py:** refactor font fetching script and add unit tests ([4f1f262](https://github.com/bartventer/dotfiles/commit/4f1f26271da74d0ad679400dd5122e0694bfefed))
* **init.sh:** enforce script to exit on error ([f627216](https://github.com/bartventer/dotfiles/commit/f627216a3cbcfb9c52b931606da0553bd87b21f4))
* **install.sh:** enhance config.json parsing ([137be5f](https://github.com/bartventer/dotfiles/commit/137be5fafae75843a4b6ade51928ed6459e5d572))
* **update_fonts.sh:** enforce script to exit on error ([cfcfee4](https://github.com/bartventer/dotfiles/commit/cfcfee43eb5616b0dc694ddc72cd2ec3d0341da8))

## [3.7.1](https://github.com/bartventer/dotfiles/compare/v3.7.0...v3.7.1) (2024-03-13)


### Bug Fixes

* **install.sh:** add default value for `TERM_COLOR` ([1b01468](https://github.com/bartventer/dotfiles/commit/1b01468a65d5eca7b103c9d821d1489e71efe623))
* **install.sh:** add parsing of `term_color`from config.json ([5dababd](https://github.com/bartventer/dotfiles/commit/5dababdb5df8c892b5f530ca7383015198d7009d))

# [3.7.0](https://github.com/bartventer/dotfiles/compare/v3.6.0...v3.7.0) (2024-03-13)


### Features

* **.tmux.conf:** add dynamic terminal feature setting based on $TERM variable ([f8017eb](https://github.com/bartventer/dotfiles/commit/f8017eb560c3446a3691688ac5ed0cbc482cd2cf))
* **install.sh:** add `tmux` plugins installation ([881d9ed](https://github.com/bartventer/dotfiles/commit/881d9edd7f06399ceceb71c789be8ce76bca39bd))
* **install.sh:** add tpm installation check and improve tmux plugin installation process ([cfdd225](https://github.com/bartventer/dotfiles/commit/cfdd225187cbd9e317ecf68b122f132d345dbed3))

# [3.6.0](https://github.com/bartventer/dotfiles/compare/v3.5.1...v3.6.0) (2024-03-13)


### Bug Fixes

* **all:** remove `rockylinux` distro specific support ([dca2a9a](https://github.com/bartventer/dotfiles/commit/dca2a9ae4e5c0fb8b5fd2ff6b9d54c071eff4b56))


### Features

* **config.json:** add rockylinux distro pacakages ([d9e815c](https://github.com/bartventer/dotfiles/commit/d9e815cd693cd9154bf293f9431fbade16e443c0))

## [3.5.1](https://github.com/bartventer/dotfiles/compare/v3.5.0...v3.5.1) (2024-03-13)


### Bug Fixes

* **install.sh:** Add CI-specific installation for Homebrew packages ([5498f9d](https://github.com/bartventer/dotfiles/commit/5498f9d99bc1580ec51ccd242dd91ab1cda8c8f8))
* **install.sh:** skip package list update in CI environment ([b5b35eb](https://github.com/bartventer/dotfiles/commit/b5b35ebc12af8893e299fc20caade475a91a148d))

# [3.5.0](https://github.com/bartventer/dotfiles/compare/v3.4.0...v3.5.0) (2024-03-12)


### Bug Fixes

* **ci:** resolve Go installation symlink issue in GitHub Actions workflow ([20b4724](https://github.com/bartventer/dotfiles/commit/20b47249787ada37d729794cbb81f7319e007c70))
* **config.json:** add `glibc-langpack-en` to fedora dependencies ([ce2fc3a](https://github.com/bartventer/dotfiles/commit/ce2fc3ac4ca0e450b0acde32c79bea908992f200))
* **config.json:** add `glibc-locale-source` to fedora dependencies ([67e75a0](https://github.com/bartventer/dotfiles/commit/67e75a011f3b636e36a2f3969324d1206f570ef6))
* **config.json:** update fedora dependencies ([915632d](https://github.com/bartventer/dotfiles/commit/915632da30bb6b7dcbb9e50842cd755324086f9a))
* **install.sh:** add debug logging ([c8e5805](https://github.com/bartventer/dotfiles/commit/c8e5805a2b65aead0010fcb8742729d680e5c7ee))
* **install.sh:** add default value handling for OH_MY_ZSH_CUSTOM_THEME_REPO ([3dcd46f](https://github.com/bartventer/dotfiles/commit/3dcd46fdffb147f2d3f45fa58086978109de6829))
* **install.sh:** change font data structure from associative array to two indexed arrays ([9f29ca0](https://github.com/bartventer/dotfiles/commit/9f29ca04dbc5de63678136a7435f69f258cd8b65))
* **install.sh:** correct Homebrew package installation ([561e2f5](https://github.com/bartventer/dotfiles/commit/561e2f5a29ec4eac468f4c7fe7da30d6e0a8fbae))
* **install.sh:** correct parsing of dictionaries from config.json in install.sh ([0523659](https://github.com/bartventer/dotfiles/commit/052365917198f303919c2a619bb0e80f5f107e58))
* **install.sh:** correct path for CONFIG_FILE ([8c57025](https://github.com/bartventer/dotfiles/commit/8c570252ee009271a9a8257b6e780db54c40b2c3))
* **install.sh:** correct shellcheck formatting ([cf0c303](https://github.com/bartventer/dotfiles/commit/cf0c3033a1bffe3d68c8668b61310579f4cc322a))
* **install.sh:** correct source path in `create_symlink` function ([e8f675b](https://github.com/bartventer/dotfiles/commit/e8f675b4f27de8e18969353a7b2fe2574245aee7))
* **install.sh:** correct the Homebrew package installation ([144fa31](https://github.com/bartventer/dotfiles/commit/144fa316ef7e493810c425ca846458f6e290a37d))
* **install.sh:** handle package installation for Homebrew correctly ([e257e45](https://github.com/bartventer/dotfiles/commit/e257e45ef5b4ae18ec8ba2965b028261a9f58f30))
* **install.sh:** modify brew package installation in install.sh ([4fb271d](https://github.com/bartventer/dotfiles/commit/4fb271db67585f6ed9243f62cae22200e7462855))
* **install.sh:** Update `create_symlink` function for cross-platform compatibility ([c882f4c](https://github.com/bartventer/dotfiles/commit/c882f4ce80a1355946437a4eb42c4cd2f7fa4e5c))
* **install.sh:** update `run_sudo_cmd` to handle `dnf check-update` exit code ([8e632a1](https://github.com/bartventer/dotfiles/commit/8e632a17d38f4e3e6c27b1ba7d9bde48900cf667))
* **install.sh:** Update default values for OH_MY_ZSH_CUSTOM_THEME_REPO_DEFAULT and FONT_NAME ([340cd08](https://github.com/bartventer/dotfiles/commit/340cd08800177bacb8b65938f7e41c6b51aaab5b))
* **install.sh:** update relative_paths population for compatibility with bash and zsh ([1c75cba](https://github.com/bartventer/dotfiles/commit/1c75cbab97a2a86a923c9ad7ddbf4016d835a04d))


### Features

* **install.sh:** Add Neovim configuration to config.json and parse into configure_neovim ([967443f](https://github.com/bartventer/dotfiles/commit/967443ff2c535fdb5df5845d7e69af1782b36770))
* Add Makefile for automating local act runner testing ([e203d0f](https://github.com/bartventer/dotfiles/commit/e203d0fb0488b8fd383bde3c28961b17b630ba4e))
* **install.sh:** Refactor data structures and configuration handling ([30e134a](https://github.com/bartventer/dotfiles/commit/30e134a875deb09370077ae7399b77fff3a81c30))
* **install.sh:** update -l option and refactor code ([2e8f11c](https://github.com/bartventer/dotfiles/commit/2e8f11c60e893ab52a10fc56fbd8277621c5d1b8))

# [3.4.0](https://github.com/bartventer/dotfiles/compare/v3.3.0...v3.4.0) (2024-03-11)


### Bug Fixes

* **init.sh:** add CI runner compatibility ([843d595](https://github.com/bartventer/dotfiles/commit/843d5954d50de7990fd62c687e252a390bbb583f))


### Features

* **ci.yml:** add glibc-all-langpacks installation for Fedora in GitHub Actions ([0bd46c7](https://github.com/bartventer/dotfiles/commit/0bd46c737cb2b9a13df20b7453867d9b5dfef346))
* **init.sh:** add macOS compatibility for script directory resolution ([8064935](https://github.com/bartventer/dotfiles/commit/8064935431818dfa204367989e435954395d6226))
* **log.sh:** enhance compatibility with both Bash and Zsh ([bb021c4](https://github.com/bartventer/dotfiles/commit/bb021c48b3513c697b8f6eda96b30e178e37d933))

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
