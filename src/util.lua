
local M = { }

function M.new_class(typetbl)
    typetbl.__index = typetbl
    setmetatable(typetbl, {
        __call = function(cls, ...)
            return cls.new(...)
        end,
    })
    return typetbl
end
local function shallow_copy(table)
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

---@param o table | nil
---@param typeobj table
---@param default table | nil
function M.new_init(o, typeobj, default)
    local defcpy = shallow_copy(default)
    o = o or {}
    for k, v in pairs(defcpy) do
        o[k] = o[k] or v
    end

    local self = setmetatable(o, typeobj)
    self.__index = self
    return self
end

function M.new_init_fn(typeobj, default)
    return function(o)
        return M.new_init(o, typeobj, default)
    end
end



function M.empty_fn(...) end

M.empty_alias = "empty"

function M.on_message_map(message_mapping)
    local function on_message(self, message_id, message, sender)
        local action = message_mapping[message_id or M.empty_alias]
        if action then
            action(self, message_id, message, sender)
        elseif action ~= false then
            local wrn_msg = string.format(
                "%s have unhandled message of id: %s from %s",
                tostring(msg.url()),
                tostring(message_id),
                tostring(sender)
            )
            print(wrn_msg)
        end
    end
    return on_message
end

function M.on_input_map(input_mapping)
    local function on_input(self, action_id, action)
        local func = input_mapping[action_id or M.empty_alias]
        if func then
            func(self, action_id, action)
        elseif action ~= false and sys.get_engine_info().debug then
            local wrn_msg = string.format("%s did not handle input of id: %s", tostring(msg.url()), tostring(action_id))
            print(wrn_msg)
        end
    end
    return on_input
end

function M.assert_contains(object, properties)
    for _, k in ipairs(properties) do
        assert(object[k], string.format("object does not contain property: %s", k))
    end
end

function M.shallow_copy(table)
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

function M.ModuloWrap(one_indexed, n, delta)
    local zero_indexed = one_indexed - 1
    local modulo_wrap = (zero_indexed + delta) % n
    return modulo_wrap + 1
end

function M.irange(i)
    local _i = 0
    return function()
        _i = _i + 1
        if _i <= i then
            return _i
        end
    end
end

local ran_names = {}
function M.run_once(name, fn)
    if ran_names[name] == nil then
        ran_names[name] = 1
        fn()
    end
end
function M.map(value, istart, istop, ostart, ostop)
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
end

return M
