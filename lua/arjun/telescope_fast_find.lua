local M = {}

--- Default `fd` invocation when no project override is set.
--- Per-project: `vim.g.arjun_fd_base = "fd --type f ..."` in `.nvim.lua`.
M.default_fd_base = "fd --type f --hidden --no-ignore"
    .. " --exclude .git --exclude .svn"
    .. " --exclude node_modules --exclude __pycache__ --exclude .ruff_cache"

--- Default `fd` for directories (`<leader>pd`). Override with `vim.g.arjun_pd_fd_base`.
M.default_pd_fd_base = "fd --type directory --hidden --follow --no-ignore"
    .. " --exclude .git --exclude .svn"
    .. " --exclude node_modules --exclude __pycache__ --exclude .ruff_cache"

local RESULT_HEAD = 50

local function bash_fd_pipeline(fd_base, prompt)
    local tail = " | head -" .. RESULT_HEAD
    if not prompt or prompt == "" then
        return vim.tbl_flatten({ "bash", "-c", fd_base .. tail })
    end
    local escaped = prompt:gsub("'", "'\\''")
    return vim.tbl_flatten({
        "bash",
        "-c",
        fd_base .. " | fzf --filter='" .. escaped .. "'" .. tail,
    })
end

local function resolved_fd_base()
    local g = vim.g.arjun_fd_base
    if type(g) == "string" and vim.fn.trim(g) ~= "" then
        return vim.fn.trim(g)
    end
    return M.default_fd_base
end

local function resolved_pd_fd_base()
    local g = vim.g.arjun_pd_fd_base
    if type(g) == "string" and vim.fn.trim(g) ~= "" then
        return vim.fn.trim(g)
    end
    return M.default_pd_fd_base
end

--- Open the fast file picker (fd piped through fzf --filter; Telescope shows results).
--- @param opts table|nil Optional `{ fd_base = string }` overrides globals for one shot.
function M.open(opts)
    opts = opts or {}
    local fd_base = opts.fd_base or resolved_fd_base()

    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")
    local conf = require("telescope.config").values
    local make_entry = require("telescope.make_entry")

    pickers.new({}, {
        prompt_title = "Find Files",
        finder = finders.new_job(function(prompt)
            return bash_fd_pipeline(fd_base, prompt)
        end, make_entry.gen_from_file({})),
        sorter = conf.file_sorter({}),
        previewer = conf.file_previewer({}),
    }):find()
end

--- Open the fast directory picker (`:Ex` on selection). Same pipeline as `open`, directories only.
--- @param opts table|nil Optional `{ fd_base = string }` overrides `vim.g.arjun_pd_fd_base` for one shot.
function M.open_directories(opts)
    opts = opts or {}
    local fd_base = opts.fd_base or resolved_pd_fd_base()

    local finders = require("telescope.finders")
    local pickers = require("telescope.pickers")
    local conf = require("telescope.config").values
    local make_entry = require("telescope.make_entry")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Find Directory",
        finder = finders.new_job(function(prompt)
            return bash_fd_pipeline(fd_base, prompt)
        end, make_entry.gen_from_file({})),
        sorter = conf.file_sorter({}),
        previewer = conf.file_previewer({}),
        attach_mappings = function(_, map)
            local function ex_selected(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry and entry.value then
                    -- Absolutize against vim's cwd (where fd ran). From a netrw buffer,
                    -- `:Ex relpath` resolves against the netrw dir, not cwd, so the second
                    -- invocation would silently land at <current-netrw-dir>/<relpath>.
                    local abs = vim.fn.fnamemodify(entry.value, ":p")
                    vim.cmd("Ex " .. vim.fn.fnameescape(abs))
                end
            end
            map("i", "<CR>", ex_selected)
            map("n", "<CR>", ex_selected)
            return true
        end,
    }):find()
end

return M
