local rgts = require('nvim-redux.rgts_query')
local utils = require('nvim-redux.utils')

local dummy_js = [[
switch (action.type) {
    case "bla":
        break;
    case "blaa":
        break;
    default:
        return;
}
]]

describe('captures', function()
    it('should find two switch-case-string captures in provided example code', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture(dummy_js, q)
        assert.are.equal(2, #captures)
    end)

    it('should find the strings "bla" and "blaa"', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture(dummy_js, q)
        local first = captures[1]
        local second = captures[2]

        assert.are.equal('"bla"', first.text)
        assert.are.equal('"blaa"', second.text)
    end)

    it('should contain col, lnum for telescope to jump to correct context', function() 
        local q = utils.read_file_contents('lua/nvim-redux/queries/query_switch.tsq')
        local captures = rgts.ts_capture(dummy_js, q)

        local capture = captures[1]
        assert.is_not_nil(capture.col)
        assert.is_not_nil(capture.lnum)
    end)
end)