return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    },
    config = function()
        require("diffview").setup({
            enhanced_diff_hl = true,
            hooks = {
                diff_buf_read = function()
                    vim.opt_local.wrap = false
                end,
            },
        })
        -- Tone down the filler lines (deleted regions) so they're less noisy
        vim.api.nvim_set_hl(0, "DiffviewDiffDeleteDim", { bg = "NONE", fg = "#3e3e3e" })
        vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2d1515", fg = "#3e3e3e" })
    end,
}
