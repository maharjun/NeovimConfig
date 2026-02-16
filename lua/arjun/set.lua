-- Core Neovim settings

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Hide fold column (fold indicators on left side)
vim.opt.foldcolumn = "0"

-- Keep cursor centered while scrolling, minimum 8 lines from edge
vim.opt.scrolloff = 8

-- Smooth scrolling handled by neoscroll.nvim plugin

-- WSL clipboard: use clip.exe / powershell for native Windows clipboard integration
vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
    },
    paste = {
        ["+"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ["*"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
}
