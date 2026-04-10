return {
{
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true },
            move = { set_jumps = true },
        })

        local select = require("nvim-treesitter-textobjects.select").select_textobject
        local move_next = require("nvim-treesitter-textobjects.move").goto_next_start
        local move_prev = require("nvim-treesitter-textobjects.move").goto_previous_start

        -- Select text objects
        local select_maps = {
            ["af"] = "@function.outer", ["if"] = "@function.inner",
            ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
            ["ai"] = "@conditional.outer", ["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
            -- Markdown: @block = code blocks/paragraphs/lists, @section = heading sections
            ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
            ["as"] = "@section.outer",  ["is"] = "@section.inner",
        }
        for key, query in pairs(select_maps) do
            vim.keymap.set({ "x", "o" }, key, function() select(query, "textobjects") end)
        end

        -- Move between text objects
        local move_maps = {
            ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner",
            ["]b"] = "@block.outer", ["]s"] = "@section.outer",
        }
        for key, query in pairs(move_maps) do
            vim.keymap.set({ "n", "x", "o" }, key, function() move_next(query, "textobjects") end)
        end
        local move_prev_maps = {
            ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner",
            ["[b"] = "@block.outer", ["[s"] = "@section.outer",
        }
        for key, query in pairs(move_prev_maps) do
            vim.keymap.set({ "n", "x", "o" }, key, function() move_prev(query, "textobjects") end)
        end

        -- Treesitter-aware bracket motions (skip brackets inside strings/comments)
        local function is_string_or_comment(r, c)
            local ok, node = pcall(vim.treesitter.get_node, { pos = { r, c } })
            if not ok or not node then return false end
            local t = node:type()
            return t:find("string") ~= nil or t:find("comment") ~= nil
        end

        local function ts_bracket_jump(target, counterpart, forward)
            local cursor = vim.api.nvim_win_get_cursor(0)
            local row, col = cursor[1] - 1, cursor[2]
            local line_count = vim.api.nvim_buf_line_count(0)
            local depth = 0

            if forward then
                col = col + 1
                for r = row, line_count - 1 do
                    local line = vim.api.nvim_buf_get_lines(0, r, r + 1, false)[1] or ""
                    local sc = (r == row) and col or 0
                    for c = sc, #line - 1 do
                        local ch = line:sub(c + 1, c + 1)
                        if (ch == target or ch == counterpart) and not is_string_or_comment(r, c) then
                            if ch == counterpart then
                                depth = depth + 1
                            elseif depth == 0 then
                                vim.api.nvim_win_set_cursor(0, { r + 1, c })
                                return
                            else
                                depth = depth - 1
                            end
                        end
                    end
                end
            else
                col = col - 1
                for r = row, 0, -1 do
                    local line = vim.api.nvim_buf_get_lines(0, r, r + 1, false)[1] or ""
                    local sc = (r == row) and col or (#line - 1)
                    for c = sc, 0, -1 do
                        local ch = line:sub(c + 1, c + 1)
                        if (ch == target or ch == counterpart) and not is_string_or_comment(r, c) then
                            if ch == counterpart then
                                depth = depth + 1
                            elseif depth == 0 then
                                vim.api.nvim_win_set_cursor(0, { r + 1, c })
                                return
                            else
                                depth = depth - 1
                            end
                        end
                    end
                end
            end
        end

        vim.keymap.set({ "n", "x", "o" }, "])", function() ts_bracket_jump(")", "(", true) end)
        vim.keymap.set({ "n", "x", "o" }, "[(", function() ts_bracket_jump("(", ")", false) end)
        vim.keymap.set({ "n", "x", "o" }, "]}", function() ts_bracket_jump("}", "{", true) end)
        vim.keymap.set({ "n", "x", "o" }, "[{", function() ts_bracket_jump("{", "}", false) end)
        vim.keymap.set({ "n", "x", "o" }, "]]", function() ts_bracket_jump("]", "[", true) end)
        vim.keymap.set({ "n", "x", "o" }, "[[", function() ts_bracket_jump("[", "]", false) end)
    end,
},
{
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    commit = "7caec274fd19c12b55902a5b795100d21531391f",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        require("nvim-treesitter").setup({})
        require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "query", "python", "xml", "json", "yaml" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "lua", "vim", "query", "python", "xml", "json", "yaml" },
            callback = function()
                vim.treesitter.start()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
},
}
