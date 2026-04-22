local M = {}

-- Updater fn for the active preset. Called before each M.next / M.prev to
-- rebuild the arglist so navigation reflects the preset's current view.
M.current_updater = nil

-- Add presets here. Each entry: { name = string, fn = function() -> string[] | nil }
-- fn returns a list of absolute file paths, or nil to abort.
M.presets = {
    {
        name = "Files in current folder (alphabetical)",
        fn = function()
            local dir = vim.fn.expand("%:p:h")
            if dir == "" or vim.fn.isdirectory(dir) == 0 then
                vim.notify("Current buffer has no folder", vim.log.levels.WARN)
                return nil
            end
            local entries = vim.fn.glob(dir .. "/*", false, true)
            local files = {}
            for _, p in ipairs(entries) do
                if vim.fn.isdirectory(p) == 0 then
                    table.insert(files, p)
                end
            end
            table.sort(files)
            return files
        end,
    },
    {
        name = "Open buffers (most recent first)",
        fn = function()
            local entries = {}
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
                    local name = vim.api.nvim_buf_get_name(b)
                    if name ~= "" and vim.fn.filereadable(name) == 1 then
                        local info = vim.fn.getbufinfo(b)[1]
                        table.insert(entries, { name = name, lastused = info and info.lastused or 0 })
                    end
                end
            end
            table.sort(entries, function(a, b) return a.lastused > b.lastused end)
            local files = {}
            for _, e in ipairs(entries) do
                table.insert(files, e.name)
            end
            return files
        end,
    },
}

local function set_arglist(files)
    if not files or #files == 0 then
        vim.notify("No files to add to arglist", vim.log.levels.WARN)
        return
    end
    pcall(vim.cmd, "argdelete *")
    local parts = {}
    for _, f in ipairs(files) do
        table.insert(parts, vim.fn.fnameescape(f))
    end
    vim.cmd("argadd " .. table.concat(parts, " "))
    local current = vim.fn.expand("%:p")
    for i, f in ipairs(files) do
        if f == current then
            vim.cmd(i .. "argument")
            return
        end
    end
end

function M.pick()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Arglist presets",
        initial_mode = "normal",
        finder = finders.new_table({
            results = M.presets,
            entry_maker = function(entry)
                return { value = entry, display = entry.name, ordinal = entry.name }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local sel = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if sel and sel.value then
                    M.current_updater = sel.value.fn
                    set_arglist(sel.value.fn())
                end
            end)
            return true
        end,
    }):find()
end

local function refresh()
    if M.current_updater then
        set_arglist(M.current_updater())
    end
end

local function current_arg_index()
    local current = vim.fn.expand("%:p")
    for i = 0, vim.fn.argc() - 1 do
        if vim.fn.fnamemodify(vim.fn.argv(i), ":p") == current then
            return i + 1
        end
    end
    return 1
end

local function open_picker(delta)
    refresh()
    local n = vim.fn.argc()
    if n == 0 then
        vim.notify("Arglist is empty", vim.log.levels.WARN)
        return
    end
    local target = ((current_arg_index() - 1 + delta) % n + n) % n + 1
    require("telescope").extensions.arglist.arglist({ default_selection_index = target, initial_mode = "normal" })
end

function M.next() open_picker(1) end
function M.prev() open_picker(-1) end

return M
