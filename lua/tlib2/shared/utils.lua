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