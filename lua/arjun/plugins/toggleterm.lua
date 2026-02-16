return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<leader>tt", function()
            local num = nil
            vim.wait(300, function()
                local c = vim.fn.getchar(0)
                if c ~= 0 then
                    local ch = vim.fn.nr2char(c)
                    if ch:match("%d") then num = ch end
                    return true
                end
                return false
            end, 20)
            vim.cmd((num or "1") .. "ToggleTerm")
        end, desc = "Toggle terminal (type digit after for Nth terminal)" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
        { "<leader>ts", "<cmd>TermSelect<cr>", desc = "Select terminal" },
        { "<leader>tn", "<cmd>ToggleTermSetName<cr>", desc = "Name terminal" },
    },
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        direction = "float",
        float_opts = {
            border = "curved",
        },
        winbar = {
            enabled = true,
        },
    },
}
