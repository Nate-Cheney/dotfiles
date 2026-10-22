local function set_statusline_hl()
	local pms = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
	local vis = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	vim.api.nvim_set_hl(0, "StlMode", { fg = pms.fg, bg = vis.bg })

	-- Git branch color: catppuccin "overlay0" from the active colorscheme
	-- (mirrors starship's git_branch, which uses the catppuccin palette)
	local ok, palettes = pcall(require, "catppuccin.palettes")
	local overlay0 = ok and palettes.get_palette().overlay0 or "#6c7086"
	vim.api.nvim_set_hl(0, "StlGit", { fg = overlay0, bg = pms.bg })
end

-- Set now, and again whenever a colorscheme loads: statusline.lua is required
-- from init.lua, which runs *before* after/plugin/color.lua switches to catppuccin
set_statusline_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_statusline_hl })

local modes = {
	n = "NORMAL",
	i = "INSERT",
	v = "VISUAL",
	V = "V-LINE",
	["\22"] = "V-BLOCK",
	c = "COMMAND",
	t = "TERMINAL",
	R = "REPLACE",
	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",
}

function _G._statusline()
	local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
	-- pad to the longest label ("TERMINAL") so the pill doesn't resize between modes
	mode = string.format("%-8s", mode)
	local branch = vim.b.git_branch and "%#StlGit# " .. vim.b.git_branch .. " %*" or ""
	local path = vim.b.rel_path or "%f"

	local diag = ""
	local counts = vim.diagnostic.count(0) or {}
	local labels = { " ", " ", " ", " " }
	local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
	for i = 1, 4 do
		if counts[i] and counts[i] > 0 then
			diag = diag .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
		end
	end

	return "%#StlMode# " .. mode .. " %*" .. branch .. " " .. path .. "%=" .. diag .. vim.bo.filetype .. " %l:%c"
end

-- Run git and return trimmed output, or nil on failure/empty output.
-- Avoids shell redirection (e.g. 2>/dev/null) so it works on cmd.exe too.
local function git(args)
	local out = vim.fn.system("git " .. args):gsub("%s+$", "")
	return vim.v.shell_error == 0 and out ~= "" and out or nil
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local full = vim.fn.expand("%:p")
		if full == "" then
			-- Unnamed buffer: fall back to "%f" in the statusline
			vim.b.git_branch = nil
			vim.b.rel_path = nil
			return
		end
		local root = git("rev-parse --show-toplevel")
		if root then
			-- Normalize separators: git emits "/", expand() may emit "\" on Windows
			root = root:gsub("\\", "/")
			vim.b.git_branch = git("branch --show-current")
			vim.b.rel_path = full:gsub("\\", "/"):sub(#root + 2)
		else
			vim.b.git_branch = nil
			vim.b.rel_path = vim.fn.expand("%:p:~")
		end
	end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		vim.cmd("redrawstatus!")
	end,
})

vim.o.statusline = "%!v:lua._statusline()"
