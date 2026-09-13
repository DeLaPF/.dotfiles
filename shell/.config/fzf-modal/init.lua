vim.opt.cmdheight = 0
vim.opt.fillchars:append({ horiz = " ", horizup = " ", horizdown = " " })
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.termguicolors = true
vim.opt.timeoutlen = 250

local input = assert(vim.env.FZF_MODAL_INPUT, "FZF_MODAL_INPUT is not set")
local output = assert(vim.env.FZF_MODAL_OUTPUT, "FZF_MODAL_OUTPUT is not set")
local args_path = assert(vim.env.FZF_MODAL_ARGS, "FZF_MODAL_ARGS is not set")
local socket = assert(vim.env.FZF_MODAL_SOCKET, "FZF_MODAL_SOCKET is not set")

local args_file = assert(io.open(args_path, "rb"))
local encoded_args = args_file:read("*a")
args_file:close()

local fzf_args =
  vim.split(encoded_args, "\0", { plain = true, trimempty = true })
local select_action = ("enter:execute-silent(printf '%%s\\n' {+} > %s)+accept"):format(
  vim.fn.shellescape(output)
)
vim.list_extend(fzf_args, {
  "--bind",
  select_action,
  "--bind",
  "start:hide-input",
  "--listen=" .. socket,
  "--margin",
  "0,0,1,0",
})

local terminal_window = vim.api.nvim_get_current_win()
local query_buffer = vim.api.nvim_create_buf(false, true)
local query_window = vim.api.nvim_open_win(query_buffer, false, {
  relative = "editor",
  row = math.max(vim.o.lines - 1, 0),
  col = 0,
  width = vim.o.columns,
  height = 1,
  style = "minimal",
  border = "none",
  focusable = true,
  zindex = 50,
})
vim.bo[query_buffer].bufhidden = "wipe"
vim.bo[query_buffer].buftype = "nofile"
vim.bo[query_buffer].swapfile = false
vim.wo[query_window].number = false
vim.wo[query_window].relativenumber = false
vim.wo[query_window].signcolumn = "yes:1"

local namespace = vim.api.nvim_create_namespace("fzf-modal")
vim.api.nvim_buf_set_extmark(query_buffer, namespace, 0, 0, {
  sign_text = "> ",
  sign_hl_group = "Question",
})

local command = {
  "sh",
  "-c",
  'input=$1; shift; cat -- "$input" | exec fzf "$@"',
  "fzf-modal",
  input,
}
vim.list_extend(command, fzf_args)

local closing = false
local function close()
  if closing then
    return
  end
  closing = true
  vim.cmd("qa!")
end

vim.api.nvim_set_current_win(terminal_window)
local job = vim.fn.jobstart(command, {
  term = true,
  on_exit = function()
    vim.schedule(close)
  end,
})

if job <= 0 then
  error("failed to start fzf")
end

local function send(bytes)
  vim.api.nvim_chan_send(job, bytes)
end

local pending_query = ""
local synced_query = ""
local syncing = false
local accept_pending = false
local sync_attempts = 0
local max_sync_attempts = 5

local function report_sync_failure(result)
  local detail = vim.trim(result.stderr or ""):gsub("%s+", " ")
  local message = "fzf-modal: failed to update search"
  if detail ~= "" then
    message = message .. ": " .. detail
  end
  vim.fn.system({ "tmux", "display-message", "-d", "5000", message })
  close()
end

local function flush_query()
  if closing or syncing or pending_query == synced_query then
    if accept_pending and pending_query == synced_query then
      accept_pending = false
      send(string.char(13))
    end
    return
  end

  local query = pending_query
  syncing = true
  vim.system({
    "curl",
    "--silent",
    "--show-error",
    "--fail",
    "--max-time",
    "1",
    "--unix-socket",
    socket,
    "http://localhost",
    "--data-binary",
    "search:" .. query,
  }, { text = true }, function(result)
    vim.schedule(function()
      syncing = false
      if closing then
        return
      end
      if result.code == 0 then
        sync_attempts = 0
        synced_query = query
        flush_query()
      else
        sync_attempts = sync_attempts + 1
        if sync_attempts < max_sync_attempts then
          vim.defer_fn(flush_query, 25 * sync_attempts)
        else
          report_sync_failure(result)
        end
      end
    end)
  end)
end

local function sync_query()
  if not vim.api.nvim_buf_is_valid(query_buffer) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(query_buffer, 0, -1, false)
  local query = table.concat(lines, " ")
  if #lines ~= 1 then
    vim.api.nvim_buf_set_lines(query_buffer, 0, -1, false, { query })
  end
  pending_query = query
  flush_query()
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
  buffer = query_buffer,
  callback = sync_query,
})

local function map(modes, lhs, rhs)
  vim.keymap.set(modes, lhs, rhs, { buffer = query_buffer, silent = true })
end

map("i", "jk", "<Esc>")
map("n", "j", function()
  send(string.char(14)) -- fzf: down (Ctrl-N)
end)
map("n", "k", function()
  send(string.char(16)) -- fzf: up (Ctrl-P)
end)
map({ "n", "i" }, "<Down>", function()
  send(string.char(14))
end)
map({ "n", "i" }, "<Up>", function()
  send(string.char(16))
end)
map({ "n", "i" }, "<CR>", function()
  accept_pending = true
  flush_query()
end)
map({ "n", "i" }, "<C-y>", function()
  send(string.char(25))
end)
map("n", "q", close)
map("n", "<Esc>", close)

vim.schedule(function()
  if vim.api.nvim_win_is_valid(query_window) then
    vim.api.nvim_set_current_win(query_window)
    vim.cmd.stopinsert()
  end
end)
