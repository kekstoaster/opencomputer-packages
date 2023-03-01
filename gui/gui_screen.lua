local component = require("component")
local event = require("event")

local GuiScreen = {}
GuiScreen["__index"] = GuiScreen


function GuiScreen:new (a)
    o = {}   -- create object if user does not provide one
    o.screen = a
    setmetatable(o, GuiScreen)
    return o
end

function GuiScreen:find_coord(x, y)
    return x + 1, y + 1
end

function GuiScreen:set(x, y, value, vertical)
    return component.gpu.set(x + 1, y + 1, value, vertical)
end

function GuiScreen:fill(x, y, w, h, c)
    return component.gpu.fill(x + 1, y + 1, w, h, c)
end

function GuiScreen:invalidate()
    event.push("render")
end

function GuiScreen:with_color(callback, fg_col, bg_col)
    if fg_col ~= nil then
        old_fg = component.gpu.setForeground(fg_col, false)
    end
    if bg_col ~= nil then
        old_bg = component.gpu.setBackground(bg_col, false)
    end
    callback()
    if fg_col ~= nil then
        component.gpu.setForeground(old_fg, false)
    end
    if bg_col ~= nil then
        component.gpu.setBackground(old_bg, false)
    end
end

return GuiScreen