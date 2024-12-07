{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.obsidian-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('obsidian').setup {
            workspaces = {
              {
                name = "personal",
                path = '~/documents/obsidian',
              },
            },
            note_id_func = function(title)
              -- lowercase and replace spaces with underscores
              return string.lower(title:gsub("%s", "_"))
            end,
            notes_subdir = 'notes',
            daily_notes = {
              folder = 'dailies',
              date_format = '%Y-%m-%d',
              template = 'daily_note.md',
            },
            templates = {
              subdir = 'templates',
            },
            follow_url_func = function(url)
              vim.fn.jobstart({ "xdg-open", url })
            end,
            new_notes_location = 'notes_subdir',
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
            disable_frontmatter = true,
            -- don't use built in mappings
            mappings = {},
            ui = {
              -- don't use obsidian.nvim colours
              hl_groups = {},
            }
          }

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
          vim.keymap.set('n', '<leader>od',
            vim.cmd.ObsidianToday, { desc = '[O]bsidian [D]aily note for Today' })
          vim.keymap.set('n', '<leader>oy',
            -- have to use Today-1 because Yesterday uses weekday only
            function()
              vim.cmd("ObsidianToday -1")
            end, { desc = '[O]bsidian [Y]esterday note' })
          vim.keymap.set('n', '<leader>or',
            function()
              vim.cmd("ObsidianDailies -30 1")
            end, { desc = '[O]bsidian [R]ecent' })
          -- keybindings for custom commands
          vim.keymap.set('n', '<leader>on',
            vim.cmd.ObsidianNextDay, { desc = '[O]bsidian [N]ext Daily Note' })
          vim.keymap.set('n', '<leader>op',
            vim.cmd.ObsidianPrevDay, { desc = '[O]bsidian [P]revious Daily Note' })

          vim.keymap.set('n', '<leader>ot',
            vim.cmd.ObsidianTemplate, { desc = '[O]bsidian [T]emplate' })
          vim.keymap.set('n', '<leader>oo',
            vim.cmd.ObsidianOpen, { desc = '[O]bsidian [O]pen' })
          vim.keymap.set('n', '<leader>of',
            vim.cmd.ObsidianFollow, { desc = '[O]bsidian [F]ollow' })
          vim.keymap.set('n', '<leader>ob',
            vim.cmd.ObsidianBacklinks, { desc = '[O]bsidian [B]acklinks' })
        '';
    }
  ];
}
