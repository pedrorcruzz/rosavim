local config = {
  defaults = {
    transparent = false,
    overrides = {},
  },
}

setmetatable(config, { __index = config.defaults })

return config
