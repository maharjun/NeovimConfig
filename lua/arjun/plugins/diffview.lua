return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
        { "<leader>gm", "<cmd>DiffviewOpen origin/main...HEAD<cr>", desc = "Diffview: diff against main (merge base)" },
        { "<leader>gs", "<cmd>DiffviewOpen --staged<cr>", desc = "Diffview: diff against main (merge base)" },
    },
    config = function()
        local actions = require("diffview.actions")
        require("diffview").setup({
            enhanced_diff_hl = true,
            keymaps = {
                view = {
                    { "n", "<leader>gl", actions.cycle_layout, { desc = "Cycle diff layout" } },
                },
                file_panel = {
                    { "n", "<leader>gl", actions.cycle_layout, { desc = "Cycle diff layout" } },
                },
                file_history_panel = {
                    { "n", "<leader>gl", actions.cycle_layout, { desc = "Cycle diff layout" } },
                },
            },
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
