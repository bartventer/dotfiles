#!/bin/sh

run_sudo_cmd() {
    run_cmd() {
        if [ "$1" = "dnf check-update"* ]; then
            # dnf check-update returns a non-zero exit code when updates are available.
            # This is expected behavior and not an error. However, it can cause issues
            # if you're using set -e or set -o errexit in your script, which cause the
            # script to exit when any command returns a non-zero exit code. To handle this,
            # we ignore the exit code of dnf check-update.
            eval "$1" || true
        else
            eval "$1"
        fi
    }

    if [ "$CI" = "true" ]; then
        run_cmd "$1"
    else
        if command -v bash >/dev/null 2>&1; then
            sudo -E bash -c "run_cmd() { if [ \"\$1\" = \"dnf check-update\"* ]; then eval \"\$1\" || true; else eval \"\$1\"; fi; }; declare -f run_cmd > /dev/null; run_cmd '$1'"
        else
            sudo -E sh -c "run_cmd() { if [ \"\$1\" = \"dnf check-update\"* ]; then eval \"\$1\" || true; else eval \"\$1\"; fi; }; declare -f run_cmd > /dev/null; run_cmd '$1'"
        fi
    fi
}