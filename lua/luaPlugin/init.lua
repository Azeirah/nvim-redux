local Job = require('plenary.job')
local ts_utils = require('nvim-treesitter.ts_utils')

local function read_file_contents(filename)
    f = io.open(filename, 'r')
    content = f:read('a')
    f.close()
    return content
end

-- query: string, regex for ripgrep.
-- cwd: optional string, directory to run ripgrep in
-- Ripgrep command uses -e flag for regex input.
-- Searches only js and adjacent files (.js, .jsx, .ts, .tsx)
local function rg_list_javascript_files_containing_regex(query, cwd, filetypes)
    local cwd = cwd or vim.loop.cwd()

    local rg = Job:new({
        command = 'rg',
        args = { 
            "-e", query,
            "-g*js", "-g*ts", "-g*jsx", "-g*tsx",
            "-l",
            cwd,
            -- don't remove the ./
            -- https://github.com/BurntSushi/ripgrep/issues/1892#issuecomment-860270717
            "./"
        }
    })
    rg:sync()
    return rg:result()
end

local function list_files_with_action_dot_type(cwd)
    return rg_list_javascript_files_containing_regex("action\\.type", cwd)
end

-- Executes a given treesitter query in all specified files.
-- The query must specify captures, otherwise this function will not return anything
-- files: array of filenames to parse and execute query for.
-- treesitter_query: A treesitter query for JavaScript containing captures.
-- Returns an array of captures. Each capture has the following fields
--      node = treesitter node corresponding to capture found by treesitter
--      path = filename from files
--      text = node text
--      lnum = line number where node is found (node.start_row)
--      col = column in bytes where node is found on the line (node.start_col)
--      start_row = start_row,
--      start_col = start_col,
--      end_row = end_row,
--      end_col = end_col
local function treesitter_captures_in_files(files, treesitter_query)
    local language = "javascript"
    local switch_cases = {}
    for i, filename in ipairs(files) do
        local contents = read_file_contents(filename)
        local parser = vim.treesitter.get_string_parser(contents, language)
        local tree = (parser:parse() or {})[1]
        if not tree then
            -- TODO: This should be a debug message of sorts
            print "Failed to parse tree"
            return
        end
        local root = tree:root()
        local q = vim.treesitter.parse_query(language, treesitter_query)
        for id, node, matches in q:iter_captures(root, contents, start_row, end_row) do
            local text = vim.treesitter.query.get_node_text(node, contents)
            local type = node:type()
            local start_row, start_col, end_row, _ = node:range()
            if type:find('string') then
                switch_cases[#switch_cases+1] = {
                    path = filename,
                    text = text,
                    lnum = start_row + 1,
                    col = start_col,
                    start_row = start_row,
                    start_col = start_col,
                    end_row = end_row,
                    end_col = end_col
                }
            end
        end
    end

    return switch_cases
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')

local redux_picker = function (results, opts)
    opts = opts or {}
    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 5 },
            { width = 70 },
            { width = 100 },
            { remaining = true } 
        }
    })
    pickers.new(opts, {
        prompt_title = "redux_actions",
        finder = finders.new_table {
            results = results,
            entry_maker = function (entry) 
                display = entry.path .. "    " .. entry.text
                return {
                    value = entry,
                    display = function(entry) 
                        return displayer({entry.lnum, entry.filename, entry.value.text})
                    end,
                    ordinal = entry.text,
                    filename = entry.path,
                    lnum = entry.lnum,
                    col = entry.col
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        previewer = previewers.new_buffer_previewer({
            title = "Redux action preview",
            get_buffer_by_name = function (_, entry)
                return entry.filename
            end,
            define_preview = function(self, entry, status)
                local bufnr = self.state.bufnr
                local p = entry.filename
                local lnum = entry.lnum
                local winid = self.state.winid

                conf.buffer_previewer_maker(p, self.state.bufnr, {
                    bufname = self.state.bufname,
                    winid = self.state.winid,
                    preview = opts.preview,
                    callback = function(bufnr)
                        vim.api.nvim_buf_call(bufnr, function () 
                            vim.cmd "norm! gg"
                            vim.cmd( "/" .. entry.value.text)
                            vim.cmd "norm! zz"
                        end)
                    end,
                })
            end
        })
    }):find()
end

local function do_the_thing(cwd)
    local switch_case_names_query = read_file_contents('query_switch.tsq')
    local files = list_files_with_action_dot_type(cwd)
    local output = treesitter_captures_in_files(files, switch_case_names_query)
    redux_picker(output)
end

return {
    list = do_the_thing
}
