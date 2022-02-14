debug_utils = require('plenary.debug_utils')

local function get_path_relative_to_source_dir(filename)
    local sourced_file = debug_utils.sourced_filepath()
    local base_dir = vim.fn.fnamemodify(sourced_file, ":p:h")

    return base_dir .. "/" .. filename
end

local function read_file_contents(filename, relative)
    if relative then
        filename = get_path_relative_to_source_dir(filename)
    end

    print('filename::' .. filename)

    local f = io.open(filename, 'r')
    content = f:read('a')
    f.close()
    return content
end

return {
    read_file_contents = read_file_contents
}
