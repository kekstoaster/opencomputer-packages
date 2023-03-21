local filesystem = require("filesystem")
local serialization = require("serialization")
local io = require("io")

local class = require("class")

local FileMirror, static = class()

function FileMirror:new(path)
    local content

    if filesystem.exists(path) and not filesystem.isDirectory(path) then
        local fp = io.open(path, "r")
        content = fp:read("*a")
        fp:close()
        content = serialization.unserialize(content)
    else
        local dir = filesystem.path(path)
        if not filesystem.isDirectory(dir) then
            local suc, err = filesystem.makeDirectory(dir)
            if not suc then
                return nil, err
            end
        end
        content = {}
    end

    self.__content = content
    self.__path = path
end

function FileMirror:dump()
    return self.__content
end

function FileMirror:save()
    local fp = io.open(self.__path, "w")
    fp:write(serialization.serialize(self.__content))
    fp:close()
end

function FileMirror:get(key)
    if self.__content[key] == nil then
        self.__content[key] = {}
    end
    return self.__content[key]
end

function FileMirror:set(key, value)
    self.__content[key] = value
    self:save()
end

return FileMirrorConstruct