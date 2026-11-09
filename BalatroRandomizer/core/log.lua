BR.Log = BR.Log or {}

local function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function BR.Log:init()
    self.directory = "/logs"
    self.file = self.directory .. "/BalatroRandomizer.log"
    self.fallback_file = "BalatroRandomizer.log"
    self.initialized = false
    self.path = nil
    self.error = nil

    if not love or not love.filesystem then
        self.error = "love.filesystem is unavailable"
        return false
    end

    local directory_ok = love.filesystem.createDirectory(self.directory)
    local target = self.file

    if directory_ok then
        local created, create_err = love.filesystem.write(target, "")
        if not created then
            self.error = tostring(create_err or "unable to create log file")
            target = self.fallback_file
        end
    else
        self.error = "unable to create log directory"
        target = self.fallback_file
    end

    if target == self.fallback_file then
        local created, create_err = love.filesystem.write(target, "")
        if not created then
            self.error = tostring(create_err or self.error or "unable to create fallback log file")
            return false
        end
    end

    self.file = target
    self.path = love.filesystem.getSaveDirectory() .. "/" .. target
    self.initialized = true
    self:write("============================================================")
    self:write(string.format("Session started | Balatro Randomizer %s", tostring(BR.version or "unknown")))
    self:write(string.format("Save directory: %s", tostring(love.filesystem.getSaveDirectory())))
    self:write(string.format("Log file: %s", tostring(self.path)))
    if self.error then
        self:write(string.format("Primary log path unavailable: %s", self.error))
    end
    return true
end

function BR.Log:write(message)
    if not self.initialized or not love or not love.filesystem then return false end
    local line = string.format("[%s] %s\n", timestamp(), tostring(message))
    local ok = love.filesystem.append(self.file, line)
    if not ok then
        return false
    end
    return true
end

function BR.Log:info(message)
    return self:write(message)
end

function BR.Log:get_path()
    return self.path
end
