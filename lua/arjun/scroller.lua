local M = {}

M.current_updater = nil

local function preview_snippet(b)
    local lines = vim.api.nvim_buf_get_lines(b, 0, 20, false)
    for _, line in ipairs(lines) do
        local stripped = line:match("^%s*(.-)%s*$")
        if stripped ~= "" then
            return stripped:sub(1, 20)
        end
    end
    return nil
end

local function buffer_display(b)
    local name = vim.api.nvim_buf_get_name(b)
    if name == "" then
        local bt = vim.bo[b].buftype
        if bt ~= "" then
            return ("[%s:%d]"):format(bt, b)
        end
        local snippet = preview_snippet(b)
        if snippet then
            return ("[No Name:%d] %s"):format(b, snippet)
        end
        return ("[No Name:%d]"):format(b)
    end
    return vim.fn.fnamemodify(name, ":~:.")
end

local function file_item(path)
    return { kind = "file", path = path, display = vim.fn.fnamemodify(path, ":~:.") }
end

local function buffer_item(b)
    return { kind = "buffer", bufnr = b, display = buffer_display(b) }
end

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
            local items = {}
            for _, p in ipairs(entries) do
                if vim.fn.isdirectory(p) == 0 then
                    table.insert(items, file_item(p))
                end
            end
            table.sort(items, function(a, b) return a.path < b.path end)
            return items
        end,
    },
    {
        name = "Open buffers (most recent first)",
        fn = function()
            local entries = {}
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
                    local info = vim.fn.getbufinfo(b)[1]
                    table.insert(entries, { bufnr = b, lastused = info and info.lastused or 0 })
                end
            end
            table.sort(entries, function(a, b) return a.lastused > b.lastused end)
            local items = {}
            for _, e in ipairs(entries) do
                table.insert(items, buffer_item(e.bufnr))
            end
            return items
        end,
    },
}

local function current_index(items)
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_path = vim.api.nvim_buf_get_name(cur_buf)
    if cur_path ~= "" then
        cur_path = vim.fn.fnamemodify(cur_path, ":p")
    end
    for i, item in ipairs(items) do
        if item.kind == "buffer" and item.bufnr == cur_buf then
            return i
        elseif item.kind == "file" and cur_path ~= "" and item.path == cur_path then
            return i
        end
    end
    return 1
end

local function activate(item)
    if item.kind == "buffer" then
        if vim.api.nvim_buf_is_valid(item.bufnr) then
            vim.cmd("buffer " .. item.bufnr)
        end
    elseif item.kind == "file" then
        vim.cmd("edit " .. vim.fn.fnameescape(item.path))
    end
end

local function open_picker(items, target)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local previewer = previewers.new_buffer_previewer({
        title = "Preview",
        define_preview = function(self, entry)
            local item = entry.value
            local lines, ft
            if item.kind == "file" then
                local ok, data = pcall(vim.fn.readfile, item.path)
                if ok then
                    lines = data
                    ft = vim.filetype.match({ filename = item.path }) or ""
                end
            elseif item.kind == "buffer" and vim.api.nvim_buf_is_loaded(item.bufnr) then
                lines = vim.api.nvim_buf_get_lines(item.bufnr, 0, -1, false)
                ft = vim.bo[item.bufnr].filetype
            end
            if lines then
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                if ft and ft ~= "" then
                    vim.bo[self.state.bufnr].filetype = ft
                end
            end
        end,
    })

    pickers.new({}, {
        prompt_title = "Scroller",
        initial_mode = "normal",
        default_selection_index = target,
        finder = finders.new_table({
            results = items,
            entry_maker = function(item)
                return { value = item, display = item.display, ordinal = item.display }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewer,
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local sel = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if sel and sel.value then activate(sel.value) end
            end)
            return true
        end,
    }):find()
end

function M.pick()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Scroller presets",
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
                end
            end)
            return true
        end,
    }):find()
end

local function open(delta)
    if not M.current_updater then
        vim.notify("No scroller preset selected (use <leader>pl)", vim.log.levels.WARN)
        return
    end
    local items = M.current_updater()
    if not items or #items == 0 then
        vim.notify("Scroller list is empty", vim.log.levels.WARN)
        return
    end
    local n = #items
    local target = ((current_index(items) - 1 + delta) % n + n) % n + 1
    open_picker(items, target)
end

function M.next() open(1) end
function M.prev() open(-1) end

return M
