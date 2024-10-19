local table = table
local string = string
local os = os
local type = type

---`🔸 Client`<br>`🔹 Server`<br>
---Returns a sequential table of all usergroups
---@param bIgnoreULX boolean @Whether to ignore ULX usergroups (https://github.com/TeamUlysses/ulx)
---@param bIgnoreGExtension boolean @Whether to ignore GExtension usergroups (https://www.gmodstore.com/market/view/gextension-the-all-in-one-package-for-your-community)
---@param bIgnoreXAdmin boolean @Whether to ignore xAdmin usergroups (https://github.com/TheXYZNetwork/xAdmin)
---@return table <number, string> @The list of usergroups
function TLib2.GetUsergroupsList(bIgnoreULX, bIgnoreGExtension, bIgnoreXAdmin)
    local tGroups = {}

    if not bIgnoreULX and xgui and xgui.data and xgui.data.groups then
        tGroups = xgui.data.groups
    end

    if not bIgnoreGExtension and GExtension and GExtension.Groups then
        tGroups = table.GetKeys(GExtension.Groups)
    end

    if not bIgnoreXAdmin and xAdmin and xAdmin.Groups then
        tGroups = table.GetKeys(xAdmin.Groups)
    end

    return tGroups
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns a sequential table of all standard teams, sorted by name
---@return table <number, table> @The list of teams
function TLib2.GetTeamsList()
    local tTeams = {}

    for iID, tTeam in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
        if (iID <= 0) or (iID > 1000) then continue end
        tTeams[#tTeams + 1] = tTeam
    end

    return tTeams
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the maximum value of an unsigned integer for the given bitcount
---@param iBitCount integer @The bitcount
---@return integer
function TLib2.GetMaxUnsignedInt(iBitCount)
    return (2 ^ iBitCount) - 1
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the minimum value of an signed integer for the given bitcount
---@param iBitCount integer @The bitcount
---@return integer
function TLib2.GetMaxSignedInt(iBitCount)
    return (2 ^ (iBitCount - 1)) - 1
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the minimum value of an signed integer for the given bitcount
---@param iBitCount integer @The bitcount
---@return integer
function TLib2.GetMinSignedInt(iBitCount)
    return -(2 ^ (iBitCount - 1))
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the money of the given player (wrapper for DarkRP, nutscript, and helix)
---@param pPlayer Player @The player
---@return number
function TLib2.GetMoney(pPlayer)
    if DarkRP then
        return pPlayer:getDarkRPVar("money") or 0
    end
    if nut and pPlayer.GetMoney then
        return pPlayer:GetMoney()
    end
    if ix and pPlayer.GetCharacter then
        local eChar = pPlayer:GetCharacter()
        if not eChar or not eChar.GetMoney then return 0 end
        return eChar:GetMoney()
    end
    return 0
end

---`🔸 Client`<br>`🔹 Server`<br>
---Sets the money of the given player (wrapper for DarkRP, nutscript, and helix), does nothing when called on the client
---@param pPlayer Player @The player
---@param iMoney number @The money
function TLib2.SetMoney(pPlayer, iMoney)
    if CLIENT then return end
    if DarkRP then
        return pPlayer:setDarkRPVar("money", iMoney)
    end
    if nut and pPlayer.SetMoney then
        return pPlayer:SetMoney(iMoney)
    end
    if ix and pPlayer.GetCharacter then
        local eChar = pPlayer:GetCharacter()
        if not eChar or not eChar.SetMoney then return end
        eChar:SetMoney(iMoney)
    end
end

---`🔸 Client`<br>`🔹 Server`<br>
---Adds money to the given player (wrapper for DarkRP, nutscript, and helix)
---@param pPlayer Player @The player
---@param iMoney number @The money
function TLib2.AddMoney(pPlayer, iMoney)
    if DarkRP then
        return pPlayer:addMoney(iMoney)
    end
    if nut and pPlayer.GiveMoney then
        return pPlayer:GiveMoney(iMoney)
    end
    if ix and pPlayer.GetCharacter then
        return TLib2.SetMoney(pPlayer, TLib2.GetMoney(pPlayer) + iMoney)
    end
end

---`🔸 Client`<br>`🔹 Server`<br>
---Checks if the given filter matches any of the given strings
---@param sFilter string @The filter
---@param ... string @The strings
---@return boolean
function TLib2.SearchTerm(sFilter, ...)
    if (type(sFilter) ~= "string") or (#sFilter == 0) then
        return true
    end

    local tInput = {...}
    for i = 1, #tInput do
        local sInput = tInput[i]
        if (type(sInput) == "string") and string.find(sInput, sFilter, 1, true) then
            return true
        end
    end

    return false
end