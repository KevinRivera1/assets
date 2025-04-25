#!/usr/bin/env bash
# setup_wsl_dev_env.sh
# Automates the installation and configuration of a modern development environment on Windows with WSL2 + Ubuntu.

set -euo pipefail
IFS=$'\n\t'

# Colors for output
RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"

echo -e "${BLUE}=== WSL2 + Ubuntu Dev Environment Setup ===${RESET}"

# Detect if running inside WSL
if grep -qi microsoft /proc/version; then
  echo -e "${GREEN}Running inside WSL. Skipping WSL installation...${RESET}"
else
  echo -e "${YELLOW}Installing WSL2 and Ubuntu from Windows...${RESET}"
  powershell.exe -NoProfile -Command "wsl --install; wsl --set-default-version 2; wsl --install -d Ubuntu"
  echo -e "${GREEN}WSL2 + Ubuntu instalado. Por favor reinicia tu equipo y ejecuta este script dentro de WSL nuevamente.${RESET}"
  exit 0
fi

# Prompt for user details
read -rp "Ingrese su email (ej: tu_email@ejemplo.com): " EMAIL
read -rp "Ingrese su GitHub username (exacto): " GITHUB_USER
KEY_NAME="personal"

# 1️⃣ Actualizar e instalar dependencias
echo -e "${BLUE}-> Actualizando paquetes APT...${RESET}"
sudo apt update && sudo apt upgrade -y

# Agregar PPA de Git
sudo apt install -y software-properties-common apt-transport-https curl git gnupg2 lsb-release
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update && sudo apt upgrade -y

# 2️⃣ Instalar Zsh y Oh My Zsh + plugins
echo -e "${BLUE}-> Instalando Zsh y Oh My Zsh...${RESET}"
sudo apt install -y zsh

# Instalar Oh My Zsh de forma no interactiva
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Plugins
export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete"

# Update ~/.zshrc plugins list
echo -e "${BLUE}-> Agregando plugins a ~/.zshrc...${RESET}"
if ! grep -q "plugins=(" ~/.zshrc; then
  sed -i "/^export ZSH=/a plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)" ~/.zshrc
else
  sed -i "s/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)/" ~/.zshrc
fi

# Cambiar shell por defecto
echo -e "${BLUE}-> Cambiando shell por defecto a Zsh...${RESET}"
chsh -s "$(which zsh)"

# 3️⃣ Instalar Homebrew y herramientas clave
echo -e "${BLUE}-> Instalando Homebrew...${RESET}"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo -e "${BLUE}-> Instalando utilidades: starship, lazygit, fnm, zoxide, fzf...${RESET}"
brew install starship lazygit fnm zoxide fzf

echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo 'eval "$(fnm env --use-on-cd --shell zsh)"' >> ~/.zshrc

echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

echo 'eval "$(fzf --completion --key-bindings)"' >> ~/.zshrc

# 4️⃣ Reload Zsh config y verificar versiones
echo -e "${BLUE}-> Recargando configuración de Zsh...${RESET}"
source ~/.zshrc

echo -e "${BLUE}-> Versiones instaladas:${RESET}"
zsh --version && git --version && brew --version && node --version || true

# 5️⃣ Configurar SSH y Git
mkdir -p ~/.ssh ~/.config/git
chmod 700 ~/.ssh

echo -e "${BLUE}-> Generando par de llaves SSH ed25519...${RESET}"
ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/$KEY_NAME -N ""

echo -e "${BLUE}-> Iniciando ssh-agent y agregando clave...${RESET}"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/$KEY_NAME

# ~/.ssh/config
echo -e "${BLUE}-> Creando ~/.ssh/config...${RESET}"
cat <<EOF > ~/.ssh/config
# Configuración para GitHub personal
Host gh-personaldev
  HostName github.com
  User git
  IdentityFile ~/.ssh/$KEY_NAME
EOF
chmod 600 ~/.ssh/config

# allowed_signers para commit signing
PUBKEY=$(cat ~/.ssh/$KEY_NAME.pub)
echo "$EMAIL ssh-ed25519 $PUBKEY" > ~/.config/git/allowed_signers
chmod 600 ~/.config/git/allowed_signers

# Git global config
echo -e "${BLUE}-> Configurando Git global...${RESET}"
git config --global user.name "$GITHUB_USER"
git config --global user.email "$EMAIL"
git config --global user.signingkey ~/.ssh/$KEY_NAME.pub
git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.ssh.allowedsignersfile ~/.config/git/allowed_signers

# 6️⃣ Limpieza final
echo -e "${BLUE}-> Limpiando caché de APT y Homebrew...${RESET}"
sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
nbrew cleanup -n && brew cleanup && brew cleanup -s && brew autoremove || true

# Fin
echo -e "${GREEN}=== ¡Instalación completa! Reinicia tu terminal y ¡a programar! 🎉${RESET}"
