# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="fino-time-bug"
# ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "fino-time-bug" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### oh-my-posh themes
# export THEME="emodipt-extend.omp.json"
# export THEME="craver.omp.json"
# export THEME="spaceship.omp.json"
export THEME="robbyrussell.omp.json"
# export THEME="json.omp.json"
# export THEME="sim-web.omp.json"
# export THEME="quick-term.omp.json"
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/.poshthemes/$THEME)"

# Created by `pipx` on 2024-07-25 07:21:09
export PATH="$PATH:/home/efo/.local/bin"


# ------------------------------ FZF ------------------------------------ #

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# source ~/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' | xargs nvim"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}


# ----------------------------- THE FUCK ----------------------------- #
# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)


# ----------------------------- KEY BINDINGS ----------------------------- #
# SPELLING ALIASES

# NAVIGATION ALIASES
alias notes="cd $HOME/notes ; lsd"
alias coding="cd $HOME/coding ; lsd"
alias metu="cd $HOME/metu/4th YEAR/1st SEMESTER ; lsd"
alias config="cd $HOME/.config ; lsd"
alias usb="cd /run/media/efo ; lsd"

# SHORTCUT ALIASES
# devour for window swallowing
alias zathura="devour zathura" # pdf
alias okular="devour okular" # pdf
alias mpv="devour mpv" # video
alias vlc="devour vlc" # video
alias sxiv="devour sxiv" # image
alias fm="devour dolphin" # file manager gui
alias cam="devour guvcview"
alias thonny="devour thonny"
# alias jupyter="firefox ; devour jupyter-notebook"

alias update="sudo pacman -Syu"
# alias logout_="loginctl terminate-user efo"
alias install="yay -S --noconfirm"
alias uninstall="yay -R"
alias lock="i3lock --color 000000" #"slock" # i3lock or slock
alias brightness="brightnessctl"
alias battery="acpi"

alias wp="nitrogen"
# alias pip="pipx"
alias lf="yazi"
alias disk="pydf | head -n 2"
alias wifi="nmtui"
alias bth="blueberry" # bluetooth
alias help="tldr"
alias wiztree="ncdu"
alias cal="gcalcli calw"
alias gcal="gcalcli"
alias weather="curl v2d.wttr.in/Ankara"
alias clock="tty-clock -C 1 -b -u -s"
alias torrent="nyaa" # https://github.com/Beastwick18/nyaa
alias edex-ui="cd /home/efo/Desktop/Apps ; ./eDEX-UI-Linux-x86_64.AppImage"
alias paraview="cd /home/efo/Desktop/Apps/ParaView-5.13.1/bin ; devour ./paraview ; cd -"
alias godot="cd /home/efo/Desktop/Apps/ ; devour ./Godot_v3.6-stable_x11.64 ; cd -"
alias anydesk="cd /home/efo/Desktop/Apps/anydesk-6.4.0-amd64/anydesk-6.4.0 ; devour ./anydesk ; cd -"
alias pdf="okular"
alias cv="cd ~/Documents ; okular cv.pdf ; cd -"
alias zshconf="nvim ~/.zshrc"
alias zshsrc="source ~/.zshrc"
# alias t="todo.sh" # https://github.com/todotxt/todo.txt-cli/blob/master/USAGE.md
# alias tls="todo.sh ls"
# alias tadd="todo.sh add"
# alias tdel="todo.sh del"
# alias todo="geek-life"
# alias todo="nvim ~/notes/TODO.todo"
alias yt="firefox youtube.com"
alias sp="ncspot"
alias clitools="bat ~/coding/cli-tools.txt"
alias monitor="arandr" # multiple monitor settings
alias vol-mixer="pavucontrol" # gui app for speaker/mic related stuff

alias anime="ani-cli"
alias manga="manga-cli"
alias atari="cd ~/Desktop/Games/ROMs ; plastic_tui"

alias ytd-mp3="yt-dlp -i -x --audio-format mp3"

alias c="clear"
# alias neo="neofetch"
alias n="fastfetch"
# alias t="tmux"
# alias v="nvim"
alias e="exit"
alias v="fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim" # pane-window works in tmux
alias l="lsd"
alias py="python3"
alias vi="nvim"

# finds all files recursively and sorts by last modification, ignore hidden files
alias lastmod='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

# Docker
alias pandoc='docker run --rm --volume "$(pwd):/data" --user $(id -u):$(id -g) pandoc/latex'
alias docker461="sudo systemctl start docker; docker container exec -it me461_labs /bin/zsh"
alias kalidocker="cd /home/efo/coding/docker-related/kalilinux-docker; docker-compose up"


function prod ()
{
	firefox calendar.google.com
	firefox app.todoist.com/app/inbox
	firefox notion.so
	firefox horde.metu.edu.tr
	firefox https://odtuclass2024f.metu.edu.tr/my/
	firefox https://drive.google.com/drive/home
}

alias cd="z"
eval "$(zoxide init zsh)"

alias mkdir="mkdir -pv"
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias ls="lsd"
# alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias tree="eza --tree --level=3"

# GIT ALIASES
alias g="git"
alias gc="git commit -m "
alias ga="git add "
alias gpu="git push -u origin "
alias lg="lazygit"

# -----------------------Environment Variables----------------------------------- #
set -o vi
export EDITOR=nvim
export BROWSER="firefox"
# export TERM="tmux-256color"
export TERM="xterm-256color"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#009999"

# PYTHON ENVIRONMENTS
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

setxkbmap -option caps:swapescape
