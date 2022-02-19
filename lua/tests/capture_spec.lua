local rgts = require('nvim-redux.rgts_query')
local utils = require('nvim-redux.utils')

describe('captures', function()
    it('should find two switch-case-string captures in provided example code', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q)
        assert.are.equal(2, #captures)
    end)

    it('should find the strings "bla" and "blaa"', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q)
        local first = captures[1]
        local second = captures[2]

        assert.are.equal('"bla"', first.text)
        assert.are.equal('"blaa"', second.text)
    end)

    it('should contain col, lnum for telescope to jump to correct context', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture('lua/tests/example_code_with_switch.js', q)

        local capture = captures[1]
        assert.is_not_nil(capture.col)
        assert.is_not_nil(capture.lnum)
    end)
end)

describe('ts_query_captures', function()
    it('should return captures', function() 
        local action_query = utils.read_file_contents('queries/query_switch.tsq', true)
        local entries = rgts.ts_query_captures({'lua/tests/example_code_with_switch.js'}, action_query)

        assert.is.equal(#entries, 2)
    end)
end)
