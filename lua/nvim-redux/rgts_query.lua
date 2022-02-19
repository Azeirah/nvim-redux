local Job = require('plenary.job')
local utils = require('nvim-redux.utils')

-- query: string, regex for ripgrep.
-- cwd: optional string, directory to run ripgrep in
-- Ripgrep command uses -e flag for regex input.
-- Searches only js and adjacent files (.js, .jsx, .ts, .tsx)
local function rg_query_files(query)
    local rg = Job:new({
        command = 'rg',
        args = { 
            "-e", query,
            "-g*js", "-g*ts", "-g*jsx", "-g*tsx",
            "-l",
            -- don't remove the ./
            -- https://github.com/BurntSushi/ripgrep/issues/1892#issuecomment-860270717
            "./"
        }
    })
    rg:sync()
    return rg:result()
end

local function ts_capture(filename, query)
    local language = "javascript"
    local switch_cases = {}

    local code = utils.read_file_contents(filename)
    local parser = vim.treesitter.get_string_parser(code, language)
    local tree = (parser:parse() or {})[1]
    if not tree then
        -- TODO: This should be a debug message of sorts
        print "Failed to parse tree"
        return
    end
    local root = tree:root()
    local q = vim.treesitter.parse_query(language, query)
    for id, node, matches in q:iter_captures(root, code, start_row, end_row) do
        local text = vim.treesitter.query.get_node_text(node, code)
        local type = node:type()
        local start_row, start_col, end_row, end_col = node:range()
        -- TODO: this predicate needs to be abstracted
        if type:find('string') then
            switch_cases[#switch_cases+1] = {
                path = filename,
                text = text,
                lnum = start_row + 1,
                col = start_col,
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col,
            }
        end
    end

    return switch_cases
end

-- Executes a given treesitter query for all given code.
-- The query must specify captures, otherwise this function will not return anything
-- files: array of filenames to parse and execute the given query in
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
local function ts_query_captures(files, treesitter_query)
    local switch_cases = {}

    for _, filename in ipairs(files) do
        for _, value in ipairs(ts_capture(filename, treesitter_query)) do
            table.insert(switch_cases, value)
        end
    end

    return switch_cases
end

local function super_cool_high_level_api(rg_query, ts_query, cwd)
    local code_contents = {}
    return ts_query_captures(rg_query_files(rg_query, cwd), ts_query)
end

return {
    rg_query_files = rg_query_files,
    ts_query_captures = ts_query_captures,
    query_for_telescope = super_cool_high_level_api,
    ts_capture = ts_capture
}
