local os = require("os")
local component = require("component")
local class = require("class")

local Controller, static = class()

function Controller:new(app)
    self.__app = app
end

function ControllerMeta:get_app()
    return self.__app
end


return static