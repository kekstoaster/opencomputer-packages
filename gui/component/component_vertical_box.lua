local component = require("component")
local unicode = require("unicode")
local class = require("class")

local Container = require("gui/component/component_container")
local border_box = require("gui/border_box")


local VerticalBox, static, base = class(Container)

function VerticalBox:new (params)
    params = params or {}
    base.new(self, params)
end

function VerticalBox:add_component(child)
    local height = self:get_height()
    base.add_component(self, child)
    child:set_x(0)
    child:set_y(height)
end


return static