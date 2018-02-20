# kubeaware

A simple Kubernetes context awareness helper for bash

## usage
```
Usage: kube[un]aware [-g | --global] [-h | --help]

With no arguments, turn on/off kubeaware for this shell instance instance (default).

  -g --global  turn on kube-ps1 status globally
  -h --help    print this message
```

## installation
```
source kubeaware.sh
export PS1="[your prompt] \$(kubeaware)$" # The output from the function `kubeaware` will have a whitespace at the end.
```

Include this in your `~/.bashrc` to load each time you start a new shell

## how it works

When kubeaware.sh is sourced, mainly two things happen:
- You load a set of helper functions, most importantly `kubeaware` which is used in your `$PS1` environment variable
- The environment variable `$PROMPT_COMMAND` is patched with the function that gets the context info from Kubernetes. 

The function(s) included in `$PROMPT_COMMAND` is executed each time your shell runs a command.

The function included by kubeaware will fetch the information from the `KUBECONFIG` file (via `kubectl config`). This will only happen if `KUBECONFIG` has changed since last time it was checked.

## acknowledgements

This was heavily inspired by https://github.com/jonmosco/kube-ps1, and does currently just contain a subset of the features
