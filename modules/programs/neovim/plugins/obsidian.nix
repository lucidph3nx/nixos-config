{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.obsidian-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          -- Helper function to get the date of the next specified weekday
          local getNextWeekday = function(dayOfWeek)
          	local currentWeekday = os.date("%w", os.time())
          	local nextWeekMonday = os.time() + (7 - currentWeekday + 1) * 24 * 60 * 60
          	return os.date("%Y-%m-%d", nextWeekMonday + (dayOfWeek - 1) * 24 * 60 * 60)
          end

          require("obsidian").setup({
          	workspaces = {
          		{
          			name = "personal",
          			path = "~/documents/obsidian",
          		},
          	},
          	note_id_func = function(title)
          		-- lowercase and replace spaces with underscores
          		return string.lower(title:gsub("%s", "_"))
          	end,
          	notes_subdir = "notes",
          	daily_notes = { folder = "dailies", date_format = "%Y-%m-%d", template = "daily_note.md" },
          	templates = {
          		subdir = "templates",
          		substitutions = {
          			nextweekyear = function()
          				-- return the year of the next week
          				return os.date("%Y", os.time() + 7 * 24 * 60 * 60)
          			end,
          			nextweeknum = function()
          				-- return the week number of the next week
          				return os.date("%V", os.time() + 7 * 24 * 60 * 60)
          			end,
          			nextweekmonday = function()
          				return getNextWeekday(1)
          			end,
          			nextweektuesday = function()
          				return getNextWeekday(2)
          			end,
          			nextweekwednesday = function()
          				return getNextWeekday(3)
          			end,
          			nextweekthursday = function()
          				return getNextWeekday(4)
          			end,
          			nextweekfriday = function()
          				return getNextWeekday(5)
          			end,
          			nextweeksaturday = function()
          				return getNextWeekday(6)
          			end,
          			nextweeksunday = function()
          				return getNextWeekday(7)
          			end,
          		},
          	},
          	follow_url_func = function(url)
          		vim.fn.jobstart({ "xdg-open", url })
          	end,
          	new_notes_location = "notes_subdir",
          	wiki_link_func = function(opts)
          		if opts.id == nil then
          			return string.format("[[%s]]", opts.label)
          		elseif opts.label ~= opts.id then
          			return string.format("[[%s|%s]]", opts.id, opts.label)
          		else
          			return string.format("[[%s]]", opts.id)
          		end
          	end,
          	open_app_foreground = true,
          	disable_frontmatter = false,
          	note_frontmatter_func = function(note)
          		-- Ensure note.path is a string
          		local note_path = tostring(note.path)

          		-- Extract filename (without extension)
          		local filename = vim.fn.fnamemodify(note_path, ":t:r") -- Gets 'YYYY-MM-DD' from 'YYYY-MM-DD.md'

          		-- Check if filename matches YYYY-MM-DD format
          		local is_daily_note = filename:match("^%d%d%d%d%-%d%d%-%d%d$") ~= nil

          		-- Ensure title is an alias if not already present
          		if note.title and not vim.tbl_contains(note.aliases, note.title) then
          			note:add_alias(note.title)
          		elseif is_daily_note and not vim.tbl_contains(note.aliases, filename) then
          			-- If it's a daily note and has no title, use filename as alias
          			note:add_alias(filename)
          		end

          		-- Get current date and time
          		local current_date = os.date("%Y-%m-%d") -- Matches daily note format
          		local current_time = os.date("%Y-%m-%d %H:%M:%S") -- Full timestamp

          		local out = {
          			aliases = note.aliases,
          			tags = note.tags,
          			modified = current_time, -- Timestamp for modifications
          		}

          		-- Add "daily-notes" tag if it's a daily note and not already tagged
          		if is_daily_note and not vim.tbl_contains(note.tags, "daily-notes") then
          			table.insert(out.tags, "daily-notes")
          		end

          		-- Check if the file already exists
          		local file = io.open(note_path, "r")
          		if file == nil then
          			-- File doesn't exist, assume it's a new note and set "created" as a link
          			out.created = "[[" .. current_date .. "]]"
          		else
          			-- File exists, close it and don't set "created"
          			file:close()
          		end

          		-- Preserve existing metadata, but always update `modified`
          		if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          			for k, v in pairs(note.metadata) do
          				if k ~= "modified" then -- Keep everything but ensure modified is new
          					out[k] = v
          				end
          			end
          		end

          		return out
          	end,
          	-- don't use built in mappings
          	mappings = {},
          	ui = {
          		-- don't use obsidian.nvim colours
          		hl_groups = {},
          	},
          })

          -- custom commands for previous and next daily note
          local offset_daily = function(offset)
          	local filename = vim.fn.expand("%:t:r")
          	local year, month, day = filename:match("(%d+)-(%d+)-(%d+)")
          	local date = os.time({ year = year, month = month, day = day })
          	local client = require("obsidian").get_client()
          	local note = client:_daily(date + (offset * 3600 * 24))
          	client:open_note(note)
          end

          vim.api.nvim_create_user_command("ObsidianPrevDay", function(_)
          	offset_daily(-1)
          end, {
          	bang = false,
          	bar = false,
          	register = false,
          	desc = "Create and switch to the previous daily note based on current buffer",
          })

          vim.api.nvim_create_user_command("ObsidianNextDay", function(_)
          	offset_daily(1)
          end, {
          	bang = false,
          	bar = false,
          	register = false,
          	desc = "Create and switch to the next daily note based on current buffer",
          })

          vim.opt.conceallevel = 2
          vim.keymap.set("n", "<leader>od", vim.cmd.ObsidianToday, { desc = "[O]bsidian [D]aily note for Today" })
          vim.keymap.set(
          	"n",
          	"<leader>oy",
          	-- have to use Today-1 because Yesterday uses weekday only
          	function()
          		vim.cmd("ObsidianToday -1")
          	end,
          	{ desc = "[O]bsidian [Y]esterday note" }
          )
          vim.keymap.set("n", "<leader>or", function()
          	vim.cmd("ObsidianDailies -30 1")
          end, { desc = "[O]bsidian [R]ecent" })
          -- keybindings for custom commands
          vim.keymap.set("n", "<leader>on", vim.cmd.ObsidianNextDay, { desc = "[O]bsidian [N]ext Daily Note" })
          vim.keymap.set("n", "<leader>op", vim.cmd.ObsidianPrevDay, { desc = "[O]bsidian [P]revious Daily Note" })

          vim.keymap.set("n", "<leader>ot", vim.cmd.ObsidianTemplate, { desc = "[O]bsidian [T]emplate" })
          vim.keymap.set("n", "<leader>oo", vim.cmd.ObsidianOpen, { desc = "[O]bsidian [O]pen" })
          vim.keymap.set("n", "<leader>of", vim.cmd.ObsidianFollow, { desc = "[O]bsidian [F]ollow" })
          vim.keymap.set("n", "<leader>ob", vim.cmd.ObsidianBacklinks, { desc = "[O]bsidian [B]acklinks" })
          vim.keymap.set("n", "<leader>ost", vim.cmd.ObsidianTags, { desc = "[O]bsidian [S]earch [T]ags" })
        '';
    }
  ];
}
