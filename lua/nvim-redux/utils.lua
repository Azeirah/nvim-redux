local function read_file_contents(filename)
    local f = io.open(filename, 'r')
    content = f:read('a')
    f.close()
    return content
end

return {
    read_file_contents = read_file_contents
}
