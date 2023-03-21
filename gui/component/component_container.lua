local component = require("component")
local unicode = require("unicode")
local class = require("class")

local BaseComponent = require("gui/component/component_base")
local border_box = require("gui/border_box")


local Container, static, base = class(BaseComponent)

function Container:new (params)
    params = params or {}
    base.new(self, params)
    self.__children = {}
end

function Container:clear()
    self.__children = {}
    self:get_gpu():invalidate()
end

function Container:key_down(char, code)
    for _, v in ipairs(self.__children) do
        v:key_down(char, code)
    end
end

function Container:clipboard(text)
    for _, v in ipairs(self.__children) do
        v:clipboard(text)
    end
end

function Container:click(x, y)
    for _, v in ipairs(self.__children) do
        if v:is_visible() then
            v:checkClicked(x, y)
        end
    end
end

function Container:blur()
    for _, v in ipairs(self.__children) do
        v:blur()
    end
    base.blur(self)
end

function Container:add_component(child)
    if child ~= nil then
        table.insert(self.__children, child)
        child:set_parent(self)
        self:get_gpu():invalidate()
    end
end

function Container:get_height()
    local height = 0
    for _, v in ipairs(self.__children) do
        height = math.max(height, v:get_y() + v:get_height())
    end
    return height
end

function Container:get_width()
    local width = 0
    for _, v in ipairs(self.__children) do
        width = math.max(width, v:get_x() + v:get_width())
    end
    return width
end

function Container:render()
    for _, v in ipairs(self.__children) do
        v:render()
    end
end

return static