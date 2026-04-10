return {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("vscode").setup({
            transparent = false,
            italic_comments = true,
            underline_links = true,
        })
        vim.cmd.colorscheme("vscode")
        vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#808080", italic = true })
    end,
}
