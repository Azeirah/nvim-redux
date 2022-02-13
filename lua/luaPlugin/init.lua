local Job = require('plenary.job')
local ts_utils = require('nvim-treesitter.ts_utils')

local function read_file_contents(filename)
    f = io.open(filename, 'r')
    content = f:read('a')
    f.close()
    return content
end

local switch_case_names_query = read_file_contents('query_switch.tsq')

local function list_files_with_action_dot_type(cwd)
    local cwd = cwd or vim.loop.cwd()
    local rg = Job:new({
        command = 'rg',
        args = { 
            "-e",  "action\\.type",
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

local function collect_switch_cases(files)
    -- collect all switch statements alongside filename:linenum in a list
    -- for each file:
    --      open()
    --      parse()
    --      query()
    --      extract results to big list
    local language = "javascript"
    local switch_cases = {}
    for i, filename in ipairs(files) do
        local contents = read_file_contents(filename)
        local parser = vim.treesitter.get_string_parser(contents, language)
        local tree = (parser:parse() or {})[1]
        if not tree then
            print "Failed to parse tree"
            return
        end
        local root = tree:root()
        local q = vim.treesitter.parse_query(language, switch_case_names_query)
        for id, node, matches in q:iter_captures(root, contents, start_row, end_row) do
            local text = vim.treesitter.query.get_node_text(node, contents)
            local type = node:type()
            local start_row, start_col, end_row, _ = node:range()
            if type:find('string') then
                switch_cases[#switch_cases+1] = {
                    path = filename,
                    text = text,
                    lnum = start_row + 1,
                    col = start_col
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

local edit_buffer
do
  local map = {
    edit = "buffer",
    new = "sbuffer",
    vnew = "vert sbuffer",
    tabedit = "tab sb",
  }

  edit_buffer = function(command, bufnr)
    command = map[command]
    if command == nil then
      error "There was no associated buffer command"
    end
    vim.cmd(string.format("%s %d", command, bufnr))
  end
end

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
    local files = list_files_with_action_dot_type(cwd)
    local output = collect_switch_cases(files)
    redux_picker(output)
end

return {
    list = do_the_thing
}
