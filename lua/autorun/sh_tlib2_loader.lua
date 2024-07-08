TLib2 = TLib2 or {}

local function requireSH(sPath)
    if SERVER then
        AddCSLuaFile(sPath)
    end
    return include(sPath)
end

local function requireSV(sPath)
    if not SERVER then return end
    return include(sPath)
end

local function requireCL(sPath)
    if SERVER then
        AddCSLuaFile(sPath)
    end
    if CLIENT then
        return include(sPath)
    end
end

hook.Add("OnGamemodeLoaded", "TLib2:OnGamemodeLoaded", function()
    -- Client
    ------------------------------------------------------------------
    requireCL("tlib2/client/init.lua")
    requireCL("tlib2/client/fonts.lua")
    requireCL("tlib2/client/utils.lua")
end)