
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

ZSH_THEME="powerlevel10k/powerlevel10k"
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

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
plugins=(git)

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
#
# Setting java 25 in path
export PATH="/opt/homebrew/opt/openjdk@25/bin:$PATH"
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias pinst="pip install -r requirements.txt"
alias aenv="source env/bin/activate"
alias dcup="docker-compose up"
alias dcupb="docker-compose up --build"
alias home="cd ~/"
repos() {
    cd ~/git/"$1" || { echo "Directory not found"; return 1; }
    while true; do
        ls -d */ | nl -n ln | pr -w "$(tput cols)" -5
        echo -n "Choose directory('e' to exit, 'b' to go back): "
        read dirnum
        if [ "$dirnum" = "e" ]; then
            break
        fi
        if [ "$dirnum" = "b" ]; then
          cd ..
        fi
        cd "$(ls -d */ | sed -n "${dirnum}p" | xargs)"
        if test -d .git; then
          "Found git repo, exiting..."
          break
        fi
    done
}
alias entra_at="nohup ~/git/github/docker-azurecli-credentials/target/release/docker-azurecli-credentials >/dev/null 2>&1 &"
alias entra_at_pid="pgrep -f ~/git/github/docker-azurecli-credentials/target/release/docker-azurecli-credentials"
alias bv_login="az login --tenant df36c901-5387-4961-b095-1ec572ed056a"
alias pg_access_token="az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv | pbcopy"
alias g_run="./gradlew run --configuration-cache"
alias nvim_cache_clear="rm -rf ~/.cache/nvim ~/.local/state/nvim ~/.local/share/nvim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Node version manager stuff

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && \. "/usr/local/opt/nvm/etc/bash_completion"
source ~/.nvm/nvm.sh

# Source cargo env to add refs to environment
source ~/.cargo/env

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export BV_EXTERNAL_USERNAME="group_bv_developers"
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"

runapp() {
    local app="$1"
    local env_file="./${app}/.env"

    if [[ -z "$app" ]]; then
      echo "usage: runapp <app-folder>"
      return 1
    fi

    if [[ ! -f "$env_file" ]]; then
      echo "missing env file: $env_file"
      return 1
    fi

    (
      set -a
      source "$env_file"
      set +a
      ./gradlew ":${app}:run"
    )
  }

 open_test_report() {
    local app="$1"
    local path

    if [[ -n "$app" ]]; then
      path="$PWD/$app/build/reports/tests/test/index.html"
    else
      path="$PWD/build/reports/tests/test/index.html"
    fi

    if [[ ! -f "$path" ]]; then
      echo "Test report not found: $path"
      return 1
    fi

    /usr/bin/open "$path"
  }
