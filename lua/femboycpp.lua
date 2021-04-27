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
	local fullfilename = vim.fn.expand('%')
	local filename = vim.fn.expand('%:r') --filename_without_extension
	local f1 = filename .. '.in'
	local f2 = filename .. '.out'
	if is_open(f1) and is_open(f2) then
		close_all(f1)
		close_all(f2)
	elseif not is_open(f1) and not is_open(f2) then
		local winnr = vim.fn.bufwinnr(fullfilename)
		vim.cmd[[bo 40vs %:r.in|set nu nornu wfw wfh]]
		vim.cmd[[bel sp %:r.out|set nu nornu wfw wfh]]
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
