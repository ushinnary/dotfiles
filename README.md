# dotfiles

My config for Rust/JS/TS development
WIP

## Packages to install:

### Rust
run 
```
./setup-rust.sh
```
### NVM

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
```

### ZSH

```
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

- AutoSuggestions:
  ```
  sudo git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  ```
- Syntax:
  ```
  sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ```

### Language servers:

- Typescript

```
npm install -g typescript-language-server typescript
```

- CSS ?

```
npm install -g vscode-css-languageserver-bin
```

- Vue

```
npm install vls -g
```

- TOML
  `https://taplo.tamasfe.dev/cli/installation/binary.html`
- LUA
  `https://github.com/sumneko/lua-language-server/releases`

### Formatters

- LUA

```
cargo install stylua
```

### Packer:

```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

### Font

- Coding:
`https://www.programmingfonts.org/#hermit`
`https://github.com/subframe7536/Maple-font`

- System:
  `QuickSand`
  `https://fonts.google.com/specimen/Comfortaa?category=Display`
  `https://fonts.google.com/specimen/Poiret+One?category=Display`

```
https://www.nerdfonts.com/font-downloads
```
