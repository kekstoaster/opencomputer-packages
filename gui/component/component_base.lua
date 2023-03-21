local os = require("os")
local GuiProxy = require("gui/gui_proxy")
local class = require("class")

local ViewComponent, static = class()

function ViewComponent:new(params)
    params = params or {}
    self.__parent = nil
    self.__gpu = GuiProxy(self)
    self.__name = params.name or ""
    self.__visible = true
    self.__y = params.y or 0
    self.__x = params.x or 0
    if params.click ~= nil then
        self.__click_fn = params.click
    end
    if params.focus ~= nil then
        self.__focus_fn = params.focus
    end
    if params.blur ~= nil then
        self.__blur_fn = params.blur
    end
    self.__has_focus = false
end

function ViewComponent:set_parent(parent)
    self.__parent = parent
end

function ViewComponent:get_parent()
    return self.__parent
end

function ViewComponent:get_gpu()
    return self.__gpu
end

function ViewComponent:get_x()
    return self.__x
end

function ViewComponent:set_x(x)
    self.__x = x
end

function ViewComponent:get_y(y)
    return self.__y
end

function ViewComponent:set_y(y)
    self.__y = y
end

function ViewComponent:get_height()
    return 0
end

function ViewComponent:get_width()
    return 0
end

function ViewComponent:render()

end

function ViewComponent:click(x, y)
    if self.__click_fn ~= nil then
        self.__click_fn(x, y)
        self.__gpu:invalidate()
    end
end

function ViewComponent:key_down(char, code)

end

function ViewComponent:clipboard(text)

end

function ViewComponent:show()
    self.__visible = true
    self.__gpu:invalidate()
end

function ViewComponent:hide()
    self.__visible = false
    self.__gpu:invalidate()
end

function ViewComponent:is_visible()
    return self.__visible
end

function ViewComponent:focus()
    if not self.__has_focus then
        self.__has_focus = true
        if self.__focus_fn ~= nil then
            self.__focus_fn()
        end
        self.__gpu:invalidate()
    end
end

function ViewComponent:blur()
    if self.__has_focus then
        self.__has_focus = false
        if self.__blur_fn ~= nil then
            self.__blur_fn()
        end
        self.__gpu:invalidate()
    end
end

function ViewComponent:checkClicked(x, y)
    if self.__visible and x >= self:get_x() and x < self:get_x() + self:get_width() and y >= self:get_y() and y < self:get_y() + self:get_height() then
        self:focus()
        self:click(x - self:get_x(), y - self:get_y())
    else
        self:blur()
    end
end

return static