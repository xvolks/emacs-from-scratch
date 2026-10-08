## Original README

[README.org](README.org)

## MacOS Installation

```console
brew install font-jetbrains-mono-nerd-font
brew install emacs-dracula
brew install cmake
brew install libvterm
```

## Some post install
Install a recent codelldb.vsx from [Github](https://github.com/vadimcn/codelldb/releases/):
```bash
d=~/.emacs.d/var/dap/extensions/vscode/codelldb
mkdir -p $d && unzip -o ~/Download/codelldb-darwin-arm64.vsix -d $d
chmod +x $d/extension/adapter/codelldb
xattr -dr com.apple.quarantine $d
```

**DO NOT USE THIS: IT INSTALLS A DEPRECATED VERSION** (as 2026-10-08, time of writing)
```emacs
    M-x dap-codelldb-setup
```

## Multi‑platform configuration (`init-mac-and-linux.el`)

A new file `init-mac-and-linux.el` has been created alongside the original
`init.el`.  It keeps all macOS‑specific behaviour and adds Linux compatibility
for both **x86_64** and **aarch64** architectures.

### What changed for Linux

| Aspect                  | macOS                                          | Linux                                                                 |
|-------------------------|------------------------------------------------|-----------------------------------------------------------------------|
| **Fixed‑pitch font**    | `FiraCode Nerd Font Mono`                      | `FiraCode Nerd Font`                                                  |
| **Variable‑pitch font** | `Arial`                                        | `Cantarell`                                                           |
| **Env inheritance**     | `exec-path-from-shell` enabled                 | Skipped (Emacs inherits env from the terminal by default)             |
| **lldb‑mi path**        | Bundled with CodeLLDB extension                | Bundled first, falls back to `/usr/bin/lldb-mi`                       |
| **Native compilation**  | Needs `MACOSX_DEPLOYMENT_TARGET` in early‑init | Works out‑of‑box (libgccjit required)                                 |

### Usage

As the `init-mac-and-linux.el` was symlinked to `init.el`, nothing spectial todo.
In case of a regression on macOS, one can still start the legacy file with:
```bash
# On macOS
emacs -l init-org.el
```

The companion file `early-init-mac-and-linux.el` handles the macOS‑only
`MACOSX_DEPLOYMENT_TARGET` environment variable; on Linux it’s a no‑op.
This file has also be symlinked to its original name `early-init.el`.

### Linux dependencies

Install the required fonts and tools:

```console
# Debian / Ubuntu
sudo apt install fonts-firacode fonts-cantarell cmake libvterm-dev

# Fedora
sudo dnf install fira-code-fonts cantarell-fonts cmake libvterm

# Arch Linux
sudo pacman -S ttf-fira-code cantarell-fonts cmake libvterm
```

For Rust debugging, install a recent [CodeLLDB release](https://github.com/vadimcn/codelldb/releases/)
and run `M-x dap-codelldb-setup` once.

## Truc bizarre à mettre dans le init.el / init-mac-and-linux.el

_inheritenv_ est une vraie dépendance de _rustic_. Elle devrait s'installer automatiquement, mais vérifiez avec *M-x package-list-packages* et *C-s inheritenv*. Si elle manque, faites *M-x package-install RET inheritenv*

## Raccourcis

| Action                                 | Touche                |
| -------------------------------------- | --------------------- |
| Aller à la définition / références     | M-. / M-?             |
| Renommer / action de code              | C-c C-c r / C-c C-c a |
| Liste d'erreurs Flycheck               | C-c C-c l             |
| Erreur suivante / précédente           | M-n / M-p             |
| Build / Run / Clippy / Tests           | C-c C-c b / R / k / T |
| Test courant                           | C-c C-c t             |
| Redémarrer rust-analyzer               | C-c C-c q             |
| Étendre une macro                      | C-c l e               |
| Débogage : lancer / dernier            | C-c d d / C-c d l     |
| Point d'arrêt / conditionnel           | C-c d t / C-c d c     |
| Pas à pas : next / in / out / continue | C-c d n / s / o / r   |
| Évaluer / watch                        | C-c d x / C-c d w     |
| Menu hydra de débogage                 | C-c d h               |


