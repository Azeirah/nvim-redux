local redux_picker = require('nvim-redux.telescope-redux-picker')
local utils = require('nvim-redux.utils')
local rgts_query = require('nvim-redux.rgts_query')
local telescope = require('telescope.builtin')

local function raw_redux_actions_in_reducers()
    local switch_case_names_query = utils.read_file_contents('queries/query_switch.tsq', true)
    local captures = rgts_query.query_for_telescope("action\\.type", switch_case_names_query)

    redux_picker(captures)
end

local function find_dispatch_calls()
    telescope.live_grep({
        grep_string="\\s+dispatch\\s*\\([a-zA-Z0-9_ {}\\[\\]]",
        prompt_title="redux dispatch calls",
        additional_args=function()
            return {"-g*ts", "-g*js", "-g*tsx", "-g*jsx"}
        end})
end

return {
    list_actions_in_switch_reducer = raw_redux_actions_in_reducers,
    list_dispatch_calls = find_dispatch_calls
}
