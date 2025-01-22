{...}: {
  # Setting some helpful autocommands
  programs.neovim = {
    extraLuaConfig =
      /*
      lua
      */
      ''
        local function augroup(name)
        	return vim.api.nvim_create_augroup("lucidph3nx_" .. name, { clear = true })
        end

        -- highlight on yank
        local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
        vim.api.nvim_create_autocmd("TextYankPost", {
        	callback = function()
        		vim.highlight.on_yank()
        	end,
        	group = highlight_group,
        	pattern = "*",
        })

        -- resize splits if window got resized
        vim.api.nvim_create_autocmd({ "VimResized" }, {
        	group = augroup("resize_splits"),
        	callback = function()
        		vim.cmd("tabdo wincmd =")
        	end,
        })

        -- wrap and check for spell in text filetypes
        vim.api.nvim_create_autocmd("FileType", {
        	group = augroup("wrap_spell"),
        	pattern = { "gitcommit", "markdown" },
        	callback = function()
        		-- vim.opt_local.wrap = true
        		vim.opt_local.spell = true
        	end,
        })

        -- Auto create dir when saving a file, in case some intermediate directory does not exist
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        	group = augroup("auto_create_dir"),
        	callback = function(event)
        		if event.match:match("^%w%w+://") then
        			return
        		end
        		local file = vim.loop.fs_realpath(event.match) or event.match
        		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        	end,
        })
      '';
  };
}
