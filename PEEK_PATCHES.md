# Peek.nvim Patches

These are manual patches applied to `peek.nvim` (`~/.local/share/nvim/lazy/peek.nvim/`). They will be overwritten if the plugin is updated — reapply after updates.

## Why peek.nvim

`markdown-preview.nvim` bundles Mermaid 10.2.3 which hardcodes `fill="#eaeaea"` on sequence diagram actor rects. The dark theme generates correct CSS rules (`.actor { fill: #1f2020 }`) but the inline SVG attributes always win. No combination of `themeVariables`, `themeCSS`, or custom CSS injection fixes this — the plugin's architecture doesn't support overriding Mermaid's inline attributes.

`peek.nvim` uses Deno and renders Mermaid with proper dark theme support.

## Prerequisites

- **Deno** installed at `~/.deno/bin/deno` (added to PATH via `~/.bashrc`)
- **WSL browser opener**: `cmd.exe /c start` (since `xdg-open` has no browser on WSL)

## Patches applied

### 1. Mermaid version upgrade (`public/mermaid.min.js`)

Replaced bundled Mermaid 10.9.0 with 11.6.0:

```bash
curl -sL "https://cdn.jsdelivr.net/npm/mermaid@11.6.0/dist/mermaid.min.js" \
  -o ~/.local/share/nvim/lazy/peek.nvim/public/mermaid.min.js
```

### 2. Diagram expand/zoom modal (`public/index.html`)

Added a zoom modal for Mermaid diagrams. Each diagram gets an expand button (⛶) on hover. Clicking opens a fullscreen modal with:

- Zoom controls (+, −, 1:1 reset)
- Scroll wheel zoom
- Click and drag to pan
- Escape or backdrop click to close

Key detail: the modal div has `class="markdown-body"` so the cloned SVG inherits the dark theme CSS context. Without this, Mermaid's ID-scoped CSS rules don't apply and the diagram reverts to light colors.

### 3. Modal styles (`public/style.css`)

Added CSS for the expand button, modal overlay, modal content panel, toolbar buttons, and drag cursor states. The modal overrides `.markdown-body` layout properties (`max-width`, `padding`, `overflow`) since it inherits that class for theming only.

## Neovim config

`~/.config/nvim/lua/arjun/plugins/peek.lua`:

```lua
return {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    opts = {
        theme = "dark",
        app = { "cmd.exe", "/c", "start" },
    },
    keys = {
        {
            "<leader>mp",
            function()
                local peek = require("peek")
                if peek.is_open() then
                    peek.close()
                else
                    peek.open()
                end
            end,
            ft = "markdown",
            desc = "Toggle Peek Markdown Preview",
        },
    },
}
```

`markdown-preview.nvim` is disabled (`enabled = false`) in `~/.config/nvim/lua/arjun/plugins/markdown-preview.lua`.
