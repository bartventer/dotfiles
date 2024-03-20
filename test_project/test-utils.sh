#!/bin/bash

USERNAME=${1:-vscode}
FAILED=()

echoStderr()
{
    echo "$@" 1>&2
}

check() {
    LABEL=$1
    CONDITION=$2
    echo -e "\n🧪 Testing $LABEL"
    if eval "$CONDITION"; then 
        echo "✅  Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

checkCommon() {
    check "OS" "[[ $(uname) == 'Linux' || $(uname) == 'Darwin' ]]"
    check "User" "[[ $(whoami) == $USERNAME ]]"
}

reportResults() {
    if [ ${#FAILED[@]} -ne 0 ]; then
        echoStderr -e "\n💥  Failed tests: ${FAILED[*]}"
        exit 1
    else 
        echo -e "\n💯  All passed!"
        exit 0
    fi
}