return {
    "Exafunction/windsurf.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("codeium").setup({
            enable_cmp_source = false,
            virtual_text = {
                enabled = true,
                idle_delay = 75,
                key_bindings = {
                    accept = "<Tab>",
                    accept_word = "<C-j>",
                    accept_line = "<C-l>",
                    clear = "<C-]>",
                    next = "<M-]>",
                    prev = "<M-[>",
                },
            },
        })
    end,
}
