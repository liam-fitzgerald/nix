return {
  {
     dir = "/Users/test/dev/reaver/editor/plan-vim",
     lazy = false,
   },
    {
       dir = "/Users/test/dev/reaver/editor/foil-vim",
       lazy = false,
     },

  { "L3MON4D3/LuaSnip", enabled = true },
  { "rafamadriz/friendly-snippets", enabled  = true },
  { "hrsh7th/nvim-cmp", enabled = true },
  { "nvim-telescope/telescope-ui-select.nvim",
     lazy = false,
     config = function ()
       require("telescope").load_extension("ui-select")
     end
},

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  { "alexghergh/nvim-tmux-navigation",
    config = function()

      local nvim_tmux_nav = require('nvim-tmux-navigation')

      nvim_tmux_nav.setup {
          disable_when_zoomed = true -- defaults to false
      }

      vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
      vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)

    end
  },
  -- { "ludovicchabant/vim-gutentags", lazy = false },
  {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
        require('distant'):setup()
    end
  },
  { "urbit/hoon.vim", lazy = false, },
  { 'rluba/jai.vim', lazy = false },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "lervag/vimtex",
    lazy = false,     -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = "zathura"
    end
  },

  { "rcarriga/nvim-dap-ui",
    lazy = false,
    init = function()
      local dapui = require('dapui')
      dapui.setup()
      vim.api.nvim_create_user_command("DapCloseUI", function()
        dapui.close()
      end, {});

    end
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
  { "mfussenegger/nvim-dap",
    lazy = false,
    init = function()
      local dap = require("dap")
      dap.listeners.before.attach.dapui_config = function()
        require('dapui').open()
      end
      dap.listeners.before.launch.dapui_config = function()
        require('dapui').open()
      end
      --   vim.api.nvim_set_hl(0, 'DapStopped', { bg = C.grey })
      local sign = vim.fn.sign_define

      sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      sign('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = mason_path .. "/adapter/codelldb",
            args = { "--port", "${port}" },
            env = {
              LLDB_DEBUGSERVER_PATH = "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/debugserver"
            }
        },
      }
      local function pick_process()
        local output = vim.fn.system("ps -u " .. vim.env.USER .. " -eo pid,comm,args --no-headers")
        local lines = vim.split(output, "\n", { trimempty = true })

        local procs = {}
        for _, line in ipairs(lines) do
          local pid, name, args = line:match("^%s*(%d+)%s+(%S+)%s+(.*)")
          if pid and name then
            table.insert(procs, {
              pid = tonumber(pid),
              display = string.format("[%s] %s — %s", pid, name, args),
            })
          end
        end

        local co = coroutine.running()   -- nvim-dap calls this inside a coroutine

        vim.ui.select(procs, {
          prompt = "Attach to process:",
          format_item = function(p) return p.display end,
        }, function(choice)
          coroutine.resume(co, choice and choice.pid or dap.ABORT)
        end)

        return coroutine.yield()  -- suspend until the picker resolves
      end

      local function pick_executable()
        local co = coroutine.running()
        vim.schedule(function()
          require("telescope.builtin").find_files({
            prompt_title = "Select executable",
            cwd = vim.fn.getcwd(),
            no_ignore = true,
            find_command = { "fd", "--type", "x", "--no-ignore" },
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local entry = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                coroutine.resume(co, entry.path or entry.value)
              end)
              return true
            end,
          })
        end)
        return coroutine.yield()
      end
      dap.configurations.rust = vim.list_extend(dap.configurations.rust or {}, {
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,   -- dap calls this as a function at launch time
          stopOnEntry = false,
          env = {
             LLDB_DEBUGSERVER_PATH = "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/Resources/debugserver"
          },
          program = pick_executable
        },
      })
      vim.keymap.set("n", "<leader>ia", function()
        require("dap").continue()   -- if config is "attach", this runs the picker
      end, { desc = "DAP attach" })


      vim.keymap.set('n', '<F5>', function() dap.continue() end)
      vim.keymap.set('n', '<F10>', function() dap.step_over() end)
      vim.keymap.set('n', '<F11>', function() dap.step_into() end)
      vim.keymap.set('n', '<F12>', function() dap.step_out() end)
      vim.keymap.set('n', '<M-b>', function() dap.toggle_breakpoint() end)
    end
  },

  { "nvim-neotest/nvim-nio" },

  {
    "windwp/nvim-ts-autotag",

    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false -- Auto close on trailing </
    },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
    ["html"] = {
      enable_close = false
    }
  }
  },
  {
  	"nvim-treesitter/nvim-treesitter",
    branch = "master",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css", "c"
  		},
      disable = { "hoon" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "hoon" },
        additional_vim_regex_highlighting = true,
      }
  	}
  }
}
