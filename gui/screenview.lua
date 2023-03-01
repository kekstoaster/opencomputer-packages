local component = require("component")

local GuiScreen = require("gui/gui_screen")

local Screen = {}
Screen["__index"] = Screen


function Screen:new (o)
    o = o or {}   -- create object if user does not provide one
    o.components = {}
    o.width, o.height = component.gpu.getResolution()
    o.gpu = GuiScreen:new(o)
    setmetatable(o, Screen)
    return o
end

function Screen:get_height()
    return self.height
end

function Screen:get_width()
    return self.width
end

function Screen:get_x()
    return 0
end

function Screen:get_y()
    return 0
end

function Screen:clear()
    component.gpu.fill(0, 0, self.width, self.height, " ")
end

function Screen:addComponent(c)
    c:set_parent(self)
    table.insert(self.components, c)
end

function Screen:click(x, y)
    for k, v in ipairs(self.components) do
        v:checkClicked(x - 1, y - 1)
    end
end

function Screen:key_down(char, code)
    for k, v in ipairs(self.components) do
        v:key_down(char, code)
    end
end

function Screen:clipboard(text)
    for k, v in ipairs(self.components) do
        v:clipboard(text)
    end
end

function Screen:render()
    --self:clear()
    for k, v in ipairs(self.components) do
        v:render()
    end
end

return Screen