## Guía de instalación de entorno de desarrollo en Windows con WSL2

Esta guía paso a paso te ayudará a configurar un entorno de desarrollo moderno en Windows mediante WSL2, Ubuntu y herramientas esenciales. Cada paso incluye su propósito, comandos y recomendaciones para que el proceso sea claro y sencillo.

---

### 📋 Prerrequisitos

- **Windows 10 2004 (build 19041) o superior** / **Windows 11**
- **Virtualización habilitada** en BIOS/UEFI
- Conexión a Internet para descargar componentes
- **Permisos de administrador** en PowerShell o Símbolo del sistema

---

### 1. Instalar WSL2

WSL2 (Windows Subsystem for Linux versión 2) permite ejecutar un kernel Linux real en Windows.

1. Abre **PowerShell** o **CMD** como administrador.
2. Ejecuta:
   ```powershell
   wsl --install                 # Instala WSL y la última distribución por defecto
   wsl --set-default-version 2   # Asegura que use la versión 2
   ```
3. **Reinicia** el equipo cuando se te solicite.

> 💡 _Nota:_ Si ya tenías WSL instalado, solo necesitas asegurarte de la versión y reiniciar.

---

### 2. Instalar y configurar tu distribución Linux (Ubuntu)

1. Verifica las distribuciones disponibles:
   ```powershell
   wsl --list --online          # Muestra distros disponibles
   ```
2. Instala Ubuntu:
   ```powershell
   wsl --install -d Ubuntu      # Descarga e instala Ubuntu
   ```
3. Al finalizar, abre **Windows Terminal**, selecciona **Ubuntu** y crea tu **usuario** (username) y **contraseña**.
4. Actualiza paquetes e instala repositorios adicionales:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo add-apt-repository ppa:git-core/ppa
   sudo apt update && sudo apt upgrade -y
   ```

> 🔒 _Tip de seguridad:_ Utiliza contraseñas fuertes y, de ser posible, gestiona tu SSH con passphrase.

---

### 3. Instalar y configurar una fuente Nerd Font

Las Nerd Fonts incluyen iconos para mejorar la apariencia de tu terminal.

1. Descarga [Mononoki Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) o similar.
2. Instálala en Windows (clic derecho ▶ Installer).
3. En **Windows Terminal**, abre las **Configuraciones**, busca el perfil Ubuntu y selecciona la fuente `Mononoki NF` o la que hayas instalado.

---

### 4. Instalar Zsh y Oh My Zsh

Zsh es un shell potente y personalizable; Oh My Zsh facilita su gestión.

1. Instala Zsh:
   ```bash
   sudo apt install zsh -y
   ```
2. Cambia tu shell por defecto:
   ```bash
   chsh -s $(which zsh)
   ```
3. Cierra y vuelve a abrir la terminal.
4. Instala **Oh My Zsh**:
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```
5. Configura tu tema y plugins editando `~/.zshrc` (ver sección de personalización al final).
   
   ```bash
   # Instala el plugin zsh-autosuggestions:

   git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
   ```

   ```bash
   # Instala el plugin zsh-syntax-highlighting:

   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
   ```

   ```bash
   # Instala el plugin fast-syntax-highlighting:

   git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
   ```

   ```bash
   # Instala el plugin zsh-autocomplete:

   git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
   ```

---

### 5. Instalar Homebrew en Linux (Linuxbrew)

Homebrew facilita la instalación de herramientas adicionales.

1. Ejecuta el instalador oficial:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Añade Homebrew al PATH en tu `~/.zshrc`:
   ```bash
   echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
   source ~/.zshrc
   ```

---

### 6. Instalar herramientas y complementos con Homebrew

Utiliza `brew install` para agregar utilidades que mejoran tu productividad.

- **Starship** (prompt rápido y personalizable):
  ```bash
  brew install starship
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  ```

- **lazygit** (interfaz TUI para Git):
  ```bash
  brew install lazygit
  ```

- **Node Version Manager** (fnm) y entornos Node.js/Bun:
  ```bash
  brew install fnm
  echo 'eval "$(fnm env --multi-zsh)"' >> ~/.zshrc
  fnm install --lts        # Node.js LTS
  fnm install bun          # Bun

  #OJO: Tambien puedes instalar bun con brew
  brew install oven-sh/bun/bun
  ```

- **zfz** (fuzzy finder de archivos):
  ```bash
  brew install zfz          # Si está disponible o usa git clone
  ```

- **zoxide** (mejor navegación de directorios):
  ```bash
  brew install zoxide
  echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
  ```

---

### 7. Personalización final y verificación

1. Abre `~/.zshrc` y revisa:
   - Dentro de tu archivo de configuración `~/.zshrc` y ubica esta sección: `plugins=(git)`. Agrega lo siguiente:
      ```bash
      plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)
      ```
   - Inicialización de starship - fnm - fzf - zoxide
   
      NOTA: Agregar estos paths al final en el archivo `~/.zshrc`:
      ```bash
      # Homebrew path
       BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
       eval "$($BREW_BIN/brew shellenv)"
      # fnm nodejs manager
       eval "$(fnm env --use-on-cd --shell zsh)"
      # starship path
       eval "$(starship init zsh)"
      # fzf path
       eval "$(fzf --zsh)"
      # zoxide path
       eval "$(zoxide init zsh)"
      ```

2. Recarga la configuración:
   ```bash
   source ~/.zshrc
   ```
3. Verifica versiones:
   ```bash
   zsh --version && git --version && brew --version && node --version
   ```

---

### 🛠️ Solución de problemas

- **Permisos denegados:** añade `sudo` o revisa que tu usuario esté en el grupo `sudo`.
- **Comandos no encontrados:** asegúrate de que el PATH esté actualizado (`echo $PATH`).
- **WSL no arranca:** revisa en PowerShell `wsl --status`.

---

¡Con esto ya cuentas con un entorno sólido para desarrollar en Windows con WSL2! Si tienes dudas, revisa la documentación oficial de cada herramienta o consulta foros especializados.

Recuerda configurar tus lllaves ssh