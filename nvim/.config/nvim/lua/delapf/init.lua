require('delapf.remap')
require('delapf.set')
require('delapf.lazy')
require('delapf.usercommands')
require('delapf.globals')
-- require('delapf.packer')

-- TODO: move elsewhere
local additional_dirs = {  -- load additional lua files
    '~/.nvim_ext',
}
-- package.path = '/home/dev/.nvim_ext/?.lua;' .. package.path
-- package.path = '/?.lua' .. package.path
if vim.fn.empty(additional_dirs) ~= 1 then
    for _, dir in ipairs(additional_dirs) do
        dir = vim.fn.expand(dir)
        if vim.fn.isdirectory(dir) ~= 0 then
            package.path = dir .. '/?.lua;' .. package.path
            -- vim.opt.rtp:append(dir)
            -- print(vim.inspect(vim.api.nvim_list_runtime_paths()))
            local files = vim.fn.glob(dir .. '/**/*.lua', false, true, true)
            -- print(vim.inspect(files))
            for _, file in ipairs(files) do
                file = string.sub(file, string.len(dir)+2, -5)
                file = string.gsub(file, '/', '.')
                require(file)
            end
        end
    end
end

-- TODO: is there a way to make work without making global?
function Yank(text)
    local escape = vim.fn.system('yank.sh', text)
    if vim.v.shell_error ~= 0 then
        error(escape)
    else
        vim.fn.writefile(escape, '/dev/tty', 'b')
    end
end
vim.keymap.set('n', '<leader>y', 'y:lua Yank(@0)<CR>')
