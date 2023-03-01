local component = require("component")
local unicode = require("unicode")

local component_base = require("gui/component_base")
local border_box = require("gui/border_box")


local component_header = component_base:meta()
component_header["__index"] = component_header

function component_header:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.padding = a.padding or 5
    o.text = a.text or ""

    setmetatable(o, component_header)
    return o
end

function component_header:get_height()
    return 5
end

function component_header:get_width()
    return 2 + 2 * self.padding + unicode.wlen(self.text)
end

function component_header:render()
    local pw = self:get_parent():get_width()
    local sw = self:get_width()
    local x2 = (pw - sw) / 2
    border_box.render_box_double(self.gpu, x2, self.y, sw, self:get_height())
    self.gpu:set(x2 + self.padding + 1, self.y + 2, self.text)
end


return component_header