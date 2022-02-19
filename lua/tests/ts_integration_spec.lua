local telescope_redux_picker = require('nvim-redux.telescope-redux-picker')

describe('treesitter_entry_maker', function () 
    it('should contain col, lnum for telescope to jump to correct context', function()
        local dummy_capture = {
            path = "dummypath/dummy.js",
            text = '"hi"',
            lnum = 5,
            col = 5,
            start_row = 0,
            start_col = 0,
            end_row = 0,
            end_col = 0,
        }

        local telescope_entry = telescope_redux_picker.make_entry_for_treesitter_captures(dummy_capture)
        assert.is.equal(telescope_entry.col, dummy_capture.col)
        assert.is.equal(telescope_entry.lnum, dummy_capture.lnum)
    end)
end)
