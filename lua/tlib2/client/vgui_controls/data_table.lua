local PANEL = {}

local surface = surface
local draw = draw

local matGradDown = Material("vgui/gradient-d")
local sFAUp = TLib2.GetFAIcon("f0d8")
local sFADown = TLib2.GetFAIcon("f0d7")
local fDragAnchorW = 0.036

function PANEL:Init()
    local dDataTbl = self

    self.columns = {}
    self.rows = {}
    self.data = {}
    self.sorted_data = {}
    self.row_buttons = {}

    self.columns_container = self:Add("DPanel")
    self.columns_container:SetTall(ScrH() * 0.03)
    self.columns_container:Dock(TOP)
    self.columns_container:DockMargin(0, 0, 0, ZoneCreator.Padding3)
    function self.columns_container:Paint(iW, iH)
        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base2)
        surface.DrawLine(0, 0, iW, 0)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end

    local dFakeAnchor = self.columns_container:Add("DPanel")
    dFakeAnchor:SetPos(0, 0)
    dFakeAnchor:Dock(LEFT)
    dFakeAnchor:SetWide(ScrH() * fDragAnchorW)
    dFakeAnchor.Paint = nil
    dFakeAnchor.is_empty_anchor = true

    self.scroll = self:Add("ZoneCreator:Scroll")
    self.scroll:Dock(FILL)
end

function PANEL:SetColumnsVisible(bVisible)
    if not bVisible then
        self.columns_container:Hide()
    else
        self.columns_container:Show()
    end
end

function PANEL:AddColumn(sLabel, fnSelector, fnFormat, bSortable, fWidth)
    local dDataTbl = self
    local iColumn = (#self.columns + 1)

    sLabel = (type(sLabel) == "string") and sLabel or ("Column "..iColumn)
    fnSelector = (type(fnSelector) == "function") and fnSelector or function() return "N/A" end
    fnFormat = (type(fnFormat) == "function") and fnFormat or nil
    bSortable = tobool(bSortable)
    fWidth = ((type(fWidth) == "number") and (fWidth <= 1) and (fWidth >= 0)) and fWidth or nil

    self.columns[iColumn] = {
        index = iColumn,
        label = sLabel,
        selector = fnSelector,
        format = fnFormat,
        sortable = bSortable,
        width = fWidth,
        sort_asc = false,
    }

    local dColumn = self.columns_container:Add("DButton")
    self.columns[iColumn].panel = dColumn

    dColumn:Dock(LEFT)
    dColumn:SetText(string.upper(sLabel))
    dColumn:SetFont("TLib2.7")
    dColumn:SetContentAlignment(4)
    dColumn:SetTextInset(ZoneCreator.Padding2, 0)
    dColumn:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    dColumn.hover_lerp = 0

    function dColumn:Paint(iW, iH)
        self.hover_lerp = Lerp(FrameTime() * 16, self.hover_lerp, self:IsHovered() and 1 or 0)
        if (self.hover_lerp > 0.001) then
            local fGradH = math.floor(iH * self.hover_lerp)
            surface.SetMaterial(matGradDown)
            surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base1)
            surface.DrawTexturedRect(0, (iH - fGradH) - 1, iW, fGradH)
        end

        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base2)
        if (iColumn == 1) then
            surface.DrawLine(0, 0, 0, iH - 1)
        end
        surface.DrawLine(iW - 1, 0, iW - 1, iH - 1)

        if not bSortable then return end
        
        if dDataTbl.sorted_column and dDataTbl.sorted_column == iColumn then
            draw.SimpleText(dDataTbl.columns[iColumn].sort_asc and sFADown or sFAUp, "TLib2.FA.6", iW - ZoneCreator.Padding2, (iH * 0.5), ZoneCreator.Cfg.Colors.Base3, 2, 1)
        else
            draw.SimpleText(dDataTbl.columns[iColumn].sort_asc and sFADown or sFAUp, "TLib2.FA.6", iW - ZoneCreator.Padding2, (iH * 0.5), ZoneCreator.Cfg.Colors.Base2, 2, 1)
        end
    end

    function dColumn:DoClick()
        dDataTbl.columns[iColumn].sort_asc = not dDataTbl.columns[iColumn].sort_asc
        dDataTbl:Sort(iColumn, dDataTbl.columns[iColumn].sort_asc)
    end
end

function PANEL:SetData(tData)
    if (type(tData) ~= "table") then return end

    self.data = tData

    self.sorted_data = {}
    for xKey, xData in pairs(tData) do
        self.sorted_data[xKey] = xData
    end

    self:UpdateRows()
