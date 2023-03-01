local filesystem = require("filesystem")
local serialization = require("serialization")
local io = require("io")



local FileMirrorConstruct = {}
local FileMirrorMeta = {}
FileMirrorMeta["__index"] = FileMirrorMeta

FileMirrorConstruct["__index"] = FileMirrorConstruct

function FileMirrorConstruct(path)
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

    local o = {}
    o.content = content
    o.path = path

    setmetatable(o, FileMirrorMeta)
    return o
end

function FileMirrorMeta:dump()
    return self.content
end

function FileMirrorMeta:save()
    local fp = io.open(self.path, "w")
    fp:write(serialization.serialize(self.content))
    fp:close()
end

function FileMirrorMeta:get(key)
    if self.content[key] == nil then
        self.content[key] = {}
    end
    return self.content[key]
end

function FileMirrorMeta:set(key, value)
    self.content[key] = value
    self:save()
end

return FileMirrorConstruct