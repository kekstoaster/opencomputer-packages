local component = require("component")
local class = require("class")
local nullable = require("nullable")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local HorizontalCenter, static, base = class(BaseComponent)

function HorizontalCenter:new (params)
    params = params or {}
    base.new(self, params)
    self:set_component(params.component)
end

function HorizontalCenter:key_down(char, code)
    self.__child:key_down(char, code)
end

function HorizontalCenter:clipboard(text)
    self.__child:clipboard(text)
end

function HorizontalCenter:set_parent(parent)
    base.set_parent(self, parent)
    self.__child:set_x(self:get_child_x())
end

function HorizontalCenter:set_component(child)
    self.__child = nullable(child)
    self.__child:set_parent(self)
    self.__child:set_x(self:get_child_x())
    self.__child:set_y(0)
end

function HorizontalCenter:get_height()
    return self.__child:get_height() or 1
end

function HorizontalCenter:get_width()
    if self.__parent ~= nil then
        return self.__parent:get_width()
    else
        return 0
    end
end

function HorizontalCenter:get_child_x()
    return math.floor((self:get_width() - (self.__child:get_width() or 0)) / 2)
end

function HorizontalCenter:click(x, y)
    self.__child:checkClicked(x, y)
end

function HorizontalCenter:blur()
    if self.__has_focus then
        self.__child:blur()
        self.__has_focus = false
        if self.__blur_fn ~= nil then
            self.__blur_fn()
            self:get_gpu():invalidate()
        end
    end
end

function HorizontalCenter:render()
    self.__child:render()
end

return static