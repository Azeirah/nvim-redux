local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')
local ns_previewer = vim.api.nvim_create_namespace "telescope.previewers"

function make_entry_for_treesitter_captures(entry) 
    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 5 },
            { width = 70 },
            { width = 100 },
            { remaining = true } 
        }
    })
    return {
        value = entry,
        display = function(entry) 
            return displayer({entry.lnum, entry.filename, entry.value.text})
        end,
        ordinal = entry.text,
        filename = entry.path,
        col = entry.col,
        lnum = entry.lnum,
        start_row = entry.start_row,
        start_col = entry.start_col,
        end_row = entry.end_row,
        end_col = entry.end_col,
    }
end

local redux_picker = function (results, opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "redux_actions",
        finder = finders.new_table {
            results = results,
            entry_maker = make_entry_for_treesitter_captures
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
                            vim.cmd("norm! gg")
                            vim.cmd("/" .. entry.value.text)
                            vim.cmd("set cursorline")
                            vim.cmd('nohl')
                            vim.cmd("norm! zz")
                        end)
                    end,
                })
            end
        })
    }):find()
end

return {
    redux_picker = redux_picker,
    make_entry_for_treesitter_captures = make_entry_for_treesitter_captures
}

