return {
    -- "ray-x/lsp_signature.nvim",
    dir = "/home/arjun/Desktop/Work/Cosmon/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
        bind = true,
        floating_window = true,
        floating_window_above_cur_line = true,
        hint_enable = true,
        hint_prefix = " ",
        hi_parameter = "LspSignatureActiveParameter",
        handler_opts = {
            border = "rounded",
        },
        toggle_key = "<C-s>",
        extra_trigger_chars = { "(", "," },
        vertical_params = true,
    },
}
