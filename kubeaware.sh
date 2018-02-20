#!/bin/bash

[[ -n $DEBUG ]] && set -x

function _main {
   _init_env
   _get_current_context
   _get_current_namespace
   PROMPT_COMMAND="_sync_kubeaware;${PROMPT_COMMAND}"
}

function _init_env {
    KUBECTL=kubectl
    KUBE_SYMBOL=$'\u2388 '
    DEFAULT_NAMESPACE_ALIAS="~"
    KUBEDIR="${HOME}/.kube"
    KUBECONFIG_FILE=${KUBECONFIG:-"${KUBEDIR}/config"}
    LAST_CHECK_TIMESTAMP_FILE="${KUBEDIR}/.kubeaware_lastcheck"
    KUBEAWARE_GLOBAL_ENABLED_FILE="${KUBEDIR}/.kubeaware_enabled"

    mkdir -p ${KUBEDIR}
}

function kubeaware_ps1 {
    if [[ -f "${KUBEAWARE_GLOBAL_ENABLED_FILE}" && -z "${KUBEUNAWARE}" ]]; then
        echo "[${KUBE_SYMBOL}${CURRENT_CTX}:${CURRENT_NS}] "
    fi
}

function kubeaware {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        print_halp
        return
    fi
    
    if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
        touch ${KUBEAWARE_GLOBAL_ENABLED_FILE}
    else
        unset KUBEUNAWARE
    fi
}

function kubeunaware {
    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        print_halp
        return
    fi

    if [[ "${1}" == "-g" || "${1}" == "--global" ]]; then
        rm -f ${KUBEAWARE_GLOBAL_ENABLED_FILE}
    else
        export KUBEUNAWARE="true"
    fi
}

function _sync_kubeaware {
    # only update context if it's changed
    if [[ $(_get_kubeconfig_last_changed) > $(_get_last_checked) ]]; then
        _get_current_namespace
        _get_current_context
        _set_last_checked
    fi
}

function _get_last_checked {
    if [[ -f ${LAST_CHECK_TIMESTAMP_FILE} ]]; then
        cat ${LAST_CHECK_TIMESTAMP_FILE}
    else
        echo 0 
    fi
}

function _get_kubeconfig_last_changed {
    date -r ${KUBECONFIG_FILE} +%s
}

function _set_last_checked {
    echo $(date +%s) > ${LAST_CHECK_TIMESTAMP_FILE}
}

function _get_current_namespace {
    CURRENT_NS="$(${KUBECTL} config view --minify --output 'jsonpath={..namespace}' 2> /dev/null)"
    if [[ ${CURRENT_NS} == "default" ]]; then
        unset CURRENT_NS
    fi
    CURRENT_NS="${CURRENT_NS:-${DEFAULT_NAMESPACE_ALIAS}}"
}

function _get_current_context {
    CURRENT_CTX="$(${KUBECTL} config current-context 2>/dev/null)"
    CURRENT_CTX="${CURRENT_CTX:-n/a}"
}


function print_halp {
   cat <<EOF 
kube[un]aware

Usage: kubeaware [-g | --global] [-h | --help]

With no arguments, turn on/off kubeaware for this shell instance instance (default).

  -g --global  turn on kube-ps1 status globally
  -h --help    print this message

EOF
}

_main
