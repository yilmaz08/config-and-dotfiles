alias py="python3"
alias pong="ping archlinux.org"
alias trm="trash-put"

alias adamimprojevarmiya="cd ~/Projects/"

# clear
alias c="clear"
alias clr="clear"
alias cls="clear"

# fetch
alias ff="fastfetch"
alias fetch="ff -c examples/13"

# ls
alias ls="/usr/bin/exa"
alias l="ls -l"
alias la="ls -la"

alias r="ranger"
alias e="nvim"
alias se="sudo nvim"

# aur helper
alias aur="yay"
alias S="aur -S"
alias Ss="aur -Ss"
alias Si="aur -Si"
alias Syu="aur -Syu"
alias Syyu="aur -Syyu"
alias R="aur -R"
alias Rcns="aur -Rcns"
alias Q="aur -Q"
alias Qe="aur -Qe"
alias Su="aur -Su"
alias Fy="aur -Fy"
alias F="aur -F"

# systemctl
alias sstart="sudo systemctl start"
alias srestart="sudo systemctl restart"
alias sreload="sudo systemctl reload"
alias sstop="sudo systemctl stop"
alias senable="sudo systemctl enable"
alias sdisable="sudo systemctl disable"
alias sstatus="sudo systemctl status"

# bluetoothctl
alias btrust="bluetoothctl trust"
alias bpair="bluetoothctl pair"
alias bconn="bluetoothctl connect"
alias bdisconn="bluetoothctl disconnect"
alias boff="bluetoothctl power off"
alias bon="bluetoothctl power on"

set fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_title
    echo (fish_prompt_pwd_dir_length=0 prompt_pwd);
end

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd
    builtin pwd -L
end

# A copy of fish's internal cd function. This makes it possible to use
# `alias cd=z` without causing an infinite loop.
if ! builtin functions --query __zoxide_cd_internal
    if builtin functions --query cd
        builtin functions --copy cd __zoxide_cd_internal
    else
        alias __zoxide_cd_internal='builtin cd'
    end
end

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd
    __zoxide_cd_internal $argv
end

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
function __zoxide_hook --on-variable PWD
    test -z "$fish_private_mode"
    and command zoxide add -- (__zoxide_pwd)
end

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

if test -z $__zoxide_z_prefix
    set __zoxide_z_prefix 'z!'
end
set __zoxide_z_prefix_regex ^(string escape --style=regex $__zoxide_z_prefix)

# Jump to a directory using only keywords.
function __zoxide_z
    set -l argc (count $argv)
    if test $argc -eq 0
        __zoxide_cd $HOME
    else if test "$argv" = -
        __zoxide_cd -
    else if test $argc -eq 1 -a -d $argv[1]
        __zoxide_cd $argv[1]
    else if set -l result (string replace --regex $__zoxide_z_prefix_regex '' $argv[-1]); and test -n $result
        __zoxide_cd $result
    else
        set -l result (command zoxide query --exclude (__zoxide_pwd) -- $argv)
        and __zoxide_cd $result
    end
end

# Completions.
function __zoxide_z_complete
    set -l tokens (commandline --current-process --tokenize)
    set -l curr_tokens (commandline --cut-at-cursor --current-process --tokenize)

    if test (count $tokens) -le 2 -a (count $curr_tokens) -eq 1
        # If there are < 2 arguments, use `cd` completions.
        complete --do-complete "'' "(commandline --cut-at-cursor --current-token) | string match --regex '.*/$'
    else if test (count $tokens) -eq (count $curr_tokens); and ! string match --quiet --regex $__zoxide_z_prefix_regex. $tokens[-1]
        # If the last argument is empty and the one before doesn't start with
        # $__zoxide_z_prefix, use interactive selection.
        set -l query $tokens[2..-1]
        set -l result (zoxide query --exclude (__zoxide_pwd) --interactive -- $query)
        and echo $__zoxide_z_prefix$result
        commandline --function repaint
    end
end
complete --command __zoxide_z --no-files --arguments '(__zoxide_z_complete)'

# Jump to a directory using interactive search.
function __zoxide_zi
    set -l result (command zoxide query --interactive -- $argv)
    and __zoxide_cd $result
end

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

abbr --erase z &>/dev/null
alias z=__zoxide_z
alias cd=__zoxide_z

abbr --erase zi &>/dev/null
alias zi=__zoxide_zi
alias cdi=__zoxide_zi

function ranger
 	set tempfile (mktemp -t tmp.XXXXXX)
	command ranger --choosedir=$tempfile $argv
	set return_value $status

	if test -s $tempfile
		set ranger_pwd (cat $tempfile)
		if test -n $ranger_pwd -a -d $ranger_pwd
			builtin cd -- $ranger_pwd
		end
	end

	command rm -f -- $tempfile
	return $return_value
end

zoxide init fish | source
starship init fish | source
