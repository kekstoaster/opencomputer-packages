local component = require("component")
--local math = require("math")

local component_base = require("gui/component/component_base")
local border_box = require("gui/border_box")


local component_horizontal_center = component_base:new()
component_horizontal_center["__index"] = component_horizontal_center

function component_horizontal_center:new (a)
    a = a or {}
    local o = component_base:new(a)

    setmetatable(o, component_horizontal_center)
    if a.component ~= nil then
        o:set_component(a.component)
    end
    return o
end

function component_horizontal_center:key_down(char, code)
    if self.child ~= nil then
        self.child:key_down(char, code)
    end
end

function component_horizontal_center:clipboard(text)
    if self.child ~= nil then
        self.child:clipboard(text)
    end
end

function component_horizontal_center:set_parent(parent)
    self.parent = parent
    if self.child ~= nil then
        self.child.x = self:get_child_x()
    end
end

function component_horizontal_center:set_component(child)
    self.child = child
    if child ~= nil then
        child:set_parent(self)
        child.x = self:get_child_x()
        child.y = 0
    end
end

function component_horizontal_center:get_height()
    if self.child ~= nil then
        return self.child:get_height()
    else
        return 1
    end
end

function component_horizontal_center:get_width()
    if self.parent ~= nil then
        return self.parent:get_width()
    else
        return 0
    end
end

function component_horizontal_center:get_child_x()
    if self.child ~= nil then
        return math.floor((self:get_width() - self.child:get_width()) / 2)
    else
        return 0
    end
end

function component_horizontal_center:click(x, y)
    if self.child ~= nil then
        self.child:checkClicked(x, y)
    end
end

function component_horizontal_center:blur()
    if self.has_focus then
        self.child:blur()
        self.has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
            self.gpu:invalidate()
        end
    end
end

function component_horizontal_center:render()
    if self.child ~= nil then
        self.child:render()
    end
end


return component_horizontal_center