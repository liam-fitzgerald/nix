require("nvchad.configs.lspconfig").defaults()


vim.lsp.config("clangd", {
  filetypes = { "c", "h" }
})

local servers = { "html", "cssls", "sourcekit", "rust_analyzer", "clangd" }
vim.lsp.enable(servers)


-- read :h vim.lsp.config for changing options of lsp servers 
