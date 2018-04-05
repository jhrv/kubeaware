# kubeaware

A simpler Kubernetes context awareness helper for bash and zsh

Complements the [kubectx and kubens tools](https://github.com/ahmetb/kubectx) by [ahmetb](https://github.com/ahmetb)

## Usage

![usage_demo](img/usage.gif)

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
export PS1="[your prompt] \$(kubeaware_prompt) $"
```

![installation_demo](img/installation.gif)

### Zsh
```
source kubeaware.sh
PROMPT='$(kubeaware_prompt) '$PROMPT
```


Include this in your `~/.bashrc` or `~/.zshrc`to load each time you start a new shell

## How it works

When kubeaware.sh is sourced, mainly two things happen:
- You load a set of helper functions, most importantly `kubeaware` which is used in your `$PS1` environment variable
- The environment variable `$PROMPT_COMMAND` in bash is patched with the function that gets the context info from Kubernetes. For ZSH the functionality is added via add-zsh-hook precmd.

The function(s) included in `$PROMPT_COMMAND` is executed each time your shell runs a command.

The function included by kubeaware will fetch the information from the `KUBECONFIG` file (via `kubectl config`). This will only happen if `KUBECONFIG` has changed since last time it was checked.

## Acknowledgements

Heavily inspired by [kube-ps1](https://github.com/jonmosco/kube-ps1) by [jonmosco](https://github.com/jonmosco), and aims to contain only a subset of the features

## Contributors
- [Frode Sundby](https://github.com/frodesundby)
- [Vegar Sechmann Molvig](https://github.com/VegarM)

## Known issues

Has not been tested versions of bash < 4.x, so there might be compatability issues if you are running an older version
