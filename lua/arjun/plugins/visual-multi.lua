return {
    "mg979/vim-visual-multi",
    init = function()
        -- Remap Ctrl-N to Ctrl-D (VS Code style)
        vim.g.VM_maps = {
            ["Find Under"] = "<C-d>",
            ["Find Subword Under"] = "<C-d>",
        }
    end,
    event = "VeryLazy",
}
