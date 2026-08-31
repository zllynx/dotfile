# Dotfiles

个人配置文件，使用 GNU Stow 管理。

## 目录结构

```
dotfile/
├── git/               # Git 配置
├── nvim/              # Neovim 配置
├── tmux/              # Tmux 配置
├── zsh/               # Zsh 配置
├── ghostty/           # Ghostty 终端配置
├── wezterm/           # WezTerm 终端配置
├── aerospace/         # Aerospace 窗口管理器配置
├── ranger/            # Ranger 文件管理器配置
├── zellij/            # Zellij 终端复用器配置
├── starship/          # Starship 提示符配置
├── karabiner/         # Karabiner (macOS) 键盘改键
├── windows/           # Windows 侧配置 (Windows Terminal)
├── omp/               # omp 数据目录
├── agents/            # Agent 记忆与 skills 本体 (git 子模块)
├── agents-skills/     # stow 包: 各工具 skills 目录软链
├── agents-memory/     # stow 包: ~/.agents 与 ~/.claude/CLAUDE.md 软链
├── AGENTS.md          # dotfile 仓库级 agent 说明
└── CLAUDE.md          # dotfile 仓库级 Claude 说明
```

## 安装

### 前置要求

安装 GNU Stow：
```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow

# Arch Linux
sudo pacman -S stow
```

### 使用步骤

1. 克隆仓库：
```bash
git clone git@github.com:zllynx/dotfile.git ~/dotfile
cd ~/dotfile
git submodule update --init   # 拉取 agents 记忆子模块
```

2. Stow 所有模块：
```bash
# 单独 stow 某个模块
stow git
stow nvim
stow zsh
stow tmux

# 或者一次性 stow 所有模块
for dir in */; do stow "${dir%/}"; done
```

3. 这会在 home 目录创建符号链接，例如：
```
~/.gitconfig      -> ~/dotfile/git/.gitconfig
~/.gitmessage     -> ~/dotfile/git/.gitmessage
~/.zshrc          -> ~/dotfile/zsh/.zshrc
~/.tmux.conf      -> ~/dotfile/tmux/.tmux.conf
```

## 更新配置

修改配置文件后：

```bash
cd ~/dotfile

# 重新链接某个模块
stow -R git

# 重新链接所有模块
for dir in */; do stow -R "${dir%/}"; done

# 查看会做什么改动（不实际执行）
stow -n -R git
```

## 卸载

```bash
cd ~/dotfile

# 删除某个模块的链接
stow -D git

# 删除所有链接
for dir in */; do stow -D "${dir%/}"; done
```

## 配置说明

### Git
- 设置 commit message 模板
- 配置 mergetool 优先级：vscode > nvim > vim

### Neovim
- 个人 Neovim 配置

### Tmux
- 终端复用器配置
- 包含本地配置文件 `.tmux_local.conf` 可自定义

### Zsh
- 使用 Zi (zimfw) 框架
- 包含个人别名和函数

## Agent 配置管理

Agent 的全局记忆与 skills 由 `agents` 子模块（[zllynx/agents](https://github.com/zllynx/agents)）统一管理，通过两个 stow 包部署：

| stow 包 | 部署内容 |
|---|---|
| `agents-memory` | `~/.agents` → 记忆本体仓库；`~/.claude/CLAUDE.md` → `agents/AGENTS.md` |
| `agents-skills` | `~/.claude/skills`、`~/.omp/skills` → `agents/skills` |

```bash
stow agents-memory agents-skills
```

规范：

- 全局记忆本体是 `agents/AGENTS.md`（即 `~/.agents/AGENTS.md`）；工具目录只放软链，不建副本。
- Skill 本体统一放 `~/.agents/skills/<name>/`，工具目录只放软链；工具 skills 目录下出现实体目录即为违规，应收编回本体。
- 项目级记忆统一用项目根目录的 `AGENTS.md`，不建 CLAUDE.md 等副本。
- 修改记忆或 skill 后：`git -C ~/.agents add -A && git commit && git push`，然后回 dotfile 仓库 bump 子模块指针并推送。
- 严禁把 AK/密码/token 写进记忆或 skill。

## 常见问题

### Q: Stow 提示冲突怎么办？

A: 删除或备份现有文件后重新 stow：
```bash
mv ~/.gitconfig ~/.gitconfig.backup
stow git
```

### Q: 如何只在某些机器上使用特定配置？

A: 只 stow 你需要的模块：
```bash
# 只在服务器上使用 tmux 和 nvim
stow tmux
stow nvim
```

### Q: stow agents-memory 后 ~/.agents 是空的？

A: `agents` 是 git 子模块，先初始化再 stow：
```bash
git submodule update --init
stow agents-memory
```

## License

MIT
