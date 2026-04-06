local function object_new()

end

local function object()
    return {["new"] = object_new}
end

local function new_class(base)
    base = base or object
    base = base()

    local class = {}
    local meta = {["__index"]=class}
    setmetatable(class, {["__index"]=base})

    local function construct(func, ...)
        local o = {}
        setmetatable(o, meta)
        o:new(...)
        return o
    end

    local construct_obj = {}
    setmetatable(construct_obj, {["__call"]=construct})

    return class, construct_obj, base
end



return new_class
