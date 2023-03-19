---@class HighlightOptions
---@field bg string
---@field fg string
---@field gui string

---@class Options
---@field persist_settings boolean
---@field persist_games boolean
---@field default_mappings boolean
---@field mappings { key: string, action: actions }
---@field custom_highlights { [string]: HighlightOptions }

local default_options = {
  persist_settings = true,
  persist_games = true,
  default_mappings = true
};

local options = default_options;

return {
  ---@param key? string
  get = function(key)
    if key ~= nil then
      return options[key];
    end
    return options;
  end,
  set = function(opts)
    options = vim.tbl_extend("force", options, opts);
    return options;
  end,
}
