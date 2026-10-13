--!strict
--[=[
    Silverline UI Framework
    Module: Systems/Cleanup.lua
    Purpose: Deterministic lifecycle and resource cleanup manager (Maid/Janitor pattern).
]=]

local Cleanup = {}
Cleanup.__index = Cleanup

export type CleanupTask = Instance | RBXScriptConnection | () -> () | { Destroy: (any) -> () } | { Clean: (any) -> () }

function Cleanup.new()
    local self = setmetatable({
        _tasks = {} :: { [any]: CleanupTask },
        _isCleaning = false,
        _destroyed = false,
    }, Cleanup)
    return self
end

function Cleanup:Add(task: CleanupTask): CleanupTask
    if self._destroyed then
        Cleanup._cleanTask(task)
        return task
    end

    table.insert(self._tasks, task)
    return task
end

function Cleanup:AddNamed(key: string, task: CleanupTask): CleanupTask
    if self._destroyed then
        Cleanup._cleanTask(task)
        return task
    end

    if self._tasks[key] then
        Cleanup._cleanTask(self._tasks[key])
    end
    self._tasks[key] = task
    return task
end

function Cleanup:Remove(keyOrTask: any)
    if self._tasks[keyOrTask] then
        self._tasks[keyOrTask] = nil
    else
        for i, task in ipairs(self._tasks) do
            if task == keyOrTask then
                table.remove(self._tasks, i)
                break
            end
        end
    end
end

function Cleanup._cleanTask(task: CleanupTask)
    if typeof(task) == "RBXScriptConnection" then
        task:Disconnect()
    elseif typeof(task) == "Instance" then
        task:Destroy()
    elseif typeof(task) == "function" then
        local success, err = pcall(task)
        if not success then
            warn("[Silverline Cleanup] Error executing cleanup function: " .. tostring(err))
        end
    elseif typeof(task) == "table" then
        if typeof((task :: any).Destroy) == "function" then
            local success, err = pcall(function()
                (task :: any):Destroy()
            end)
            if not success then
                warn("[Silverline Cleanup] Error destroying object: " .. tostring(err))
            end
        elseif typeof((task :: any).Clean) == "function" then
            local success, err = pcall(function()
                (task :: any):Clean()
            end)
            if not success then
                warn("[Silverline Cleanup] Error cleaning object: " .. tostring(err))
            end
        end
    end
end

function Cleanup:Clean()
    if self._isCleaning then return end
    self._isCleaning = true

    for key, task in pairs(self._tasks) do
        Cleanup._cleanTask(task)
        self._tasks[key] = nil
    end

    self._isCleaning = false
end

function Cleanup:Destroy()
    if self._destroyed then return end
    self:Clean()
    self._destroyed = true
end

return Cleanup
