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
                -- Show just the venv folder name instead of full path
                on_telescope_result_callback = function(filename)
                    -- Extract venv name from path like /path/to/.venv-name/bin/python
                    local venv_name = filename:match("([^/]+)/bin/python$")
                    if venv_name then
                        return venv_name
                    end
                    return filename
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
