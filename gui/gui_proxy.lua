local component = require("component")

local GuiProxy = {}
GuiProxy["__index"] = GuiProxy


function GuiProxy:new (a)
    local o = {}
    o.component = a
    setmetatable(o, GuiProxy)
    return o
end

function GuiProxy:find_coord(x, y)
    if self.component.parent ~= nil then
        return self.component.parent.gpu:find_coord(x + self.component.parent:get_x(), y + self.component.parent:get_y())
    end
end

function GuiProxy:set(x, y, value, vertical)
    if self.component.parent ~= nil then
        return self.component.parent.gpu:set(x + self.component.parent:get_x(), y + self.component.parent:get_y(), value, vertical)
    end
end

function GuiProxy:fill(x, y, w, h, c)
    if self.component.parent ~= nil then
        return self.component.parent.gpu:fill(x + self.component.parent:get_x(), y + self.component.parent:get_y(), w, h, c)
    end
end

function GuiProxy:invalidate()
    if self.component.parent ~= nil then
        return self.component.parent.gpu:invalidate()
    end
end

function GuiProxy:with_color(callback, fg_col, bg_col)
    if self.component.parent ~= nil then
        return self.component.parent.gpu:with_color(callback, fg_col, bg_col)
    end
end

return GuiProxy