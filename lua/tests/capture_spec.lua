local rgts = require('nvim-redux.rgts_query')
local utils = require('nvim-redux.utils')

describe('captures', function()
    it('should find two switch-case-string captures in provided example code', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q, {"reducer"})
        assert.are.equal(2, #captures)
    end)

    it('should find the strings "bla" and "blaa"', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q, {"reducer"})
        local first = captures[1]
        local second = captures[2]

        assert.are.equal('"bla"', first.text)
        assert.are.equal('"blaa"', second.text)
    end)

    it('should contain col, lnum for telescope to jump to correct context', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q, {"reducer"})

        local capture = captures[1]
        assert.is_not_nil(capture.col)
        assert.is_not_nil(capture.lnum)
    end)

    it('should capture all reducers in react-toolkit slices', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_slice.scm')
        local captures = rgts.ts_capture('lua/tests/redux_slice.js', q, {'reducer'})

        assert.is.equal(7, #captures)
    end)
end)

describe('ts_query_captures', function()
    it('should return captures', function() 
        local action_query = utils.read_file_contents('queries/query_switch.tsq', true)
        local entries = rgts.ts_query_captures({'lua/tests/example_code_with_switch.js'}, action_query, {'reducer'})

        assert.is.equal(#entries, 2)
    end)

    it('should bla', function() 
        local switch_case_names_query = utils.read_file_contents('queries/query_switch.tsq', true)
        local captures = rgts.query_for_telescope("action\\.type", switch_case_names_query, {'reducer'})

        require('nvim-redux.telescope-redux-picker').redux_picker(captures)

        local redux_toolkit_slices_query = utils.read_file_contents('queries/query_slice.scm', true)
        local toolkit_slices_captures = rgts.query_for_telescope("createSlice", redux_toolkit_slices_query, {'reducer'})

        -- concat both capture results into one. Two queries add up to one result.
        for _, v in ipairs(toolkit_slices_captures) do
            table.insert(captures, v)
        end

        require('nvim-redux.telescope-redux-picker').redux_picker(captures)
    end)
end)
