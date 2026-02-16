# Neovim Configuration

## Prerequisites

- **Neovim 0.11+** (this config uses native LSP features)
- **fd** (for venv-selector): `sudo apt install fd-find && sudo ln -s $(which fdfind) /usr/local/bin/fd`
- **ripgrep** (for Telescope live grep): `sudo apt install ripgrep`
- **fzf** (for quickfix filtering): `sudo apt install fzf`

### Treesitter Dependencies

Treesitter requires tools to compile parsers:

```bash
# C/C++ compiler and build tools
sudo apt install build-essential libclang-dev

# tree-sitter-cli (via Cargo)
sudo apt install rustup
rustup default stable
cargo install tree-sitter-cli
```

Alternatively, install tree-sitter-cli via npm:
```bash
npm install -g tree-sitter-cli
```

## Directory Structure

```
~/.config/nvim/
├── init.lua                      # Entry point, requires arjun module
└── lua/arjun/
    ├── init.lua                  # Main config, loads remap and lazy
    ├── set.lua                   # Core Neovim settings
    ├── remap.lua                 # Core keymaps
    ├── lazy.lua                  # Lazy.nvim bootstrap
    └── plugins/
        ├── init.lua              # Base plugin specs
        ├── telescope.lua         # Fuzzy finder
        ├── treesitter.lua        # Syntax highlighting
        ├── undotree.lua          # Undo history visualization
        ├── visual-multi.lua      # Multi-cursor editing
        ├── neogit.lua            # Git interface
        ├── lsp.lua               # LSP, Mason, autocompletion
        ├── venv-selector.lua     # Python venv switching
        ├── ufo.lua               # Code folding
        ├── neoscroll.lua         # Smooth scrolling
        ├── colorscheme.lua       # VS Code theme
        ├── bqf.lua               # Better quickfix
        ├── conform.lua           # Formatter (mdformat for markdown)
        ├── diffview.lua          # Multi-file git diff viewer
        ├── markdown-preview.lua  # Live markdown preview in browser
        └── surround.lua          # Add/delete/replace surroundings

```

## Installation

1. Clone or copy this config to `~/.config/nvim/`
2. Open Neovim - Lazy.nvim will auto-bootstrap
3. Run `:Lazy sync` to install all plugins
4. Run `:Mason` to install LSP servers (e.g., `basedpyright` for Python)

## Keymaps

Leader key is `<Space>`.

### File Navigation (Telescope)

| Keymap | Action |
|--------|--------|
| `<leader>pf` | Find files |
| `<leader>pr` | Recent files |
| `<leader>pb` | List buffers |
| `<leader>ps` | Search text (supports ripgrep args) |
| `<leader>pw` | Search word under cursor |
| `<leader>pd` | Find directory |
| `<leader>po` | Document symbols (LSP) |
| `<leader>pov` | Document variables |
| `<leader>pof` | Document functions |
| `<leader>poc` | Document classes |
| `<leader>pa` | All workspace symbols (LSP) |
| `<leader>pav` | Workspace variables |
| `<leader>paf` | Workspace functions |
| `<leader>pac` | Workspace classes |
| `<leader>pv` | Open file explorer (netrw) |

### Git (Neogit + Diffview)

| Keymap | Action |
|--------|--------|
| `<leader>gs` | Open Neogit status |
| `<leader>gd` | Diffview: open all uncommitted changes |
| `<leader>gh` | Diffview: file history for current file |
| `<leader>gq` | Diffview: close |

Inside Neogit, press `?` for help. Common keys:
- `s` - stage file/hunk
- `u` - unstage
- `c` - commit popup
- `p` - push popup
- `F` - pull popup

### Markdown

| Keymap | Action |
|--------|--------|
| `<leader>mp` | Toggle Markdown Preview (browser) |
| `<leader>fw` | Format/hard-wrap markdown (mdformat, 80 cols) |

### Surround (mini.surround)

