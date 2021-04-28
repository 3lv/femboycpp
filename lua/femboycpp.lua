local function get_root_bufid()
	buflist = vim.api.nvim_list_bufs()
	for bufid in buflist do
		if nvim_buf_is_loaded(buf) then
			local e = vim.fn.expand('#' .. bufif .. ':e')
			if e == 'cpp' then
				return bufid
			end
		end
	end
	for bufid in buflist do
		if nvim_buf_is_loaded(buf) then
			local e = vim.fn.expand('#' .. bufif .. ':e')
			if e == 'in' or e == 'out' then
				return bufid
			end
		end
	end
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
	local e = vim.fn.expand('%:e') -- extension
	local file
	local filewe
	if e == 'cpp' or e == 'in' or e == 'out' then
		file = vim.fn.expand('%')
		filewe = vim.fn.expand('%:r') --filename_without_extension
	else 
		file = vim.fn.expand('#' .. get_root_bufid())
		filewe = vim.fn.expand('#' .. get_root_bufid() .. ':r')
	end

	local f1 = filewe .. '.in'
	local f2 = filewe .. '.out'
	if is_open(f1) and is_open(f2) then
		close_all(f1)
		close_all(f2)
	elseif not is_open(f1) and not is_open(f2) then
		local winnr = vim.fn.bufwinnr(file)
		local opts = '|setlocal nu nornu wfw wfh'
		vim.cmd('bo ' .. '40' .. 'vs ' .. f1 .. opts)
		vim.cmd('bel sp ' .. f2 .. opts)
		vim.cmd(winnr .. "wincmd w")
	elseif is_open(f1) then
		close_all(f1)
	elseif is_open(f2) then
		close_all(f2)
	end
end

local function build_and_run()
	vim.cmd[[wa|silent make %:r|silent !./%:r < %:r.in > %:r.out]]
end

local functions = {}
functions.toggle_inout = toggle_inout
functions.build_and_run = build_and_run

return functions
