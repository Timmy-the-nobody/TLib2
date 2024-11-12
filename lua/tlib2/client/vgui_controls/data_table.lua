
local surface = surface
local draw = draw
local render = render

local Lerp = Lerp
local RealFrameTime = RealFrameTime

local matGradDown = Material("vgui/gradient-d", "noclamp smooth")
local fDragAnchorW = 0.036

---@class TLib2:DataTable : DPanel
local PANEL = {}

function PANEL:Init()
    local dDataTbl = self

    self.columns = {}
    self.rows = {}
    self.data = {}
    self.sorted_data = {}
    self.row_buttons = {}
    self.empty_text = "No data"

    self.columns_container = self:Add("DPanel")
    self.columns_container:SetTall(ScrH() * 0.03)
    self.columns_container:Dock(TOP)
    self.columns_container:DockMargin(0, 0, 0, TLib2.Padding4)
    function self.columns_container:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawLine(0, 0, iW, 0)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end

    local dFakeAnchor = self.columns_container:Add("DPanel")
    dFakeAnchor:SetPos(0, 0)
    dFakeAnchor:Dock(LEFT)
    dFakeAnchor:SetWide(ScrH() * fDragAnchorW)
    dFakeAnchor.Paint = nil
    dFakeAnchor.is_empty_anchor = true

    self.scroll = self:Add("TLib2:Scroll")
    self.scroll:Dock(FILL)
end

---`🔸 Client`<br>
---Sets the visibility of the columns container
---@param bVisible boolean @Whether the columns container is visible
function PANEL:SetColumnsVisible(bVisible)
    self.columns_container:SetVisible(tobool(bVisible))
end

