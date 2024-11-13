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
---@return integer @The maximum value
function TLib2.GetMaxUnsignedInt(iBitCount)
    return (2 ^ iBitCount) - 1
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the maximum value of a signed integer for the given bitcount
---@param iBitCount integer @The bitcount
---@return integer @The maximum value
function TLib2.GetMaxSignedInt(iBitCount)
    return (2 ^ (iBitCount - 1)) - 1
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the minimum value of a signed integer for the given bitcount
---@param iBitCount integer @The bitcount
---@return integer @The minimum value
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

---`🔸 Client`<br>`🔹 Server`<br>
---Checks if the given date is valid
---@param iYear number @The year
---@param iMonth number @The month
---@param iDay number @The day
---@return boolean @Whether the date is valid or not
function TLib2.IsDateValid(iYear, iMonth, iDay)
    if (type(iYear) ~= "number") or (type(iMonth) ~= "number") or (type(iDay) ~= "number") then
        return false
    end

    local iTimestamp = os.time({year = iYear, month = iMonth, day = iDay})
    if not iTimestamp then return false end

    local tValidDate = os.date("*t", iTimestamp)
    return (tValidDate.year == iYear and tValidDate.month == iMonth and tValidDate.day == iDay)
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the day of the week of the given date
---@param iYear number @The year
---@param iMonth number @The month
---@param iDay number @The day
---@return number @The day of the week (1 = Sunday, 7 = Saturday)
function TLib2.GetDayOfWeek(iYear, iMonth, iDay)
    return tonumber(os.date("%w", os.time({year = iYear, month = iMonth, day = iDay}))) + 1
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the number of days in the given month
---@param iYear number @The year
---@param iMonth number @The month
---@return number @The number of days in the month
function TLib2.GetDaysInMonth(iYear, iMonth)
    return tonumber(os.date("%d", os.time({year = iYear, month = iMonth + 1, day = 1}) - 86400))
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the first day of the given month
---@param iYear number @The year
---@param iMonth number @The month
---@return number @The first day of the month (1 = Sunday, 7 = Saturday)
function TLib2.GetFirstDayOfMonth(iYear, iMonth)
    return TLib2.GetDayOfWeek(iYear, iMonth, 1)
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the last day of the given month
---@param iYear number @The year
---@param iMonth number @The month
---@return number @The last day of the month (1 = Sunday, 7 = Saturday)
function TLib2.GetLastDayOfMonth(iYear, iMonth)
    return TLib2.GetDayOfWeek(iYear, iMonth, TLib2.GetDaysInMonth(iYear, iMonth))
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the timestamp from the given date
---@param iYear number @The year
---@param iMonth number @The month
---@param iDay number @The day.
---@param iHour number? @The hour
---@param iMin number? @The minute
---@return number? @The timestamp
function TLib2.DateToTimestamp(iYear, iMonth, iDay, iHour, iMin, iSec)
    if not TLib2.IsDateValid(iYear, iMonth, iDay) then return end

    return os.time({
        year = iYear,
        month = iMonth,
        day = iDay,
        hour = iHour or 0,
        min = iMin or 0,
        sec = iSec or 0
    })
end

---`🔸 Client`<br>`🔹 Server`<br>
---Returns the date from the given timestamp
---@param iTimestamp number @The timestamp
---@return number @The year
---@return number @The month
---@return number @The day
---@return number @The hour
---@return number @The minute
---@return number @The second
function TLib2.TimestampToDate(iTimestamp)
    if (type(iTimestamp) ~= "number") or (iTimestamp < 0) then return end

    local tDate = os.date("*t", iTimestamp)
    if not tDate then return end

    return tDate.year, tDate.month, tDate.day, tDate.hour, tDate.min, tDate.sec
end

local tTimeValues = {
    {label = "y", seconds = 31536000},
    {label = "m", seconds = 2592000},
    {label = "w", seconds = 604800},
    {label = "d", seconds = 86400},
    {label = "h", seconds = 3600},
    {label = "min", seconds = 60},
    {label = "s", seconds = 1}
}

---`🔸 Client`<br>`🔹 Server`<br>
---Returns a human readable time string from the given number of seconds
---@param iSeconds number @The number of seconds
---@param bAbbreviated boolean @Whether the time string should be abbreviated
---@param iMaxValues integer @The maximum amount of values to return (ex: if 2 is give, it will return "2m 5min" instead of "2h 5min 2s")
---@return string @The human readable time string
function TLib2.FormatTime(iSeconds, iMaxValues)
    local iTime = math.floor(iSeconds)
    if (iTime <= 0) then
        return "0s"
    end

    local sTimeStr = ""
    local iValues = 0

    for i = 1, #tTimeValues do
        local v = tTimeValues[i]

        local iVal = math.floor(iTime / v.seconds)
        if (iVal <= 0) then continue end

        iTime = (iTime - (iVal * v.seconds))
        sTimeStr = sTimeStr..iVal..v.label.." "
        iValues = (iValues + 1)

        if (type(iMaxValues) == "number") and (iValues >= iMaxValues) then
            return sTimeStr:sub(1, -2)
        end
    end

    return sTimeStr:sub(1, -2)
end