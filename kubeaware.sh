#!/bin/bash

[[ -n $DEBUG ]] && set -x

KUBECTL=kubectl
KUBE_SYMBOL='⎈'
DEFAULT_NAMESPACE_ALIAS="~"
KUBEDIR="${HOME}/.kube"
KUBEAWARE_GLOBAL_ENABLED_FILE="${KUBEDIR}/.kubeaware_enabled"

mkdir -p "${KUBEDIR}"

kubeaware_prompt() {
  if [[ ( -f "${KUBEAWARE_GLOBAL_ENABLED_FILE}" || -n ${KUBEAWARE} ) && -z "${KUBEUNAWARE}" ]]; then
    echo -e "[${PRE_SYMBOL}${KUBE_SYMBOL}${POST_SYMBOL}${CURRENT_CTX}:${CURRENT_NS}] "
  fi
}

kubeaware() {
  if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    print_help
    return
  fi

  if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
    touch "${KUBEAWARE_GLOBAL_ENABLED_FILE}"
  else
    export KUBEAWARE="true"
    unset KUBEUNAWARE
  fi
}

kubeunaware() {
  if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    print_help
    return
  fi

  if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
    rm -f "${KUBEAWARE_GLOBAL_ENABLED_FILE}"
  fi

  export KUBEUNAWARE="true"
}

sync_kubeaware() {
  # only update context if it's changed
  KUBECONFIG_FILES=${KUBECONFIG:-"${KUBEDIR}/config"}

  # check for changes in all kubeconfig files
  local IFS="$(':' read -ra CONFIG <<< "$KUBECONFIG_FILES")"
  KUBECONFIG_CONTENT="$(for element in "${CONFIG[@]}"; do cat "$element"; done)"
  
  local CURR_HASH=$(echo ${KUBECONFIG_CONTENT} | shasum | cut -d" " -f1)

  if [[ ${CURR_HASH} != ${LAST_HASH} ]]; then
    get_current_namespace
    get_current_context
    export LAST_HASH=${CURR_HASH}
  fi
}

get_current_namespace() {
  CURRENT_NS="$(${KUBECTL} config view --minify --output 'jsonpath={..namespace}' 2> /dev/null)"

  if [[ ${CURRENT_NS} == "default" ]]; then
    unset CURRENT_NS
  fi

  CURRENT_NS="${CURRENT_NS:-${DEFAULT_NAMESPACE_ALIAS}}"
}

get_current_context() {
  CURRENT_CTX="$(${KUBECTL} config current-context 2>/dev/null)"
  CURRENT_CTX="${CURRENT_CTX:-n/a}"
}

print_help() {
  cat <<EOF
kube[un]aware

Usage: kubeaware [-g | --global] [-h | --help]

With no arguments, turn on/off kubeaware for this shell instance instance (default).

  -g --global  turn on kubeawareness globally
  -h --help    print this message

EOF
}

main() {
  get_current_context
  get_current_namespace
  if [ "${ZSH_VERSION}" ]; then
    PRE_SYMBOL="%{$fg[blue]%}"
    POST_SYMBOL="%{$fg[white]%} "
    setopt PROMPT_SUBST
    autoload -U add-zsh-hook
    add-zsh-hook precmd sync_kubeaware
  elif [ "${BASH_VERSION}" ]; then
    PRE_SYMBOL='\001\033[34m\002'
    POST_SYMBOL='\001\033[39m\002 '
    PROMPT_COMMAND="sync_kubeaware;${PROMPT_COMMAND}"
  fi
}

main "$@"
