local component = require("component")
local unicode = require("unicode")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_button = component_base:new()
component_button["__index"] = component_button

function component_button:new (a)
    a = a or {}
    local o = component_base:new(a)
    o.padding = a.padding or 0
    o.text = a.text or ""
    setmetatable(o, component_button)
    return o
end

function component_button:set_text(text)
    self.text = text
    self.gpu:invalidate()
end

function component_button:get_height()
    return 3
end

function component_button:get_width()
    return 2 + 2 * self.padding + unicode.wlen(self.text)
end



function component_button:render()
    border_box.render_box_single(self.gpu, self:get_x(), self:get_y(), self:get_width(), self:get_height())
    self.gpu:set(self:get_x() + self.padding + 1, self:get_y() + 1, self.text)
end

return component_button