| Key | Action | Example |
|-----|--------|---------|
| `sa` + motion + char | Add surrounding | `saiw(` wraps word in `()` |
| `sd` + char | Delete surrounding | `sd"` removes quotes |
| `sr` + old + new | Replace surrounding | `sr"'` changes `"` to `'` |

Open brackets `([{` add **no padding**, close brackets `)]}` add **padding**.

### Treesitter Text Objects

**Select** (use with `v`, `d`, `c`, `y`):

| Key | Selects |
|-----|---------|
| `af` / `if` | Around/inside function |
| `ac` / `ic` | Around/inside class |
| `aa` / `ia` | Around/inside argument |
| `ai` / `ii` | Around/inside if block |
| `al` / `il` | Around/inside loop |
| `ab` / `ib` | Around/inside block (paragraph, code block, heading, list) |
| `as` / `is` | Around/inside section (heading + content until next same-level heading) |

**Jump** (normal, visual, operator-pending):

| Key | Jumps to |
|-----|----------|
| `]f` / `[f` | Next/previous function |
| `]c` / `[c` | Next/previous class |
| `]a` / `[a` | Next/previous argument |
| `]b` / `[b` | Next/previous block |
| `]s` / `[s` | Next/previous section |

### Utilities

| Keymap | Action |
|--------|--------|
| `<leader>u` | Toggle Undotree |
| `<leader>pe` | Select Python venv |

### Multi-cursor (vim-visual-multi)

| Key | Action |
|-----|--------|
| `Ctrl-n` | Select word under cursor (repeat for next) |
| `Ctrl-Down/Up` | Create cursors vertically |
| `Shift-Arrows` | Select one character at a time |
| `n` / `N` | Next / previous occurrence |
| `q` | Skip current, get next |
| `Q` | Remove current cursor |
| `Tab` | Switch between cursor/extend mode |

### Autocompletion (nvim-cmp)

| Key | Action |
|-----|--------|
| `Ctrl-Space` | Trigger completion |
| `Ctrl-e` | Abort completion |
| `Enter` | Confirm selection |
| `Ctrl-b/f` | Scroll docs |

### Code Folding (nvim-ufo)

| Key | Action |
|-----|--------|
| `za` | Toggle fold under cursor |
| `zo` | Open fold under cursor |
| `zc` | Close fold under cursor |
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek inside fold (preview) |

### Scrolling (neoscroll.nvim - animated)

| Key | Action |
|-----|--------|
| `Alt-n` | Scroll down 5 lines (instant) |
| `Alt-p` | Scroll up 5 lines (instant) |
| `Ctrl-b` | Scroll up full page (quadratic easing) |
| `Ctrl-f` | Scroll down full page (quadratic easing) |
| `zt` | Scroll cursor to top (animated) |
| `zz` | Scroll cursor to center (animated) |
| `zb` | Scroll cursor to bottom (animated) |

### LSP Actions

