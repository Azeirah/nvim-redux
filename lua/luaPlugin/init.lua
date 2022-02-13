local redux_picker = require('telescope-redux-picker')
local utils = require('utils')
local rgts_query = require('rgts_query')

local function do_the_thing(cwd)
    local switch_case_names_query = utils.read_file_contents('query_switch.tsq')
    local captures = rgts_query.query_for_telescope("action\\.type", switch_case_names_query, cwd)

    redux_picker(captures)
end

return {
    list_actions_in_switch_reducer = do_the_thing
}
