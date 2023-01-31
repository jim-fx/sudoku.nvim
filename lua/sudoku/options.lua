---@class Options
---@field persist_settings boolean
---@field persist_highscores boolean
---@field default_mappings boolean
---@field mappings { key: string, action: actions }

local default_options = {
  persist_settings = true,
  persist_highscores = true,
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
