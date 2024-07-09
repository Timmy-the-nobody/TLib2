---`🔸 Client`<br>`🔹 Server`<br>
---Returns a sequential table of all usergroups
---@param bIgnoreULX boolean @Whether to ignore ULX usergroups
---@param bIgnoreGExtension boolean @Whether to ignore GExtension usergroups
---@return table <number, string> @The list of usergroups
function TLib2.GetUsergroupsList(bIgnoreULX, bIgnoreGExtension)
    local tGroups = {}

    if not bIgnoreULX then
        if xgui and xgui.data and xgui.data.groups then
            tGroups = xgui.data.groups
        end
    end

    if not bIgnoreGExtension then
        if GExtension and GExtension.Groups then
            for sGroup, _ in pairs(GExtension.Groups) do
                tGroups[#tGroups + 1] = sGroup
            end
        end
    end

    return tGroups
end