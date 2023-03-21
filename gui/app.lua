local event = require("event")
local serialization = require("serialization")
local class = require("class")

local GuiApp, static = class()

function GuiApp:new(params)
    params = params or {}
    self.__screens = {}
    self.__active_screen = nil
    self.__active_name = nil
    self.__needs_render = true
    self.__state = {}
    self.__events = {}
    self.__event_list = {
        "touch", "key_down", "clipboard", "interrupted", "render", "screen"
    }
end

function GuiApp:get_state(name)
    if self.__state[name] == nil then
        self.__state[name] = {}
    end
    return self.__state[name]
end

function GuiApp:reset_state(name)
    self.__state[name] = {}
    return self.__state[name]
end

function GuiApp:set_state(name, value)
    self.__state[name] = value
end

function GuiApp:add_event(name, callback)
    if type(callback) == "function" and self.__events[name] == nil then
        table.insert(self.__event_list, name)
        self.__events[name] = callback
    end
end

function GuiApp:add_screen(name, screen)
    self.__screens[name] = screen
    if self.__active_screen == nil then
        self:select_screen(name)
    end
end

function GuiApp:select_screen(name, ...)
    if self.__screens[name] ~= nil then
        if self.__active_screen ~= nil then
            self.__active_screen:clear()
        end
        self.__needs_render = true
        self.__active_screen = self.__screens[name]
        self.__active_screen:init(...)
        self.__active_name = name
    end
end

function GuiApp:invalidate ()
    self.__needs_render = true
end

function GuiApp:render ()
    if self.__needs_render and self.__active_screen ~= nil then
        self.__needs_render = false
        if self.__active_screen ~= nil then
            self.__active_screen:render()
        end
    end
end

function GuiApp__process_event(self, id, ...)
    if type(self["on_" .. id]) == "function" then
        self["on_" .. id](self, ...)
    elseif type(self.__events[id]) == "function" then
        self.__events[id](...)
    end
end

function GuiApp:run()
    self.__active_screen:clear()
    while true do
        self:render()

        local params = table.pack(event.pullMultiple(table.unpack(self.__event_list)))
        if params[1] == "interrupted" then
            break
        else
            GuiApp__process_event(self, table.unpack(params))
        end
    end
end

function GuiApp:on_touch(_, x, y, button, player)
    if self.__active_screen ~= nil then
        self.__active_screen:click(x, y)
    end
end

function GuiApp:on_key_down(_, char, code, player)
    if self.__active_screen ~= nil then
        self.__active_screen:key_down(char, code)
    end
end

function GuiApp:on_clipboard(_, value, player)
    if self.__active_screen ~= nil then
        self.__active_screen:clipboard(value)
    end
end

function GuiApp:on_render()
    self:invalidate()
end

function GuiApp:on_screen(screen, ...)
    self:select_screen(screen, ...)
end

return static