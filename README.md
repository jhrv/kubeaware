# Kubeaware

A simple Kubernetes context awareness helper for bash and zsh

## Usage
```
Usage: kube[un]aware [-g | --global] [-h | --help]

With no arguments, turn on/off kubeaware for this shell instance instance (default).

  -g --global  turn on kubeawareness globally
  -h --help    print this message
```

## Installation
### Bash
```
source kubeaware.sh
export PS1="[your prompt] \$(kubeaware_prompt)$" # The output from the function `kubeaware_prompt` will have a whitespace at the end.
```
### Zsh
```
source kubeaware.sh
PROMPT='$(kubeaware_prompt)'$PROMPT
```


Include this in your `~/.bashrc` or `~/.zshrc`to load each time you start a new shell

## How it works

When kubeaware.sh is sourced, mainly two things happen:
- You load a set of helper functions, most importantly `kubeaware` which is used in your `$PS1` environment variable
- The environment variable `$PROMPT_COMMAND` in bash is patched with the function that gets the context info from Kubernetes. For ZSH the functionality is added via add-zsh-hook precmd.

The function(s) included in `$PROMPT_COMMAND` is executed each time your shell runs a command.

The function included by kubeaware will fetch the information from the `KUBECONFIG` file (via `kubectl config`). This will only happen if `KUBECONFIG` has changed since last time it was checked.

## Acknowledgements

This was heavily inspired by https://github.com/jonmosco/kube-ps1, and does currently just contain a subset of the features

## Contributors
- Frode Sundby ([@frodesundby](https://github.com/frodesundby))
