local os = require("os")
local GuiProxy = require("gui/gui_proxy")

local ViewComponent = {}
local ViewComponentMeta = {}
ViewComponentMeta["__index"] = ViewComponentMeta


function ViewComponent:new (a)
    a = a or {}
    local o = {}
    o.parent = nil
    o.gpu = GuiProxy:new(o)
    o.name = a.name or ""
    o.visible = true
    o.y = a.y or 0
    o.x = a.x or 0
    if a.click ~= nil then
        o.click_fn = a.click
    end
    if a.focus ~= nil then
        o.focus_fn = a.focus
    end
    if a.blur ~= nil then
        o.blur_fn = a.blur
    end
    o.has_focus = false
    setmetatable(o, ViewComponentMeta)
    return o
end

function ViewComponent:meta (o)
    o = o or {}
    setmetatable(o, ViewComponentMeta)
    return o
end

function ViewComponentMeta:set_parent(parent)
    self.parent = parent
end

function ViewComponentMeta:get_parent()
    return self.parent
end

function ViewComponentMeta:get_x()
    --return self.parent:get_x() + self.x
    return self.x
end

function ViewComponentMeta:get_y()
    --return self.parent:get_y() + self.y
    return self.y
end

function ViewComponentMeta:get_height()
    return 0
end

function ViewComponentMeta:get_width()
    return 0
end

function ViewComponentMeta:render()

end

function ViewComponentMeta:click(x, y)
    if self.click_fn ~= nil then
        self.click_fn(x, y)
        self.gpu:invalidate()
    end
end

function ViewComponentMeta:key_down(char, code)

end

function ViewComponentMeta:clipboard(text)

end

function ViewComponentMeta:show()
    self.visible = true
    self.gpu:invalidate()
end

function ViewComponentMeta:hide()
    self.visible = false
    self.gpu:invalidate()
end

function ViewComponentMeta:focus()
    if not self.has_focus then
        self.has_focus = true
        if self.focus_fn ~= nil then
            self.focus_fn()
        end
        self.gpu:invalidate()
    end
end

function ViewComponentMeta:blur()
    if self.has_focus then
        self.has_focus = false
        if self.blur_fn ~= nil then
            self.blur_fn()
        end
        self.gpu:invalidate()
    end
end

function ViewComponentMeta:checkClicked(x, y)
    if self.visible and x >= self:get_x() and x < self:get_x() + self:get_width() and y >= self:get_y() and y < self:get_y() + self:get_height() then
        self:focus()
        self:click(x - self:get_x(), y - self:get_y())
    else
        self:blur()
    end
end



return ViewComponent