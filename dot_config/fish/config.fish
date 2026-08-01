source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Disable the fastfetch greeting from cachyos-fish-config
function fish_greeting
end

# ---- Port of my oh-my-zsh setup (~/.zshrc) ----

# vi mode (was: bindkey -v)
fish_vi_key_bindings
# restore ! and $ history expansion (cachyos only binds these for default mode)
bind -M insert ! __history_previous_command
bind -M insert '$' __history_previous_command_arguments

# fzf key bindings: Ctrl+T files, Ctrl+R history, Alt+C cd (was: source ~/.fzf.zsh)
fzf --fish | source

# git aliases from the oh-my-zsh git plugin, as fish abbreviations
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gst 'git status'
abbr -a gd 'git diff'
abbr -a gdc 'git diff --cached'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gb 'git branch'
abbr -a gba 'git branch -a'
abbr -a gm 'git merge'
abbr -a gcl 'git clone'
abbr -a gc 'git commit --verbose'
abbr -a 'gc!' 'git commit --verbose --amend'
abbr -a gca 'git commit --verbose --all'
abbr -a gcm 'git commit --message'
abbr -a gl 'git pull'
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a glg 'git log --stat'
abbr -a glog 'git log --oneline --decorate --graph'
abbr -a glo 'git log --oneline --decorate'
abbr -a gsw 'git switch'
abbr -a gfa 'git fetch --all --prune'
abbr -a grb 'git rebase'
abbr -a grbc 'git rebase --continue'
abbr -a gcp 'git cherry-pick'
abbr -a grm 'git rm'

# git auto-fetch (was: oh-my-zsh git-auto-fetch) - background fetch every 60s
function __git_auto_fetch --on-event fish_prompt
  set -q __git_last_fetch; or set -g __git_last_fetch 0
  if test (date +%s) -ge (math "$__git_last_fetch + 60")
    set -g __git_last_fetch (date +%s)
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
      command git fetch --all --prune >/dev/null 2>&1 &
    end
  end
end

# Add ~/bin (chezmoi) to PATH
fish_add_path ~/bin
