return {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    opts = {
        theme = "dark",
        app = { "cmd.exe", "/c", "start" },
    },
    keys = {
        {
            "<leader>mp",
            function()
                local peek = require("peek")
                if peek.is_open() then
                    peek.close()
                else
                    peek.open()
                end
            end,
            ft = "markdown",
            desc = "Toggle Peek Markdown Preview",
        },
    },
}
