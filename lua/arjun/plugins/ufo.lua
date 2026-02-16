return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufRead",
    config = function()
        -- Required settings
        vim.o.foldcolumn = "0"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Keymaps
        local ufo = require("ufo")
        vim.keymap.set("n", "zR", function() ufo.closeFoldsWith(99) end, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
        vim.keymap.set("n", "zK", function()
            local winid = ufo.peekFoldedLinesUnderCursor()
            if not winid then
                vim.lsp.buf.hover()
            end
        end, { desc = "Peek fold or hover" })
        -- Fold to specific levels (z0 = all closed, z1 = level 1, etc.)
        vim.keymap.set("n", "z0", function() ufo.closeFoldsWith(0) end, { desc = "Fold all (level 0)" })
        vim.keymap.set("n", "z1", function() ufo.closeFoldsWith(1) end, { desc = "Fold to level 1" })
        vim.keymap.set("n", "z2", function() ufo.closeFoldsWith(2) end, { desc = "Fold to level 2" })
        vim.keymap.set("n", "z3", function() ufo.closeFoldsWith(3) end, { desc = "Fold to level 3" })
        vim.keymap.set("n", "z4", function() ufo.closeFoldsWith(4) end, { desc = "Fold to level 4" })

        require("ufo").setup({
            -- Use treesitter as main provider, indent as fallback
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
        })
    end,
}
