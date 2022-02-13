local redux_picker = require('nvim-redux.telescope-redux-picker')
local utils = require('nvim-redux.utils')
local rgts_query = require('nvim-redux.rgts_query')

local function do_the_thing(cwd)
    local switch_case_names_query = utils.read_file_contents('query_switch.tsq')
    local captures = rgts_query.query_for_telescope("action\\.type", switch_case_names_query, cwd)

    redux_picker(captures)
end

return {
    list_actions_in_switch_reducer = do_the_thing
}