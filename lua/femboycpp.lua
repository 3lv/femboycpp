local function is_open(filename)
	local winnr = vim.fn.bufwinnr(filename)
	if winnr == -1 then
		return false
	end
	return true
end

local function get_root_file()
	local M = { }
	local buflist = vim.api.nvim_list_bufs()
	local root_file = {
		filename = nil,
		priority = 0,
	};
	for _, v in ipairs(buflist) do
		local filename = vim.fn.bufname(v)
		local ext = vim.fn.fnamemodify(filename, ':e')
		local priority = 0;
		if ext == 'cpp' or ext == 'in' or ext == 'out' then
			if filename == vim.fn.expand('%') then
				priority = priority + 20
			end
			if is_open(filename)  then
				priority = priority + 10
			end
			if ext == 'cpp' then
				priority = priority + 2
			end
			if ext == 'in' or ext == 'out' then
				priority = priority + 1
			end
		end
		if priority > root_file.priority then
			root_file = { filename = filename, priority = priority };
		end
	end
	return root_file.filename
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
	local filename = get_root_file() -- the root file with extra informations
	local filewe = vim.fn.fnamemodify(filename, ':r')
	local f1 = filewe .. '.in' -- .in file
	local f2 = filewe .. '.out' -- .out file
	if #vim.fn.win_findbuf(vim.fn.bufnr(f1)) + #vim.fn.win_findbuf(vim.fn.bufnr(f2)) == vim.fn.winnr('$') then
		if vim.fn.winnr('$') == 1 then
			vim.cmd('e '..filewe..'.cpp')
			toggle_inout()
			return
		else
			vim.cmd('e '..filewe..'.cpp')
			toggle_inout()
			toggle_inout()
			return
		end
	end
	if is_open(f1) and is_open(f2) then
		close_all(f1)
		close_all(f2)
	elseif not is_open(f1) and not is_open(f2) then
		cpp_win_opts = cpp_win_opts or 'wfw wfh'
		opts = '|setlocal ' .. cpp_win_opts
		vim.cmd('bo 40vs '..f1..opts)
		vim.cmd('bel sp '..f2..opts)
		vim.cmd(cur_win .. 'wincmd w')
	elseif is_open(f1) then
		close_all(f1)
	elseif is_open(f2) then
		close_all(f2)
	end
end

local function build_and_run_io()
	local file = get_root_file() -- file name without extension
	local r = vim.fn.fnamemodify(file, ':r')
	vim.cmd('wa|silent make '..r..'|silent !./'..r..' < '..r..'.in > '..r..'.out')
end
local function build_and_run()
	local file = get_root_file() -- file name without extension
	local r = vim.fn.fnamemodify(file, ':r')
	vim.cmd('wa|silent make '..r..'|silent !./'..r)
end

local function cpp_autocmd()
	vim.cmd [[
	augroup femboycpp
	autocmd!
	autocmd FileType cpp nnoremap <silent> <A-4> <cmd>lua require('femboycpp').toggle_inout()<CR>
	autocmd FileType cpp nnoremap <silent> <A-7> <cmd>lua require('femboycpp').build_and_run_io()<CR>
	autocmd FileType cpp nnoremap <silent> <A-8> <cmd>lua require('femboycpp').build_and_run()<CR>
	augroup END
	]]
end

local function setup( user_config )
	cpp_autocmd()
end

local F = {}
F.toggle_inout = toggle_inout
F.build_and_run_io = build_and_run_io
F.build_and_run = build_and_run
F.setup = setup

return F
