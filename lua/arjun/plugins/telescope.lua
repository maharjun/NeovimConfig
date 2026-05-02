return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
        "sam4llis/telescope-arglist.nvim",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_layout = require("telescope.actions.layout")
        local action_state = require("telescope.actions.state")
        local layout_strategies = require("telescope.pickers.layout_strategies")

        local close_saving_history = function(prompt_bufnr)
            local line = action_state.get_current_line()
            if line and line ~= "" then
                action_state.get_current_history():append(line, action_state.get_current_picker(prompt_bufnr))
            end
            actions.close(prompt_bufnr)
        end

        layout_strategies.horizontal_narrow = function(picker, max_columns, max_lines, layout_config)
            layout_config = vim.tbl_deep_extend("force", layout_config or {}, { preview_width = 0.4 })
            return layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
        end

        layout_strategies.horizontal_wide = function(picker, max_columns, max_lines, layout_config)
            layout_config = vim.tbl_deep_extend("force", layout_config or {}, { preview_width = 0.7 })
            return layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
        end

        telescope.setup({
            defaults = {
                sorting_strategy = "ascending",
                path_display = { "smart" },
                layout_strategy = "horizontal_narrow",
                cycle_layout_list = { "horizontal_narrow", "horizontal_wide" },
                history = {
                    path = vim.fn.stdpath("data") .. "/telescope_history",
                    limit = 200,
                },
                mappings = {
                    i = {
                        ["<C-c>"] = close_saving_history,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<M-l>"] = action_layout.cycle_layout_next,
                    },
                    n = {
                        ["<Esc>"] = close_saving_history,
                        ["q"] = close_saving_history,
                        ["<M-l>"] = action_layout.cycle_layout_next,
                    },
                },
            },
            extensions = {
                fzf = {},
            },
            pickers = {
                find_files = {
                    hidden = true,
                    file_ignore_patterns = { "%.git/" },
                },
                grep_string = {
                    additional_args = { "--hidden", "--glob=!.git/" },
                },
                live_grep = {
                    additional_args = { "--hidden", "--glob=!.git/" },
                },
                buffers = {
                    file_ignore_patterns = {},
                },
            },
        })
        telescope.load_extension("fzf")
        telescope.load_extension("live_grep_args")
        telescope.load_extension("arglist")
    end,
    keys = {
        -- Files
        { "<leader>pf", function() require("arjun.telescope_fast_find").open() end, desc = "Find files" },
        { "<leader>pr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
        { "<leader>pb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>pl", function() require("arjun.arglist").pick() end, desc = "Pick arglist preset" },
        -- Search (with ripgrep args support)
        { "<leader>ps", function() require("telescope").extensions.live_grep_args.live_grep_args() end, desc = "Search text (with args)" },
        { "<leader>pw", "<cmd>Telescope grep_string<cr>", desc = "Search word under cursor" },
        -- Directories (fast: fd | fzf | head, same pattern as arjun.telescope_fast_find)
        { "<leader>pd", function() require("arjun.telescope_fast_find").open_directories() end, desc = "Find directory" },
        -- LSP Symbols (Ctrl-Shift-O in VS Code)
        { "<leader>po", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
        { "<leader>pov", function() require("telescope.builtin").lsp_document_symbols({ symbols = { "variable", "constant" } }) end, desc = "Document variables" },
        { "<leader>pof", function() require("telescope.builtin").lsp_document_symbols({ symbols = { "function", "method" } }) end, desc = "Document functions" },
        { "<leader>poc", function() require("telescope.builtin").lsp_document_symbols({ symbols = { "class" } }) end, desc = "Document classes" },
        { "<leader>pa", function() require("arjun.telescope_workspace_symbols").open_progressive() end, desc = "All workspace symbols (progressive)" },
        { "<leader>pav", function() require("arjun.telescope_workspace_symbols").open_progressive({ symbols = { "variable", "constant" } }) end, desc = "Workspace variables (progressive)" },
        { "<leader>paf", function() require("arjun.telescope_workspace_symbols").open_progressive({ symbols = { "function", "method" } }) end, desc = "Workspace functions (progressive)" },
        { "<leader>pac", function() require("arjun.telescope_workspace_symbols").open_progressive({ symbols = { "class" } }) end, desc = "Workspace classes (progressive)" },
    },
}
