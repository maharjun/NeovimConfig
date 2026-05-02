local M = {}

local MAX_RESULTS = 50

--- Toggle timing logs to `:messages`. Flip with `:lua require("arjun.telescope_workspace_symbols").profile = false`.
M.profile = true

local function ms_since(t0)
    return (vim.uv.hrtime() - t0) / 1e6
end

local function make_requester(bufnr, opts)
    local channel = require("plenary.async.control").channel
    local utils = require("telescope.utils")
    local cancel = function() end

    return function(prompt)
        local t_start = vim.uv.hrtime()

        local tx, rx = channel.oneshot()
        cancel()
        cancel = vim.lsp.buf_request_all(bufnr, "workspace/symbol", { query = prompt }, tx)

        local results = rx()
        local t_lsp = ms_since(t_start)

        local raw_count = 0
        local locations = {}
        for client_id, client_res in pairs(results) do
            if client_res.result ~= nil then
                raw_count = raw_count + #client_res.result
                local client = vim.lsp.get_client_by_id(client_id)
                local items = vim.lsp.util.symbols_to_items(
                    client_res.result,
                    bufnr,
                    client and client.offset_encoding
                )
                vim.list_extend(locations, items)
            end
        end

        if not vim.tbl_isempty(locations) then
            locations = utils.filter_symbols(locations, opts) or {}
        end
        local filtered_count = #locations

        -- Cap before handing to telescope: rendering thousands of entries dominates,
        -- and the LSP returns symbols in server-relevance order.
        if #locations > MAX_RESULTS then
            local trimmed = {}
            for i = 1, MAX_RESULTS do
                trimmed[i] = locations[i]
            end
            locations = trimmed
        end

        local t_total = ms_since(t_start)
        local t_post = t_total - t_lsp

        if M.profile then
            print(string.format(
                "[ws-symbols] q=%q lsp=%.0fms post=%.0fms total=%.0fms raw=%d filtered=%d capped=%d",
                prompt, t_lsp, t_post, t_total, raw_count, filtered_count, #locations
            ))
        end

        return locations
    end
end

--- Open a capped LSP dynamic workspace symbols picker.
--- @param opts table|nil Forwarded to telescope; `symbols` filters by kind (e.g. {"function","method"}).
function M.open(opts)
    opts = opts or {}
    local bufnr = vim.api.nvim_get_current_buf()
    opts.bufnr = bufnr

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local sorters = require("telescope.sorters")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")

    pickers.new(opts, {
        prompt_title = opts.prompt_title or ("Workspace symbols (top " .. MAX_RESULTS .. ")"),
        finder = finders.new_dynamic({
            entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
            fn = make_requester(bufnr, opts),
        }),
        previewer = conf.qflist_previewer(opts),
        sorter = sorters.highlighter_only(opts),
        attach_mappings = function(_, map)
            map("i", "<c-space>", actions.to_fuzzy_refine)
            return true
        end,
    }):find()
end

-- Cached path: basedpyright returns 0 for empty query, so we sweep single-char
-- queries across [a-z 0-9 _] (every Python identifier contains at least one)
-- to materialize the full symbol table once, then filter client-side forever.

M.cache_ttl_ms = 10 * 60 * 1000
M.cache = { items = nil, at = 0, root = nil }

