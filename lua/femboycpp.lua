local function get_root_bufid()
	buflist = vim.api.nvim_list_bufs()
	for number, bufid in ipairs(buflist) do
		if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_buf_is_loaded(bufid) then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'cpp' then
				return bufid
			end
		end
	end
	for number, bufid in ipairs(buflist) do
		if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_buf_is_loaded(bufid) then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'in' or e == 'out' then
				return bufid
			end
		end
	end
end


local function get_root_file()
	local e = vim.fn.expand('%:e')
	local c -- filechar
	if e == 'cpp' or e == 'in' or e == 'out' then
		c = '%'
	else
		c = '#' .. get_root_bufid()
	end
	M = {}
	M.file = vim.fn.expand(c)
	M.filewe = vim.fn.expand(c .. ':r')
	return M
end

local function is_open(filename)
	local winnr = vim.fn.bufwinnr(filename)
	if winnr == -1 then
		return false
	end
	return true
end

local function close_all(filename)
	local winid = vim.fn.bufwinid(filename)
	while winid ~= -1 do
		vim.api.nvim_win_close(winid, true)
		winid = vim.fn.bufwinid(filename)
	end
end


local function toggle_inout()
	local cur_win = vim.fn.bufwinnr(vim.fn.expand('%')) -- current window
	local e = vim.fn.expand('%:e') -- extension
	local f = get_root_file()
	local file = f.file
	local filewe = f.filewe
	local f1 = filewe .. '.in'
	local f2 = filewe .. '.out'
	if is_open(f1) and is_open(f2) then
		close_all(f1)
		close_all(f2)
	elseif not is_open(f1) and not is_open(f2) then
		local opts = '|setlocal nu nornu wfw wfh'
		vim.cmd('bo ' .. '40' .. 'vs ' .. f1 .. opts)
		vim.cmd('bel sp ' .. f2 .. opts)
		vim.cmd(cur_win .. "wincmd w")
	elseif is_open(f1) then
		close_all(f1)
	elseif is_open(f2) then
		close_all(f2)
	end
end

local function build_and_run()
	local r = get_root_file().filewe -- file name without extension
	vim.cmd('wa|silent make '..r..'|silent !./'..r..' < '..r..'.in > '..r..'.out')
end

local functions = {}
functions.toggle_inout = toggle_inout
functions.build_and_run = build_and_run

return functions
