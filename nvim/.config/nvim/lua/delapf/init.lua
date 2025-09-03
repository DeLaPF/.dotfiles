-- TODO: there is much left to be desired from this current config
-- Clean up packer bits
-- Move over to more "lazy" way

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
