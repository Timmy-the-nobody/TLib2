local hook = hook
local type = type
local CurTime = CurTime

TLib2.__fadein_hooks = TLib2.__fadein_hooks or {}
TLib2.__fadein_hook_id = TLib2.__fadein_hook_id or 0

---`🔸 Client`<br>
---Fades an audio channel to a specific volume
---@param oAudioChannel IGModAudioChannel @The audio channel
---@param fDuration? number @Duration in seconds, defaults to 1
---@param fEndVol? number @End volume, defaults to 1
---@param onFinish? function @Function to call when the fade is complete
function TLib2.FadeAudioChannel(oAudioChannel, fDuration, fEndVol, onFinish)
    if (type(oAudioChannel) ~= "IGModAudioChannel") or not oAudioChannel:IsValid() then
        return
    end

    if TLib2.__fadein_hooks[oAudioChannel] then
        hook.Remove("Think", "TLib2:FadeAudioChannel:"..TLib2.__fadein_hooks[oAudioChannel])
        TLib2.__fadein_hooks[oAudioChannel] = nil
    end
    
    TLib2.__fadein_hook_id = (TLib2.__fadein_hook_id + 1)
    TLib2.__fadein_hooks[oAudioChannel] = TLib2.__fadein_hook_id
    
    local fStart = CurTime()
    local fStartVol = oAudioChannel:GetVolume()
    local sHook = "TLib2:FadeAudioChannel:"..TLib2.__fadein_hooks[oAudioChannel]

    hook.Add("Think", sHook, function()
        if not oAudioChannel or not oAudioChannel:IsValid() then
            hook.Remove("Think", sHook)
            TLib2.__fadein_hooks[oAudioChannel] = nil
            return
        end

        local fElapsed = (CurTime() - fStart)
        if (fElapsed >= fDuration) then
            oAudioChannel:SetVolume(fEndVol)

            hook.Remove("Think", sHook)
            TLib2.__fadein_hooks[oAudioChannel] = nil

            if (type(onFinish) == "function") then
                onFinish(oAudioChannel)
            end
            return
        end

        local fNewVolume = fStartVol + (fEndVol - fStartVol) * (fElapsed / fDuration)
        oAudioChannel:SetVolume(fNewVolume)
    end)
end