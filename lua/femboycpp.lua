local function get_root_buf()
	local M = {}
	buflist = vim.api.nvim_list_bufs()
	for number, bufid in ipairs(buflist) do
		--if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_buf_is_loaded(bufid) then
		if vim.fn.win_findbuf(bufid)[1] ~= nil then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'cpp' then
				M.id = bufid
				M.visible = true
				return M
			end
		end
	end
	for number, bufid in ipairs(buflist) do
		if vim.fn.win_findbuf(bufid)[1] ~= nil then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'in' or e == 'out' then
				M.id = bufid
				M.visible = true
				return M
			end
		end
	end
	for number, bufid in ipairs(buflist) do
		if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_buf_is_loaded(bufid) then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'cpp' then
				M.id = bufid
				M.visible = false
				return M
			end
		end
	end
	for number, bufid in ipairs(buflist) do
		if vim.api.nvim_buf_is_valid(bufid) and vim.api.nvim_buf_is_loaded(bufid) then
			local e = vim.fn.expand('#' .. bufid .. ':e')
			if e == 'in' or e == 'out' then
				M.id = bufid
				M.visible = false
				return M
			end
		end
	end
end


local function get_root_file()
	local e = vim.fn.expand('%:e')
	local c -- filechar
	local visible = false
	if e == 'cpp' or e == 'in' or e == 'out' then
		c = '%'
		visible = true
	else
		buf = get_root_buf()
		c = '#' .. buf.id
		visible = buf.visible
	end
	M = {}
	M.file = vim.fn.expand(c)
	M.filewe = vim.fn.expand(c .. ':r')
	M.visible = visible
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
	local f = get_root_file() -- the root file with extra informations
	local f1 = f.filewe .. '.in' -- .in file
	local f2 = f.filewe .. '.out' -- .out file
	if is_open(f1) and is_open(f2) then
		close_all(f1)
		close_all(f2)
	elseif not is_open(f1) and not is_open(f2) then
		local opts = '|setlocal nu nornu wfw wfh'
		vim.cmd('bo ' .. '40' .. 'vs ' .. f1 .. opts)
		vim.cmd('bel sp ' .. f2 .. opts)
		vim.cmd(cur_win .. "wincmd w")
		if f.visible == false then
			vim.cmd('e ' .. f.filewe .. '.cpp')
		end
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