local function alphabet()
    local chars = {}
    for c = string.byte("a"), string.byte("z") do
        chars[#chars + 1] = string.char(c)
    end
    for c = string.byte("0"), string.byte("9") do
        chars[#chars + 1] = string.char(c)
    end
    chars[#chars + 1] = "_"
    return chars
end

local function dedup_key(item)
    return string.format(
        "%s:%d:%d:%s",
        item.filename or "", item.lnum or 0, item.col or 0, item.text or ""
    )
end

local function root_for(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    for _, c in ipairs(clients) do
        if c.config and c.config.root_dir then
            return c.config.root_dir
        end
    end
    return vim.fn.getcwd()
end

--- Sweep [a-z 0-9 _] one character at a time, union into a deduped item list.
--- @param bufnr integer Buffer to use for the LSP request.
--- @param on_done fun(items: table[], elapsed_ms: number) Called once when sweep completes.
function M.warm(bufnr, on_done)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local chars = alphabet()
    local seen, items = {}, {}
    local i = 0
    local t_start = vim.uv.hrtime()

    local function step()
        i = i + 1
        if i > #chars then
            local elapsed = ms_since(t_start)
            on_done(items, elapsed)
            return
        end
        local ch = chars[i]
        vim.notify(
            string.format("Indexing workspace symbols [%d/%d] %q (%d so far)", i, #chars, ch, #items),
            vim.log.levels.INFO
        )
        vim.lsp.buf_request_all(bufnr, "workspace/symbol", { query = ch }, function(results)
            for client_id, client_res in pairs(results) do
                if client_res.result then
                    local client = vim.lsp.get_client_by_id(client_id)
                    local part = vim.lsp.util.symbols_to_items(
                        client_res.result,
                        bufnr,
                        client and client.offset_encoding
                    )
                    for _, item in ipairs(part) do
                        local k = dedup_key(item)
                        if not seen[k] then
                            seen[k] = true
                            items[#items + 1] = item
                        end
                    end
                end
            end
            vim.schedule(step)
        end)
    end
    step()
end

local function cache_is_fresh(bufnr)
    if not M.cache.items then return false end
    if (vim.uv.now() - M.cache.at) >= M.cache_ttl_ms then return false end
    if M.cache.root ~= root_for(bufnr) then return false end
    return true
end

local function open_static(items, opts)
    opts = opts or {}
    local utils = require("telescope.utils")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local conf = require("telescope.config").values

    local filtered = items
    if opts.symbols then
        filtered = utils.filter_symbols(items, opts) or {}
    end

    pickers.new(opts, {
        prompt_title = opts.prompt_title or string.format("Workspace symbols (cached, %d)", #filtered),
        finder = finders.new_table({
            results = filtered,
            entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
        }),
        sorter = conf.generic_sorter(opts),
        previewer = conf.qflist_previewer(opts),
    }):find()
end

--- Open a fully-cached workspace symbols picker. First call sweeps a-z/0-9/_ to
--- populate the cache (~20s on a moderate workspace); subsequent calls within
--- `cache_ttl_ms` are instant and filter client-side.
--- @param opts table|nil `symbols` filters by kind; passed to telescope.
function M.open_cached(opts)
    opts = opts or {}
    local bufnr = vim.api.nvim_get_current_buf()
    opts.bufnr = bufnr

    if cache_is_fresh(bufnr) then
        open_static(M.cache.items, opts)
        return
    end

    local root = root_for(bufnr)
    vim.notify("Indexing workspace symbols (one-time per session)...", vim.log.levels.INFO)
    M.warm(bufnr, function(items, elapsed_ms)
        M.cache.items = items
        M.cache.at = vim.uv.now()
        M.cache.root = root
        vim.notify(
            string.format("Cached %d symbols in %.0fms", #items, elapsed_ms),
            vim.log.levels.INFO
        )
        open_static(items, opts)
    end)
end

--- Drop the cache; next `open_cached` will re-sweep.
function M.invalidate()
    M.cache = { items = nil, at = 0, root = nil }
    vim.notify("Workspace symbol cache cleared", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("WsSymbolCacheClear", function() M.invalidate() end, {})
vim.api.nvim_create_user_command("WsSymbolCacheWarm", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local root = root_for(bufnr)
    M.warm(bufnr, function(items, elapsed_ms)
        M.cache.items = items
        M.cache.at = vim.uv.now()
        M.cache.root = root
        vim.notify(
            string.format("Cached %d symbols in %.0fms", #items, elapsed_ms),
            vim.log.levels.INFO
        )
    end)
end, {})

-- Progressive path: cache grows lazily as the user types. Each new first-letter
-- triggers an async LSP fetch (not cancelled mid-flight); the prompt filters
-- whatever is already in cache, and the picker refreshes when results arrive.
--
-- Mirrors the fd|fzf|head pattern in arjun.telescope_fast_find: do the fuzzy
-- match + cap *before* handing entries to telescope, since telescope's sorter
-- on the full cache is the bottleneck.

local TOP_N = 50

local function head(list, n)
    if #list <= n then return list end
    local out = {}
    for i = 1, n do out[i] = list[i] end
    return out
end

-- vim.lsp.util.symbols_to_items formats `text` as "[Kind] name". Matching on
-- `text` directly makes "func" pull in every [Function]; key on `name` instead.
local function strip_kind_prefix(text)
    return (text or ""):gsub("^%[[^%]]+%]%s*", "")
end

local function rank_and_cap(items, prompt, n)
    if not prompt or prompt == "" then
        return head(items, n)
    end
    local ok, ranked = pcall(vim.fn.matchfuzzy, items, prompt, { key = "name" })
    if not ok or type(ranked) ~= "table" then
        return head(items, n)
    end
    return head(ranked, n)
end

-- Per-letter buckets: `by_letter[c]` is the deduped list of symbols
-- `workspace/symbol{query=c}` returned. Typing "foo" filters bucket["f"]
-- locally; typing "bar" filters bucket["b"]. Each bucket is independently
-- refreshed (full replacement) on the corresponding first-letter event.
M.progressive = { by_letter = {}, root = nil }

--- Toggle debug logs to `:messages` for the progressive picker pipeline.
M.debug_progressive = false

local function dlog(fmt, ...)
    if not M.debug_progressive then return end
    print("[ws-syms] " .. string.format(fmt, ...))
end

local function reset_progressive_if_needed(root)
    if M.progressive.root ~= root then
        M.progressive = { by_letter = {}, root = root }
    end
end

--- Open a progressively-populated workspace symbols picker.
--- @param opts table|nil `symbols` filters by kind; passed to telescope.
function M.open_progressive(opts)
    opts = opts or {}
    local bufnr = vim.api.nvim_get_current_buf()
    local root = root_for(bufnr)
    reset_progressive_if_needed(root)
    opts.bufnr = bufnr

    local utils = require("telescope.utils")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local sorters = require("telescope.sorters")
    local conf = require("telescope.config").values

    local picker_ref           ---@type table|nil
    local in_flight_cancels = {} ---@type function[]
    local prev_prompt = ""

    -- Items for the bucket matching `prompt`'s first letter, filtered by
    -- the current kind selection.
    local function visible_items(prompt)
        local first = (prompt or ""):sub(1, 1):lower()
        if first == "" then return {} end
        local bucket = M.progressive.by_letter[first]
        if not bucket then return {} end
        if opts.symbols then
            -- filter_symbols mutates opts.symbols (lowercases it). Pass a
            -- copy of the kinds list each call so repeated picker opens
            -- stay safe.
            return utils.filter_symbols(bucket,
                { symbols = vim.deepcopy(opts.symbols) }) or {}
        end
        return bucket
    end

    -- Replace `by_letter[letter]` with the fresh LSP response. Full
    -- replacement (not merge) ensures stale entries from a prior analysis
    -- context — e.g. an LSP restart after a venv switch where the server
    -- now indexes a different file tree — drop out cleanly. The local
    -- `seen` set dedupes across multiple LSP clients in this single
    -- response (buf_request_all hits every attached server) but isn't
    -- kept around afterwards — there's nothing to dedupe against once
    -- the bucket is finalized.
    local function ingest(letter, results)
        local new_items, seen = {}, {}
        for client_id, client_res in pairs(results or {}) do
            if client_res.result then
                local client = vim.lsp.get_client_by_id(client_id)
                local items = vim.lsp.util.symbols_to_items(
                    client_res.result, bufnr,
                    client and client.offset_encoding
                )
                for _, item in ipairs(items) do
                    local k = dedup_key(item)
                    if not seen[k] then
                        seen[k] = true
                        item.name = strip_kind_prefix(item.text)
                        new_items[#new_items + 1] = item
                    end
                end
            end
        end
        M.progressive.by_letter[letter] = new_items
        return #new_items > 0
    end

    -- Forward-declared so build_finder's closure binds to this local rather
    -- than a (nil) global; maybe_fetch is assigned further down.
    local maybe_fetch

    -- Build a fresh dynamic finder pointing at the same fn closure.
    local function build_finder()
        dlog("build_finder")
        return finders.new_dynamic({
            entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
            fn = function(prompt)
                local items = visible_items(prompt)
                dlog("fn called: prompt=%q bucket=%d", prompt or "", #items)
                maybe_fetch(prompt)
                local out = rank_and_cap(items, prompt, TOP_N)
                dlog("fn returning: %d items", #out)
                return out
            end,
        })
    end

    -- Re-run the finder against the (now larger) cache. Pass a new finder
    -- to picker:refresh — that goes through the close + reassign path and
    -- then signals the main loop, which is the same trick telescope's own
    -- git pickers use for live updates from async sources.
    local function refresh_if_open()
        dlog("refresh_if_open: picker_ref=%s", tostring(picker_ref ~= nil))
        if not picker_ref then return end
        local pb = picker_ref.prompt_bufnr
        if not pb or not vim.api.nvim_buf_is_valid(pb) then
            dlog("refresh_if_open: invalid prompt_bufnr")
            return
        end
        local ok, err = pcall(function()
            picker_ref:refresh(build_finder(), { reset_prompt = false })
        end)
        dlog("refresh_if_open: refresh ok=%s err=%s", tostring(ok), tostring(err))
    end

    -- Called on every keystroke. Fires an LSP fetch only when the prompt
    -- transitions from empty to non-empty (i.e. the user just typed the first
    -- character of a fresh search). Every subsequent character within the same
    -- non-empty span filters the existing cache locally; clearing back to
    -- empty and typing again is another first-character event.
    maybe_fetch = function(prompt)
        local curr = prompt or ""
        local just_started = (prev_prompt == "" and curr ~= "")
        dlog("maybe_fetch: curr=%q prev=%q just_started=%s",
            curr, prev_prompt, tostring(just_started))
        prev_prompt = curr
        if not just_started then return end

        local first = curr:sub(1, 1):lower()
        if not first:match("[%w_]") then
            dlog("maybe_fetch: non-identifier first char %q, skipping", first)
            return
        end

        dlog("maybe_fetch: firing LSP for %q", first)
        local t0 = vim.uv.hrtime()
        local cancel = vim.lsp.buf_request_all(
            bufnr, "workspace/symbol", { query = first },
            function(results)
                local elapsed = (vim.uv.hrtime() - t0) / 1e6
                local raw = 0
                for _, r in pairs(results or {}) do
                    if r.result then raw = raw + #r.result end
                end
                local has_items = ingest(first, results)
                local bucket = M.progressive.by_letter[first]
                dlog("LSP %q done: %.0fms raw=%d has_items=%s bucket=%d",
                    first, elapsed, raw, tostring(has_items),
                    bucket and #bucket or 0)
                vim.schedule(function()
                    dlog("scheduled refresh fired")
                    refresh_if_open()
                end)
            end
        )
        in_flight_cancels[#in_flight_cancels + 1] = cancel
    end

    local picker = pickers.new(opts, {
        prompt_title = opts.prompt_title or string.format("Workspace symbols (progressive, top %d)", TOP_N),
        finder = build_finder(),
        -- highlighter_only: skip telescope's ranking pass; we already ordered
        -- via matchfuzzy and capped to TOP_N so its O(n*m) sort would just be
        -- redundant work on entries we've already chosen.
        sorter = sorters.highlighter_only(opts),
        previewer = conf.qflist_previewer(opts),
    })
    picker_ref = picker
    picker:find()

    -- Cancel in-flight requests only when the picker actually closes.
    -- Telescope wipes its prompt buffer on close, so BufWipeout is the hook.
    -- IMPORTANT: this must run AFTER picker:find() — prompt_bufnr is only
    -- assigned inside find() (pickers.lua:546). If we register earlier,
    -- buffer=nil falls back to pattern="*" and the autocmd fires on the
    -- first BufWipeout anywhere in nvim, nil'ing picker_ref immediately.
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = picker.prompt_bufnr,
        once = true,
        callback = function()
            for _, c in pairs(in_flight_cancels) do
                pcall(c)
            end
            in_flight_cancels = {}
            picker_ref = nil
        end,
    })
end

vim.api.nvim_create_user_command("WsSymbolProgressiveClear", function()
    M.progressive = { by_letter = {}, root = nil }
    vim.notify("Progressive symbol cache cleared", vim.log.levels.INFO)
end, {})

return M
