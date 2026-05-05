vim.g.mapleader = " "
vim.keymap.set("n", "<leader>p", "<Nop>", { desc = "No-op (prevent accidental paste)" })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Clipboard (system) yank/paste
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"+d', { desc = "Delete to clipboard (cut)" })

-- Macro replay: record with qu, replay with Q
vim.keymap.set("n", "Q", "@u", { desc = "Replay macro u" })

-- LSP actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>cR", "<cmd>lsp restart<cr>", { desc = "Restart LSP server(s)" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gtd", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Go to references" })

-- Arglist navigation
vim.keymap.set("n", "<leader>j", function() require("arjun.arglist").next() end, { desc = "Next arglist file" })
vim.keymap.set("n", "<leader>k", function() require("arjun.arglist").prev() end, { desc = "Previous arglist file" })

-- Diagnostics navigation
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Pane navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right pane" })

-- Terminal
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.api.nvim_create_user_command("Bd", function(opts)
	local target
	if opts.args ~= "" then
		target = tonumber(opts.args) or vim.fn.bufnr(opts.args)
		if not target or target < 1 then
			vim.notify("No buffer matching " .. opts.args, vim.log.levels.ERROR)
			return
		end
	else
		target = vim.api.nvim_get_current_buf()
	end
	if vim.bo[target].modified and not opts.bang then
		vim.notify(
			("E89: No write since last change for buffer %d (add ! to override)"):format(target),
			vim.log.levels.ERROR
		)
		return
	end
	local was_listed = vim.bo[target].buflisted
	for _, win in ipairs(vim.fn.win_findbuf(target)) do
		vim.api.nvim_win_call(win, function()
			local alt = vim.fn.bufnr("#")
			if alt > 0 and alt ~= target and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
				vim.api.nvim_win_set_buf(win, alt)
			else
				pcall(vim.cmd, "bprevious")
				if vim.api.nvim_win_get_buf(win) == target then
					vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
				end
			end
		end)
	end
	if not vim.api.nvim_buf_is_valid(target) then
		return
	end
	local kill = was_listed and "bdelete" or "bwipeout"
	vim.cmd(("%s%s %d"):format(kill, opts.bang and "!" or "", target))
end, { bang = true, nargs = "?", complete = "buffer", desc = "Delete buffer keeping window/tab layout" })

vim.cmd([[cnoreabbrev <expr> bd (getcmdtype() == ':' && getcmdline() ==# 'bd') ? 'Bd' : 'bd']])
