local event = require("event")

local GuiApp = {}
GuiApp["__index"] = GuiApp


function GuiApp:new (a)
    a = a or {}
    local o = {}
    o.screens = {}
    o.active_screen = nil
    o.active_name = nil
    o.needs_render = true
    o.state = {}

    setmetatable(o, GuiApp)
    return o
end

function GuiApp:get_state (name)
    if self.state[name] == nil then
        self.state[name] = {}
    end
    return self.state[name]
end

function GuiApp:reset_state (name)
    self.state[name] = {}
    return self.state[name]
end

function GuiApp:set_state (name, value)
    self.state[name] = value
end

function GuiApp:add_screen (name, screen)
    self.screens[name] = screen
    if self.active_screen == nil then
        self.needs_render = true
        self.active_screen = screen
        self.active_name = name
    end
end

function GuiApp:select_screen (name)
    if self.screens[name] ~= nil then
        self.active_screen:clear()
        self.needs_render = true
        self.active_screen = self.screens[name]
        self.active_name = name
    end
end

function GuiApp:invalidate ()
    self.needs_render = true
end

function GuiApp:render ()
    if self.needs_render and self.active_screen ~= nil then
        self.needs_render = false
        if self.active_screen ~= nil then
            self.active_screen:render()
        end
    end
end

function GuiApp:run ()
    self.active_screen:clear()
    while true do
        self:render()
        local id, _, x, y = event.pullMultiple("touch", "key_down", "clipboard", "interrupted", "render", "screen")
        if id == "interrupted" then
            --print("soft interrupt, closing")
            break
        elseif id == "touch" then
            if self.active_screen ~= nil then
                self.active_screen:click(x, y)
            end
            -- print("user clicked", x, y)
        elseif id == "key_down" then
            if self.active_screen ~= nil then
                self.active_screen:key_down(x, y)
            end
        elseif id == "clipboard" then
            if self.active_screen ~= nil then
                self.active_screen:clipboard(x)
            end
        elseif id == "render" then
            self:invalidate()
        elseif id == "screen" then
            self:select_screen(x)
        end
    end
end

return GuiApp