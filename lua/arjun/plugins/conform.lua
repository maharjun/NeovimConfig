return {
    "stevearc/conform.nvim",
    keys = {
        {
            "<leader>fw",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            desc = "Format (wrap) buffer",
        },
    },
    opts = {
        formatters_by_ft = {
            markdown = { "mdformat" },
        },
        formatters = {
            mdformat = {
                prepend_args = { "--wrap", "80" },
            },
        },
    },
}
