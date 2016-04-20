#!/bin/bash
# Usage:
#   If you want to activate the work related features, create a '.at-work' file in home folder.
#   If you want to include additional configs, and do not version them, create a ~/.bash_extended_profile file and put them there.

# TO DO list:
# - Improve TAB compeltion:
#   - http://stackoverflow.com/questions/10942919/customize-tab-completion-in-shell
#   - http://superuser.com/questions/289539/custom-bash-tab-completion
# - use peco to easily merge branches, confirm after selection.
# - Add an easy way to do git stash save -u "Tests for Matrix 1.0".
# - Move at-wrok comands to a separate private file to avoid showing any confidentail things at all.

missing=()

grey=$(tput setaf 0)  # In fact is black
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
bold=$(tput bold)
reset=$(tput sgr0)

HISTSIZE=5000
export HISTCONTROL=ignoredups:erasedups

alias ..='cd ..'
alias grep='grep --color=always'

if [ "$(uname)" == "Darwin" ]; then
  export CLICOLOR=1
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  alias ls="ls --color=auto"
else
  missing+=("LS coloring")
fi
alias l='ls -CF'
alias la='ls -a'
alias ll='ls -l'
# Grep Recursive
alias gr='grep -RnIf /dev/stdin . <<<'

# Find: look for files or directories by name.
#   $1: name/patter(bash).
#   $2: optional root path.
function ffind {
  if [ "$2" ]; then
    find "$2" -name "$1"
  else
    find . -name "$1"
  fi
}

# Ignore case completition.
bind "set completion-ignore-case on"
# Displays all possibilities with only one TAB press.
bind "set show-all-if-ambiguous on"

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
else
  missing+=("Bash completion")
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# GIT
alias gc="git commit"

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
else
  missing+=("git-completition")
fi

if [ -f ~/.git-prompt.sh ]; then
  source ~/.git-prompt.sh
else
  missing+=("git-prompt")
fi

function mergeXcodeProject {
  projectfile=`find -d . -name 'project.pbxproj'`
  projectdir=`echo *.xcodeproj`
  projectfile="${projectdir}/project.pbxproj"
  tempfile="${projectdir}/project.pbxproj.temp"
  savefile="${projectdir}/project.pbxproj.original"
  cat $projectfile | grep -v "<<<<<<< HEAD" | grep -v "=======" | grep -v "^>>>>>>> " > $tempfile
  cp $projectfile $savefile
  mv $tempfile $projectfile
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Prompt
command -v __git_ps1 >/dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
    PS1='\[$green$bold\]\u\[$reset\]:\[$blue$bold\]\w\[$grey\]$(__git_ps1 " %s")\[$reset\]\$ '
else
    PS1='\[$green$bold\]\u\[$reset\]:\[$blue$bold\]\w\[$reset\]\$ '
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Optional Homebrew stuff
export PATH=/usr/local/sbin:$PATH

command -v brew >/dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
  if [ -f `brew --repository`/Library/Contributions/brew_bash_completion.sh ]; then
    . `brew --repository`/Library/Contributions/brew_bash_completion.sh
  else
    missing+=("brew bash completion")
  fi
  if [ -f `brew --prefix`/etc/bash_completion.d/vagrant ]; then
    source `brew --prefix`/etc/bash_completion.d/vagrant
  else
    missing+=("brew vagrant completion")
  fi
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# DEPRECATED: Stuff used at work
# In order to avoid bash environment pollution, this is not included unless a '.at-work' file exists in home folder.
# TODO: replace repeated commands by a ignore case aliases, couldn't get that working right now.
if [ -f ~/.at-work ]; then

  # Iats Switch: Easily exchange between local branches.
  function iswitch {
    #  iatsSwitch `iatsListBranches | cut -d"/" -f 2 | peco`
    if [ "$#" -eq 0 ]; then
      target=`git branch | awk -F ' +' '! /\(no branch\)/ {print $2}' | peco`
      if [ "$target" ]; then
        iatsSwitch "$target"
      fi
    else
      iatsSwitch "$@"
    fi
  }

  function iListTests {
    vim `find . -name "*unit.cpp" | peco`
  }

  function ideleteLocalBranch {
    # TODO: remove master from the list.
    # TODO: maybe allow the user to delete it remotely:
    #   git push origin --delete REMOTE_BRANCH_TO_DELETE
    target=`git branch | awk -F ' +' '! /\(no branch\)/ {print $2}' | peco`
    if [ "$target" == "" ]; then
      return
    fi
    REPLY=""
    while [[ ! $REPLY =~ ^[YyNn]$ ]]
    do
      read -p "Sure you want to delete $target ? (Y/n)" -n 1 -r
      echo
    done
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      git branch -D "$target"
    fi
  }

else
  missing+=(".at-work")
fi

# Show missing files
if [ ! ${#missing[@]} -eq 0 ]; then
  output=$(printf ", %s" "${missing[@]}")
  output=${output:1}
  echo "Missing: ${output[*]}"
fi

# Import extended config
if [ -f ~/.bash_extended_profile ]; then
  . ~/.bash_extended_profile
fi

