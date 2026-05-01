return {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    config = function()
        require("venv-selector").setup({
            options = {
                enable_cached_venvs = false,
                on_telescope_result_callback = function(filename)
                    local cwd = vim.fn.getcwd()
                    if vim.startswith(filename, cwd .. "/") then
                        return (filename:sub(#cwd + 2):gsub("/bin/python$", ""))
                    end
                    return filename:match("([^/]+)/bin/python$") or filename
                end,
            },
        })
        -- Only set default keymap if not already defined (e.g., by .nvim.lua)
        local existing = vim.fn.maparg("<leader>pe", "n")
        if existing == "" then
            vim.keymap.set("n", "<leader>pe", "<cmd>VenvSelect<cr>", { desc = "Select Python venv" })
        end
    end,
}
