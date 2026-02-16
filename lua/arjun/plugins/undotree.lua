return {
    "mbbill/undotree",
    keys = {
        { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
    },
    config = function()
        local undodir = vim.fn.expand("~/.undodir")
        if vim.fn.isdirectory(undodir) == 0 then
            vim.fn.mkdir(undodir, "p", tonumber("0700", 8))
        end
        vim.opt.undodir = undodir
        vim.opt.undofile = true
    end,
}
