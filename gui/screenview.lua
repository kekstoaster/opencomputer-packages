local component = require("component")
local class = require("class")
local GuiScreen = require("gui/gui_screen")

local Screen, static = class()

function Screen:new()
    self.__components = {}
    self.__width, self.__height = component.gpu.getResolution()
    self.__gpu = GuiScreen()
end

function Screen:init()

end

function Screen:get_gpu()
    return self.__gpu
end

function Screen:get_height()
    return self.__height
end

function Screen:get_width()
    return self.__width
end

function Screen:get_x()
    return 0
end

function Screen:get_y()
    return 0
end

function Screen:clear()
    component.gpu.fill(0, 0, self.__width, self.__height, " ")
end

function Screen:add_component(c)
    c:set_parent(self)
    table.insert(self.__components, c)
end

function Screen:click(x, y)
    for k, v in ipairs(self.__components) do
        v:checkClicked(x - 1, y - 1)
    end
end

function Screen:key_down(char, code)
    for k, v in ipairs(self.__components) do
        v:key_down(char, code)
    end
end

function Screen:clipboard(text)
    for k, v in ipairs(self.__components) do
        v:clipboard(text)
    end
end

function Screen:render()
    for k, v in ipairs(self.__components) do
        v:render()
    end
end

return static