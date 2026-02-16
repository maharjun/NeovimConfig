return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        -- Picker: telescope chosen from telescope, fzf-lua, mini.pick, snacks.nvim
        "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
        { "<leader>gs", "<cmd>Neogit<cr>", desc = "Git status (Neogit)" },
    },
}
