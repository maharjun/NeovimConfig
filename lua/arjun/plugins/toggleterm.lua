local function tmux_session_name()
    local root = vim.fn.getcwd()
    local hash = vim.fn.sha256(root):sub(1, 8)
    return "nvim-" .. hash
end

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<leader>tr", function()
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
        shell = function()
            return "tmux new-session -A -s " .. tmux_session_name()
        end,
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
        on_open = function(term)
            -- Switch tmux to the window matching this terminal's ID
            local session = tmux_session_name()
            local win_target = session .. ":" .. (term.id - 1)
            -- Create the window if it doesn't exist, otherwise select it
            vim.fn.system("tmux select-window -t " .. win_target .. " 2>/dev/null || tmux new-window -t " .. win_target)

            -- Ctrl-\ in terminal mode: escape to normal mode
            vim.keymap.set("t", "<C-\\>", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Exit terminal mode" })
            -- Ctrl-\ in normal mode: hide this terminal
            vim.keymap.set("n", "<C-\\>", function()
                vim.cmd(term.id .. "ToggleTerm")
            end, { buffer = term.bufnr, desc = "Hide terminal" })
        end,
    },
}
