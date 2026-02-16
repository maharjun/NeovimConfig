return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
        { "junegunn/fzf", build = ":call fzf#install()" },
    },
    opts = {
        auto_enable = true,
        preview = {
            auto_preview = true,
            winblend = 0,
        },
        filter = {
            fzf = {
                action_for = { ["ctrl-s"] = "split" },
                extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
            },
        },
    },
}
