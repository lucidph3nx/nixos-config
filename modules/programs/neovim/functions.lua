-- Some code to toggle checkboxes in markdown
function toggle_checkbox()
	local line_number = vim.fn.line(".")
	local line = vim.fn.getline(line_number)
	if line:match("- %[%s%]") then
		line = line:gsub("- %[%s%]", "- [x]")
	elseif line:match("- %[%a%]") then
		line = line:gsub("- %[%a%]", "- [ ]")
	else
		print("No checkbox found at line " .. line_number)
		return
	end
	vim.fn.setline(line_number, line)
end

-- Function to wrap selected text into wiki link format
local function wrap_text_into_wiki_link(text)
	local wrapped_text

	-- Format the wrapped text based on selection
	if string.match(text, "%u") then
		-- Selected text contains uppercase letters
		local formatted_text = text:lower()
		wrapped_text = "[[" .. formatted_text .. "|" .. text .. "]]"
	elseif string.match(text, "%s") then
		-- Selected text contains spaces (multiple words)
		local formatted_text = text:gsub("%s", "_")
		wrapped_text = "[[" .. formatted_text .. "|" .. text .. "]]"
	else
		-- Single word, no capital letters
		wrapped_text = "[[" .. text .. "]]"
	end

	return wrapped_text
end

function wrap_wiki_link_normal()
	-- Clear the contents of the default register
	vim.fn.setreg('"', "")

	-- Use word under cursor
	local selected_text = vim.fn.expand("<cword>")

	-- Check if selected text is empty
	if selected_text == "" then
		print("No text selected.")
		return
	end

	-- Wrap selected text into wiki link format
	local wrapped_text = wrap_text_into_wiki_link(selected_text)

	-- Replace selected text with wrapped text
	vim.fn.setreg('"', wrapped_text)
	vim.cmd('normal! "_d')
	vim.cmd("normal! viw")
	vim.cmd('normal! ""p')
end

function wrap_wiki_link_visual()
	-- Clear the contents of the default register
	vim.fn.setreg('"', "")

	-- Get the current selection
	local start_line = vim.fn.getpos("'<")[2]
	local end_line = vim.fn.getpos("'>")[2]
	local selected_text = ""
	if start_line == end_line then
		-- Single line selection
		selected_text = vim.fn.getline(start_line):sub(vim.fn.getpos("'<")[3], vim.fn.getpos("'>")[3])
	else
		-- Multi-line selection
		selected_text = table.concat(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")
	end

	-- Check if selected text is empty
	if selected_text == "" then
		print("No text selected.")
		return
	end

	-- Wrap selected text into wiki link format
	local wrapped_text = wrap_text_into_wiki_link(selected_text)

	-- Replace selected text with wrapped text
	vim.fn.setreg('"', wrapped_text)
	vim.cmd('normal! "_d')
	vim.cmd("normal! gv")
	vim.cmd('normal! "_dP')
end

-- Since I will mostly use this in my obsidian vault, I'm going to continue to use the <leader>o convention.
vim.api.nvim_set_keymap(
	"n",
	"<leader>oc",
	":lua toggle_checkbox()<CR>",
	{ noremap = true, desc = "[O]bsidian [C]heckbox" }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>ol",
	":lua wrap_wiki_link_normal()<CR>",
	{ noremap = true, desc = "[O]bsidian [L]ink" }
)
vim.api.nvim_set_keymap(
	"x",
	"<leader>ol",
	":lua wrap_wiki_link_visual()<CR>",
	{ noremap = true, desc = "[O]bsidian [L]ink" }
)
