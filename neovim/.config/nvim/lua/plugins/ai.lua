return {}
-- return {
--   {
--     "olimorris/codecompanion.nvim",
--     config = true,
--     opts = function(_, opts)
--       return {
--         strategies = {
--           chat = {
--             adapter = "mistral_chat",
--           },
--           inline = {
--             adapter = "mistral_fim",
--           },
--         },
--         adapters = {
--           mistral_chat = function()
--             -- return require("codecompanion.adapters").extend("openai", {
--             -- return require("codecompanion.adapters").extend("ollama", {
--             -- return require("codecompanion.adapters").extend("openai_compatible", {
--             return require("codecompanion.adapters").extend("openai_compatible", {
--               name = "mistral_chat", -- Give this adapter a different name to differentiate it from the default ollama adapter
--               opts = {
--                 stream = false,
--               },
--               env = {
--                 url = "https://codestral.mistral.ai",
--                 api_key = "CODESTRAL_API_KEY",
--                 chat_url = "/v1/chat/completions",
--               },
--               schema = {
--                 model = {
--                   default = "codestral-latest",
--                 },
--                 -- include_usage = false,
--               },
--               include_usage = false,
--             })
--           end,
--           mistral_fim = function()
--             return require("codecompanion.adapters").extend("openai_compatible", {
--               name = "mistral_fim", -- Give this adapter a different name to differentiate it from the default ollama adapter
--               url = "https://codestral.mistral.ai/v1/fim/completions",
--               opts = {
--                 stream = false,
--               },
--               env = {
--                 api_key = "CODESTRAL_API_KEY",
--               },
--               schema = {
--                 model = {
--                   default = "codestral-latest",
--                 },
--               },
--             })
--           end,
--         },
--       }
--     end,
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "nvim-treesitter/nvim-treesitter",
--     },
--   },
-- }