end

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

local function findParentRowRecursive(dVGUI)
    if not dVGUI or not dVGUI:IsValid() then return end

    if dVGUI.is_data_table_row then
        return dVGUI
    end

    return findParentRowRecursive(dVGUI:GetParent())
end

function PANEL:AddRowButton(sFAIcon, sLabel, fnDoClick)
    self.row_buttons[#self.row_buttons + 1] = {
        icon = sFAIcon or "f013",
        label = sLabel or "",
        do_click = fnDoClick
    }

    self:UpdateRows()
end

function PANEL:AddRow(xData, ...)
    local tColumnContent = {...}

    local dDataTbl = self
    local iRow = (#self.rows + 1)

    local dRow = self.scroll:Add("DPanel")
    dRow:Dock(TOP)
    dRow:SetTall(ScrH() * 0.07)
    dRow.is_data_table_row = true
    dRow.bg_color = (iRow % 2 == 0) and ZoneCreator.ColorManip(ZoneCreator.Cfg.Colors.Base1, 1, 0.7) or ZoneCreator.ColorManip(ZoneCreator.Cfg.Colors.Base1, 1, 0.8)
    dRow.data = xData

    self.rows[iRow] = dRow

    function dRow:IsHovered()
        local dHovered = vgui.GetHoveredPanel()
        if not dHovered then return false end
        if (dHovered == self) then return true end

        return self:IsChildHovered(false)
    end

    function dRow:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self:IsHovered() and ZoneCreator.Cfg.Colors.Base1 or self.bg_color)
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
    dRow.drag_anchor = dRow:Add("ZoneCreator:DataTableDragAnchor")
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
        dContent:SetTextInset(ZoneCreator.Padding2, 0)
        dContent:SetTextColor(ZoneCreator.Cfg.Colors.Base4)

        if self.columns[iColumn] and self.columns[iColumn].format then
            self.columns[iColumn].format(dContent, self.sorted_data[iRow], iRow, iColumn)
        end
    end

    if self.row_buttons then
        local sFACircle = TLib2.GetFAIcon("f111")

        for i = 1, #self.row_buttons do
            local tButton = self.row_buttons[i]
            tButton.vgui = dRow:Add("DButton")

            local dButton = tButton.vgui
            dButton:SetText("")
            dButton:Dock(RIGHT)
            dButton:SetWide(dRow:GetTall())
            dButton:SetFont("TLib2.6")
            dButton:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
            dButton:SetContentAlignment(4)
            dButton:SetTextInset(ZoneCreator.Padding2, 0)
            dButton.fa_icon = TLib2.GetFAIcon(tButton.icon)
            dButton.lerp_hover = 0

            function dButton:Paint(iW, iH)
                self.lerp_hover = Lerp(RealFrameTime() * 8, self.lerp_hover, self:IsHovered() and 1 or 0)

                draw.SimpleText(sFACircle, "TLib2.FA.2", (iW * 0.5), (iH * 0.5), dRow:IsHovered() and ZoneCreator.Cfg.Colors.Base0 or ZoneCreator.Cfg.Colors.Base1, 1, 1)
                draw.SimpleText(self.fa_icon, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Base3, 1, 1)

                if (self.lerp_hover > 0.1) then
                    local iX, iY = self:LocalToScreen(0, 0)

                    render.SetScissorRect(iX, iY, (iX + (iW * self.lerp_hover)), iY + iH, true)
                        draw.SimpleText(sFACircle, "TLib2.FA.2", (iW * 0.5), (iH * 0.5),  ZoneCreator.Cfg.Colors.Base2, 1, 1)
                        draw.SimpleText(self.fa_icon, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Accent, 1, 1)
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
    dRow.separator:SetBackgroundColor(ZoneCreator.Cfg.Colors.Base1)

    if self.OnRowAdded then
        self:OnRowAdded(dRow, iRow, xData)
    end

    return dRow
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
            self.scroll:SetBackgroundInfo(ZoneCreator:I18n("generic.no_data_found"), TLib2.GetFAIcon("f071"))
        end
    else
        if self.scroll:GetBackgroundInfo() then
            self.scroll:SetBackgroundInfo(nil, nil)
        end
    end
end

function PANEL:Paint(iW, iH)
    -- draw.RoundedBox(0, 0, 0, iW, iH, Color(50, 50, 50)) -- Gray background
end

vgui.Register("ZoneCreator:DataTable", PANEL, "DPanel")