require("nvchad.configs.lspconfig").defaults()


vim.lsp.config("clangd", {
  filetypes = { "c", "h" }
})

local servers = { "html", "cssls", "rust_analyzer" }
vim.lsp.enable(servers)


-- read :h vim.lsp.config for changing options of lsp servers
