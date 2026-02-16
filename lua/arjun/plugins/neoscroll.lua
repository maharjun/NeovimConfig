return {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
        local neoscroll = require("neoscroll")
        neoscroll.setup({
            mappings = {}, -- Disable default mappings, we'll set our own
            hide_cursor = true,
            stop_eof = true,
            respect_scrolloff = true,
            cursor_scrolls_alone = true,
            easing = "quadratic",
        })

        local keymap = {
            ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end,
            ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end,
            ["zt"] = function() neoscroll.zt({ half_win_duration = 250 }) end,
            ["zz"] = function() neoscroll.zz({ half_win_duration = 250 }) end,
            ["zb"] = function() neoscroll.zb({ half_win_duration = 250 }) end,
        }

        for key, func in pairs(keymap) do
            vim.keymap.set({ "n", "v", "x" }, key, func)
        end

        vim.keymap.set({ "n", "v", "x" }, "<M-n>", "5<C-e>", { desc = "Scroll down 5 lines" })
        vim.keymap.set({ "n", "v", "x" }, "<M-p>", "5<C-y>", { desc = "Scroll up 5 lines" })

        -- In insert mode: scroll lsp_signature window if open
        vim.keymap.set("i", "<M-n>", function()
            if _LSP_SIG_CFG and _LSP_SIG_CFG.winnr and vim.api.nvim_win_is_valid(_LSP_SIG_CFG.winnr) then
                vim.api.nvim_win_call(_LSP_SIG_CFG.winnr, function() vim.cmd("normal! 3j") end)
            end
        end, { desc = "Scroll signature down" })

        vim.keymap.set("i", "<M-p>", function()
            if _LSP_SIG_CFG and _LSP_SIG_CFG.winnr and vim.api.nvim_win_is_valid(_LSP_SIG_CFG.winnr) then
                vim.api.nvim_win_call(_LSP_SIG_CFG.winnr, function() vim.cmd("normal! 3k") end)
            end
        end, { desc = "Scroll signature up" })
    end,
}
