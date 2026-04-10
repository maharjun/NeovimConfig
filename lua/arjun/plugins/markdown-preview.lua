return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
        vim.g.mkdp_auto_close = 0
    end,
    enabled = false, -- replaced by peek.nvim for Mermaid dark mode support
}