---`🔸 Client`<br>
---Adds a column to the data table
---@param sLabel string @Label of the column
---@param fnSelector function @Function that returns the data of the column
---@param fnFormat function @Function that formats the data of the column
---@param bSortable boolean @Whether the column is sortable
function PANEL:AddColumn(sLabel, fnSelector, fnFormat, bSortable)
    local dDataTbl = self
    local iColumn = (#self.columns + 1)

    sLabel = (type(sLabel) == "string") and sLabel or ("Column "..iColumn)
    fnSelector = (type(fnSelector) == "function") and fnSelector or function() return "N/A" end
    fnFormat = (type(fnFormat) == "function") and fnFormat or nil
    bSortable = tobool(bSortable)

    self.columns[iColumn] = {
        index = iColumn,
        label = sLabel,
        selector = fnSelector,
        format = fnFormat,
        sortable = bSortable,
        sort_asc = false,
    }

    local dColumn = self.columns_container:Add("DButton")
    self.columns[iColumn].panel = dColumn

    dColumn:Dock(LEFT)
    dColumn:SetText(string.upper(sLabel))
    dColumn:SetFont("TLib2.7")
    dColumn:SetContentAlignment(4)
    dColumn:SetTextInset(TLib2.Padding3, 0)
    dColumn:SetTextColor(TLib2.Colors.Base3)
    dColumn.hover_lerp = 0

    function dColumn:Paint(iW, iH)
        self.hover_lerp = Lerp(RealFrameTime() * 16, self.hover_lerp, self:IsHovered() and 1 or 0)
        if (self.hover_lerp > 0.001) then
            local fGradH = math.floor(iH * self.hover_lerp)
            surface.SetMaterial(matGradDown)
            surface.SetDrawColor(TLib2.Colors.Base1)
            surface.DrawTexturedRect(0, (iH - fGradH) - 1, iW, fGradH)
        end

        surface.SetDrawColor(TLib2.Colors.Base2)
        if (iColumn == 1) then
            surface.DrawLine(0, 0, 0, iH - 1)
        end
        surface.DrawLine(iW - 1, 0, iW - 1, iH - 1)

        if not bSortable then return end

        local sFA = dDataTbl.columns[iColumn].sort_asc and "f0d7" or "f0d8"
        if dDataTbl.sorted_column and (dDataTbl.sorted_column == iColumn) then
            TLib2.DrawFAIcon(sFA, "TLib2.FA.6", iW - TLib2.Padding3, (iH * 0.5), TLib2.Colors.Base3, 2, 1)
        else
            TLib2.DrawFAIcon(sFA, "TLib2.FA.6", iW - TLib2.Padding3, (iH * 0.5), TLib2.Colors.Base2, 2, 1)
        end
    end

    function dColumn:DoClick()
        dDataTbl.columns[iColumn].sort_asc = not dDataTbl.columns[iColumn].sort_asc
        dDataTbl:Sort(iColumn, dDataTbl.columns[iColumn].sort_asc)
    end
end

---`🔸 Client`<br>
---Sets the data of the data table
---@param tData table @Data of the table
function PANEL:SetData(tData)
    if (type(tData) ~= "table") then return end

    self.data = tData

    self.sorted_data = {}
    for xKey, xData in pairs(tData) do
        self.sorted_data[xKey] = xData
    end

    self:UpdateRows()
end

---`🔸 Client`<br>
---Updates the rows of the data table
function PANEL:UpdateRows()
    local iVBarScroll = self.scroll:GetVBar():GetScroll()

    self.scroll:Clear()
    self.rows = {}

    for xKey, xData in pairs(self.sorted_data) do
        local tLabels = {}
        for iColumn = 1, #self.columns do
            local sLabel = self.columns[iColumn].selector(xData)
            tLabels[iColumn] = sLabel
        end
        self:AddRow(xData, unpack(tLabels))
    end

    self.scroll:GetVBar():SetScroll(iVBarScroll)
end

---`🔸 Client`<br>
---Sorts the data table by a column
---@param iColumn number @Index of the column to sort by
---@param bAsc boolean @Whether to sort in ascending order
function PANEL:Sort(iColumn, bAsc)
    if not self.columns[iColumn].sortable then return end

    self.sorted_column = iColumn

    table.sort(self.sorted_data, function(xA, xB)
        local xSelectorA = self.columns[iColumn].selector(xA)
        local xSelectorB = self.columns[iColumn].selector(xB)

        if (type(xSelectorA) == "number") and (type(xSelectorB) == "number") then
            if bAsc then
                return (xSelectorA > xSelectorB)
            else
                return (xSelectorA < xSelectorB)
            end
        end

        return (bAsc and true or false)
    end)

    self:UpdateRows()
end

---`🔸 Client`<br>
---Adds a row button to the data table
---@param sFAIcon string @Font Awesome icon
---@param sLabel string @Label of the button
---@param fnDoClick function @Function that is called when the button is clicked
function PANEL:AddRowButton(sFAIcon, sLabel, fnDoClick)
    self.row_buttons[#self.row_buttons + 1] = {
        icon = sFAIcon or "f013",
        label = sLabel or "",
        do_click = fnDoClick
    }

    self:UpdateRows()
end

---`🔸 Client`<br>
---Adds a row to the data table
---@param xData any @Data of the row
---@param ... string @Labels of the columns
function PANEL:AddRow(xData, ...)
    local tColumnContent = {...}

    local dDataTbl = self
    local iRow = (#self.rows + 1)

    local dRow = self.scroll:Add("DPanel")
    dRow:Dock(TOP)
    dRow:SetTall(ScrH() * 0.06)
    dRow.is_data_table_row = true
    dRow.bg_color = (iRow % 2 == 0) and TLib2.ColorManip(TLib2.Colors.Base1, 1, 0.7) or TLib2.ColorManip(TLib2.Colors.Base1, 1, 0.8)
    dRow.data = xData

    self.rows[iRow] = dRow

    function dRow:IsHovered()
        local dHovered = vgui.GetHoveredPanel()
        if not dHovered then return false end
        if (dHovered == self) then return true end

        return self:IsChildHovered(false)
    end

    function dRow:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self:IsHovered() and TLib2.Colors.Base1 or self.bg_color)
    end

    function dRow:OnMousePressed(iButton)
        if (iButton ~= MOUSE_LEFT) then return end
        dDataTbl.scroll:ScrollToChild(self)
    end

    function dRow:PerformLayout(iW, iH)
        local tRowChilds = self:GetChildren()
        local tHeaderChilds = dDataTbl.columns_container:GetChildren()

        for iColumn = 1, #tRowChilds do
            if not tHeaderChilds[iColumn] then continue end
            tRowChilds[iColumn]:SetWide(tHeaderChilds[iColumn]:GetWide())
        end
    end

    -- Drag anchor
    dRow.drag_anchor = dRow:Add("TLib2:DataTableDragAnchor")
    dRow.drag_anchor:Dock(LEFT)
    dRow.drag_anchor:SetWide(ScrH() * fDragAnchorW)
    dRow.drag_anchor.drop_data = {
        parent = self,
        row = dRow,
        index = iRow
    }

    -- Row content (columns)
    for iColumn = 1, #tColumnContent do
        local dContent = dRow:Add("DLabel")
        dContent:Dock(LEFT)
        dContent:SetText(tColumnContent[iColumn])
        dContent:SetFont("TLib2.6")
        dContent:SetContentAlignment(4)
        dContent:SetTextInset(TLib2.Padding3, 0)
        dContent:SetTextColor(TLib2.Colors.Base4)

        if self.columns[iColumn] and self.columns[iColumn].format then
            self.columns[iColumn].format(dContent, self.sorted_data[iRow], iRow, iColumn)
        end
    end

    if self.row_buttons then
        for i = 1, #self.row_buttons do
            local tButton = self.row_buttons[i]
            tButton.vgui = dRow:Add("TLib2:Button")

            local dButton = tButton.vgui
            dButton:SetText("")
            dButton:Dock(RIGHT)
            dButton:SetWide(dRow:GetTall())
            dButton:SetFont("TLib2.6")
            dButton:SetTextColor(TLib2.Colors.Base4)
            dButton:SetContentAlignment(4)
            dButton:SetTextInset(TLib2.Padding3, 0)
            dButton.lerp_hover = 0

            function dButton:Paint(iW, iH)
                self.lerp_hover = Lerp(RealFrameTime() * 8, self.lerp_hover, self:IsHovered() and 1 or 0)

                TLib2.DrawFAIcon("f111", "TLib2.FA.2", (iW * 0.5), (iH * 0.5), dRow:IsHovered() and TLib2.Colors.Base0 or TLib2.Colors.Base1, 1, 1)
                TLib2.DrawFAIcon(tButton.icon, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base3, 1, 1)

                if (self.lerp_hover > 0.1) then
                    local iX, iY = self:LocalToScreen(0, 0)

                    render.SetScissorRect(iX, iY, (iX + (iW * self.lerp_hover)), iY + iH, true)
                        TLib2.DrawFAIcon("f111", "TLib2.FA.2", (iW * 0.5), (iH * 0.5),  TLib2.Colors.Base2, 1, 1)
                        TLib2.DrawFAIcon(tButton.icon, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Accent, 1, 1)
                    render.SetScissorRect(0, 0, 0, 0, false)
                end
            end

            if (type(tButton.do_click) ~= "function") then continue end

            local tData = self.sorted_data[iRow]
            function dButton:DoClick()
                tButton.do_click(tData, dRow, self)
            end
        end
    end

    dRow.separator = self.scroll:Add("DPanel")
    dRow.separator:Dock(TOP)
    dRow.separator:SetTall(0)
    dRow.separator:SetBackgroundColor(TLib2.Colors.Base1)

    if self.OnRowAdded then
        self:OnRowAdded(dRow, iRow, xData)
    end

    return dRow
end

---`🔸 Client`<br>
---Returns the text displayed when the table is empty
---@return string @The text displayed when the table is empty
function PANEL:GetEmptyText()
    return self.empty_text
end

---`🔸 Client`<br>
---Sets the text displayed when the table is empty
---@param sText string @The text to display when the table is empty
function PANEL:SetEmptyText(sText)
    if (type(sText) ~= "string") then return end
    self.empty_text = sText
end

function PANEL:PerformLayout(iW, iH)
    local iScrollBarW = 0
    if (self.scroll:GetVBar().CanvasSize > iH) then
        iScrollBarW = self.scroll:GetVBar():GetWide()
    end

    local tColumns = self.columns_container:GetChildren()
    local fAnchorw = (ScrH() * fDragAnchorW)

    local fButtonsW = 0
    if self.row_buttons then
        for i = 1, #self.row_buttons do
            local tButton = self.row_buttons[i]
            if tButton.vgui and tButton.vgui:IsValid() then
                fButtonsW = fButtonsW + tButton.vgui:GetWide()
            end
        end
    end

    for i = 1, #tColumns do
        local dChild = tColumns[i]
        if dChild.is_empty_anchor then continue end
        dChild:SetWide(math.Round((iW - iScrollBarW - fAnchorw - fButtonsW) / (#tColumns - 1)))
    end

    if (#self.rows == 0) then
        if not self.scroll:GetBackgroundInfo() then
            self.scroll:SetBackgroundInfo(self:GetEmptyText(), "f07c")
        end
    else
        if self.scroll:GetBackgroundInfo() then
            self.scroll:SetBackgroundInfo()
        end
    end
end

function PANEL:Paint(iW, iH)
end

vgui.Register("TLib2:DataTable", PANEL, "DPanel")