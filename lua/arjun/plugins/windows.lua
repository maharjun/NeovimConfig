return {
    "anuvyklack/windows.nvim",
    event = "VeryLazy",
    dependencies = {
        "anuvyklack/middleclass",
    },
    config = function()
        vim.o.winwidth = 10
        vim.o.winminwidth = 10
        vim.o.equalalways = false
        require("windows").setup({
            autowidth = {
                winwidth = 1.5,
            },
            animation = {
                enable = false,
            },
        })
    end,
}
