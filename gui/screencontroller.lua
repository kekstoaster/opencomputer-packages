local os = require("os")
local component = require("component")

local ControllerMeta = {}
ControllerMeta["__index"] = ControllerMeta


function Controller(app)
    local o = {}   -- create object if user does not provide one
    o.app = app
    setmetatable(o, ControllerMeta)
    return o
end

function ControllerMeta:get_app()
    return self.app
end


return Controller