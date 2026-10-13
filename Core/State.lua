--!strict
--[=[
    Silverline UI Framework
    Module: Core/State.lua
    Purpose: Reactive state container with observable change notifications.
]=]

local State = {}
State.__index = State

export type Listener<T> = (newValue: T, oldValue: T) -> ()

function State.new<T>(initialValue: T)
    local self = setmetatable({
        _value = initialValue,
        _listeners = {} :: { Listener<T> },
        _destroyed = false,
    }, State)
    return self
end

function State:Get<T>(): T
    return self._value
end

function State:Set<T>(newValue: T, suppressListeners: boolean?): boolean
    if self._destroyed then return false end
    local oldValue = self._value
    if oldValue == newValue then
        return false
    end

    self._value = newValue

    if not suppressListeners then
        for _, listener in ipairs(self._listeners) do
            local success, err = pcall(listener, newValue, oldValue)
            if not success then
                warn("[Silverline State] Error in listener callback: " .. tostring(err))
            end
        end
    end

    return true
end

function State:Listen<T>(listener: Listener<T>): () -> ()
    if self._destroyed then
        return function() end
    end

    table.insert(self._listeners, listener)

    return function()
        local idx = table.find(self._listeners, listener)
        if idx then
            table.remove(self._listeners, idx)
        end
    end
end

function State:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    table.clear(self._listeners)
end

return State
