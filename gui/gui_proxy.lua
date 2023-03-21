local component = require("component")
local class = require("class")

local GuiProxy, static = class()

function GuiProxy:new (c)
    self.__component = c
end

function GuiProxy:find_coord(x, y)
    if self.__component:get_parent() ~= nil then
        return self.__component:get_parent():get_gpu():find_coord(x + self.__component:get_parent():get_x(), y + self.__component:get_parent():get_y())
    end
end

function GuiProxy:set(x, y, value, vertical)
    if self.__component:get_parent() ~= nil then
        return self.__component:get_parent():get_gpu():set(x + self.__component:get_parent():get_x(), y + self.__component:get_parent():get_y(), value, vertical)
    end
end

function GuiProxy:fill(x, y, w, h, c)
    if self.__component:get_parent() ~= nil then
        return self.__component:get_parent():get_gpu():fill(x + self.__component:get_parent():get_x(), y + self.__component:get_parent():get_y(), w, h, c)
    end
end

function GuiProxy:invalidate()
    if self.__component:get_parent() ~= nil then
        return self.__component:get_parent():get_gpu():invalidate()
    end
end

function GuiProxy:with_color(callback, fg_col, bg_col)
    if self.__component:get_parent() ~= nil then
        return self.__component:get_parent():get_gpu():with_color(callback, fg_col, bg_col)
    end
end

return static