| Key | Action |
|-----|--------|
| `<leader>ca` | Code action (show fixes) |
| `<leader>cf` | Format buffer |
| `<leader>cr` | Rename symbol |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<leader>e` | Show diagnostic message |
| `<leader>q` | Diagnostics to loclist |

### Clipboard

| Key | Action |
|-----|--------|
| `<leader>y` | Yank to clipboard |
| `<leader>Y` | Yank line to clipboard |
| `<leader>d` | Delete to clipboard (cut) |

### Quickfix (nvim-bqf)

| Key | Action |
|-----|--------|
| `Ctrl-q` | (In Telescope) Send results to quickfix |
| `zf` | Fuzzy filter quickfix list |
| `zn` | Create new quickfix list |
| `Tab` | Toggle sign/bookmark on item |
| `zN` | Filter to signed items only |
| `o` | Open in split |
| `p` | Toggle preview |

### Ripgrep Args (in Telescope search)

| Search prompt | Effect |
|---------------|--------|
| `foo` | Basic search |
| `"foo bar"` | Exact phrase |
| `foo -g "!**/tests/**"` | Exclude folder |
| `foo -g "*.py"` | Only Python files |
| `foo -tpy` | Only Python (shorthand) |
| `foo --no-ignore` | Include gitignored |

## LSP Setup

LSP is managed via Mason. To install a language server:

1. Run `:Mason`
2. Search for the server (e.g., `basedpyright`)
3. Press `i` to install

Installed servers are auto-enabled when you open a file of that type.

### Configuring basedpyright

Create `pyrightconfig.json` in your project root:

```json
{
  "venvPath": ".",
  "venv": ".venv",
  "typeCheckingMode": "standard"
}
```

Or use the venv-selector with `<leader>pe` to switch venvs dynamically.

## Project-Local Configuration

This config enables `exrc`, allowing per-project `.nvim.lua` files.

### Setup

Project-local configs are automatically loaded when you open Neovim in a directory containing `.nvim.lua`. On first load, Neovim will ask you to trust the file.

### Example: Custom Python venv search

Create `.nvim.lua` in your project root:

```lua
-- .nvim.lua
-- Search for Python venvs in a specific directory
-- Temporarily clear file_ignore_patterns so Telescope doesn't filter venv names
vim.keymap.set("n", "<leader>pe", function()
    local conf = require("telescope.config").values
    local saved = conf.file_ignore_patterns
    conf.file_ignore_patterns = {}
    vim.cmd("VenvSelect fd 'bin/python$' workspaces/codegen-agent-ws --full-path -a -d 4 -H")
    conf.file_ignore_patterns = saved
end, { desc = "Select Python venv (project)" })
```

**Important flags for fd:**
- `-H` - include hidden directories (for `.venv` folders)
- `-a` - show absolute paths
- `-d 4` - search depth limit

### Example: Project-specific Telescope excludes

Add file exclusion patterns per project (uses Lua patterns, not glob):

```lua
-- .nvim.lua
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "%.git/",
            "%.venv%-.*%-ws/",    -- .venv-*-ws
            "%.2%-venv%-.*",      -- .2-venv-*
            "__pycache__/",
        },
    },
})
```

**Lua pattern escaping:**
- `%.` - literal dot (`.` is special in Lua patterns)
- `%-` - literal hyphen
- `.*` - any characters

### Gitignore

Add `.nvim.lua` to your project's `.gitignore`:

```bash
echo ".nvim.lua" >> .gitignore
```

## Plugin Details

### Telescope
Fuzzy finder for files, grep, buffers, and more. Includes `live-grep-args` extension for passing ripgrep arguments directly in search prompt. Requires `ripgrep`.

### Treesitter
Syntax highlighting using tree-sitter parsers. Parsers are auto-installed for: lua, vim, vimdoc, query, python, xml, json, yaml. Includes `treesitter-textobjects` for structural selection and navigation (functions, classes, arguments, markdown sections).

To add more languages, edit `lua/arjun/plugins/treesitter.lua` and add to the install list. Custom markdown text object queries are in `after/queries/markdown/textobjects.scm`.

### Undotree
Visualizes undo history as a tree. Persistent undo is enabled - undo history survives across sessions (stored in `~/.undodir`).

### vim-visual-multi
Multi-cursor editing similar to VS Code/Sublime. Press `Ctrl-n` on a word to start, then `n` for next occurrence.

### Neogit
Git interface inspired by Emacs Magit. Provides a TUI for staging, committing, pushing, etc.

### diffview.nvim
Multi-file git diff viewer similar to VS Code's Source Control panel. Shows all changed files in a sidebar with side-by-side diffs. Useful for reviewing LLM-generated changes across multiple files. Supports arbitrary commit ranges (e.g., `:DiffviewOpen HEAD~3`).

### venv-selector
Switch Python virtual environments without restarting Neovim. Integrates with basedpyright LSP.

The picker shows just the venv folder name for clarity. Results are cached per project directory.

### nvim-ufo
Modern code folding with treesitter support. Folds are created automatically based on code structure (functions, classes, blocks). Use `zK` to peek inside a fold without opening it.

### neoscroll.nvim
Smooth animated scrolling for all scroll commands. Uses quadratic easing for a natural feel. Respects `scrolloff` setting (cursor stays 8 lines from edges).

### vscode.nvim
VS Code Dark colorscheme with yellow functions, italic comments, and proper treesitter/LSP highlighting support.

### nvim-bqf
Enhanced quickfix window with fuzzy filtering (fzf), preview, and item signing. Enables hierarchical search workflow: Telescope → quickfix → filter → refine.

### conform.nvim
Formatter framework. Configured with `mdformat` for markdown files — hard-wraps prose at 80 columns while respecting code blocks, links, and other markdown structures. Requires `mdformat` (`conda install conda-forge::mdformat`).

### markdown-preview.nvim
Live markdown preview in the browser. Auto-close is disabled so the preview persists when switching buffers.

### mini.surround
Add, delete, and replace surrounding characters (brackets, quotes, tags, etc.). Open brackets add no padding, close brackets add padding (flipped from default).

## Commands Reference

| Command | Description |
|---------|-------------|
| `:Lazy` | Open Lazy.nvim plugin manager |
| `:Lazy sync` | Install/update/clean plugins |
| `:Mason` | Open Mason LSP installer |
| `:Neogit` | Open Git interface |
| `:DiffviewOpen` | Open multi-file diff view |
| `:DiffviewClose` | Close diff view |
| `:VenvSelect` | Open venv picker |
| `:UndotreeToggle` | Toggle undo tree |
| `:Telescope <cmd>` | Run Telescope command |
| `:TSUpdate` | Update Treesitter parsers |
| `:MarkdownPreviewToggle` | Toggle markdown preview |

## Troubleshooting

### venv-selector shows no results
- Ensure `fd` is installed and in PATH
- Add `-H` flag to search hidden directories
- Check the search path is correct relative to your working directory

### venv-selector missing entries when using Telescope

Telescope's `file_ignore_patterns` (set in `defaults`) applies to **all** Telescope pickers, including venv-selector. If a venv name (e.g., `.2-venv-connector`) matches one of these patterns, it will be silently filtered out before it reaches the sorter.

**Symptom:** `fd` finds the venv (verify with `:!fd ...`), debug logs show "Found venv from interactive: ...", but the Telescope picker shows fewer results than expected.

**Root cause:** In `pickers.lua:get_result_processor`, Telescope checks `entry.value` (which venv-selector sets to the venv folder name) against `file_ignore_patterns` using `string.find`. A pattern like `"%.2%-venv%-.*"` matches the bare name `.2-venv-connector`, filtering it out.

**Fix:** Temporarily clear `file_ignore_patterns` when opening VenvSelect in your project `.nvim.lua`:

```lua
vim.keymap.set("n", "<leader>pe", function()
    local conf = require("telescope.config").values
    local saved = conf.file_ignore_patterns
    conf.file_ignore_patterns = {}
    vim.cmd("VenvSelect fd 'bin/python$' path/to/venvs --full-path -a -d 4 -H")
    conf.file_ignore_patterns = saved
end, { desc = "Select Python venv (project)" })
```

This does not affect file/grep searches — only the VenvSelect picker sees the empty pattern list.

### LSP not starting
- Run `:LspInfo` to check status
- Ensure the server is installed via `:Mason`
- Check `:messages` for errors

### Treesitter errors on startup
- Run `:TSUpdate` to update parsers
- The new Treesitter API (v0.10+) differs from older versions

### Project .nvim.lua not loading
- Neovim prompts for trust on first load - check `:messages`
- Verify `exrc` is enabled: `:set exrc?` should show `exrc`
