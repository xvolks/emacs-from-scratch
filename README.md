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

**DO NOT USE THIS: IT INSTALLS A DEPRECATED VERSION** (as 2026-10-08, time of writting)
```emacs
    M-x dap-codelldb-setup
```

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


