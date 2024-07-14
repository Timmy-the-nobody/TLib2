local PANEL = {}

local draw = draw
local surface = surface

function PANEL:Init()
    self.options = {}
    self.multi_select = false
    self.selected_options = {}
    self.title = ""
end

function PANEL:GetMultiple()
    return self.multi_select
end

function PANEL:SetMultiple(bMultiple)
    self.multi_select = tobool(bMultiple)

    if not self.multi_select then
        local iFirstSelected = nil
        for iOption, _ in pairs(self.selected_options) do
            iFirstSelected = iOption
            break
        end
        if iFirstSelected then
            self.selected_options = {[iFirstSelected] = true}
        end
    end
end

function PANEL:CloseMenu()
    if self.menu_container and self.menu_container:IsValid() then
        self.menu_container:Remove()
    end
end

function PANEL:OpenMenu()
    if self.menu and self.menu:IsValid() then return end

    local dPanel = self

    self.menu_container = vgui.Create("DPanel")
    self.menu_container:SetSize(ScrW(), ScrH())
    self.menu_container:MakePopup()
    self.menu_container.Paint = nil
    function self.menu_container:OnMousePressed()
        dPanel:CloseMenu()
    end

    self.menu = self.menu_container:Add("DPanel")
    self.menu:SetDrawOnTop(true)
    self.menu:DockPadding(1, 1, 1, 1)
    self.menu:SetTall(ScrH() * 0.03)
    self.menu:MakePopup()
    function self.menu:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base1)
    end

    self.menu.title = self.menu:Add("TLib2:Button")
    self.menu.title:Dock(TOP)
    self.menu.title:SetFont("TLib2.7")
    self.menu.title:SetTextColor(TLib2.Colors.Base3)
    self.menu.title:SetTextInset(TLib2.Padding3, 0)
    self.menu.title:SetContentAlignment(4)
    self.menu.title:SetText(self.title)
    self.menu.title:SizeToContentsX()
    function self.menu.title:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end

    local dMenuClose = self.menu.title:Add("DButton")
    dMenuClose:Dock(RIGHT)
    dMenuClose:SetText("")
    dMenuClose:SetSize(self.menu.title:GetTall(), self.menu.title:GetTall())
    function dMenuClose:Paint(iW, iH)
        TLib2.DrawFAIcon("f00d", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors[self:IsHovered() and "Warn" or "Base3"], 1, 1)
    end
    function dMenuClose:DoClick()
        dPanel:CloseMenu()
    end

    local iOptionsCount = #self.options

    self.menu.scroll = self.menu:Add("TLib2:Scroll")
    self.menu.scroll:Dock(FILL)
    self.menu.scroll:DockMargin(0, TLib2.Padding4, 0, TLib2.Padding4)
    self.menu.scroll:SetEdgeGradientColor(TLib2.Colors.Base1)
    self.menu.scroll.Paint = nil

    for i = 1, iOptionsCount do
        local dOption = self.menu.scroll:Add("TLib2:Button")
        dOption:SetText(self.options[i].label)
        dOption:SetFont("TLib2.7")
        dOption:Dock(TOP)
        dOption:SetContentAlignment(4)
        dOption:SetTextInset((TLib2.Padding3 * 2) + (ScrH() * 0.015), 0)
        dOption:SetBackgroundColor(color_transparent)
        dOption:SetBackgroundHoverColor(TLib2.Colors.Base2)
        dOption:SetOutlineColor(color_transparent)
        dOption:SetOutlineHoverColor(color_transparent)

        function dOption:PaintOver(iW, iH)
            if not dPanel:IsOptionSelected(i) then return end
            TLib2.DrawFAIcon("f00c", "TLib2.FA.7", TLib2.Padding3, (iH * 0.5), TLib2.Colors.Base3, 0, 1)
        end

        function dOption:DoClick()
            dPanel:__OnClickOption(i)
            dPanel.menu.scroll:ScrollToChild(self)
        end
    end

    self:InvalidateLayout(true)
end

function PANEL:SetTitle(sTitle)
    self.title = sTitle
end

function PANEL:DoClick()
    self:OpenMenu()
end

function PANEL:OnRemove()
    if self.menu_container and self.menu_container:IsValid() then
        self.menu_container:Remove()
    end
end

function PANEL:OnSelect(iIndex, sLabel, xData)
end

function PANEL:OnUnselect(iIndex, sLabel, xData)
end

function PANEL:__OnClickOption(iIndex)
    local tOption = self.options[iIndex]
    if not tOption then return end

    -- Multiple selection
    if self:GetMultiple() then
        self:SetSelectedOption(iIndex, not self:IsOptionSelected(iIndex))
        return
    end

    -- Single selection
    self:SetSelectedOption(iIndex, true)
    self:CloseMenu()
end

function PANEL:SetSelectedOption(iIndex, bSelected, bSilent)
    if not self.options[iIndex] then return end

    if bSelected then
        if self.selected_options[iIndex] then return end

        if not self:GetMultiple() then
            for i, _ in pairs(self.selected_options) do
                self.selected_options[i] = nil
                if not bSilent then
                    self:OnUnselect(i, self.options[i].label, self.options[i].data)
                end
            end
        end

        self.selected_options[iIndex] = true
        if not bSilent then
            self:OnSelect(iIndex, self.options[iIndex].label, self.options[iIndex].data)
        end
    else
        if not self.selected_options[iIndex] then return end

        self.selected_options[iIndex] = nil
        if not bSilent then
            self:OnUnselect(iIndex, self.options[iIndex].label, self.options[iIndex].data)
        end
    end
end

function PANEL:IsOptionSelected(iIndex)
    return (self.selected_options[iIndex] == true)
end

function PANEL:GetSelectedOptions()
    return self.selected_options
end

function PANEL:AddOption(sLabel, xData, bSelected)
    local iInd = (#self.options + 1)

    self.options[iInd] = {
        label = sLabel,
        data = xData
    }

    if bSelected then
        self:SetSelectedOption(iInd, true, true)
    end

    return iInd
end

function PANEL:RemoveOption(iIndex)
    if not self.options[iIndex] then return end

    table.remove(self.options, iIndex)
end

function PANEL:PerformLayout(iW, iH)
    if not self.menu or not self.menu:IsValid() then return end

    local iScrH = ScrH()
    local iNewW = math.max(self.menu.title:GetWide(), iScrH * 0.05)
    local iNewH = self.menu.title:GetTall() + (TLib2.Padding4 * 2) + 2

    local tChildren = self.menu.scroll:GetCanvas():GetChildren()
    for i = 1, #tChildren do
        local dChild = tChildren[i]

        surface.SetFont(dChild:GetFont())
        local iTextW, iTextH = surface.GetTextSize(dChild:GetText())
        local iInsetX = dChild:GetTextInset()

        dChild:InvalidateLayout(true)
        iNewW = math.max(iNewW, iTextW + iInsetX + iTextH + TLib2.Padding2)
        iNewH = iNewH + dChild:GetTall()
    end

    iNewH = math.min(iNewH, (iScrH * 0.24))

    self.menu:SetSize(iNewW, iNewH)

    local iX, iY = self:LocalToScreen(0, 0)

    local iNewX = iX + self:GetWide() - iNewW
    if (iNewX < TLib2.Padding4) then
        iNewX = TLib2.Padding4
    end
    if (iNewX + iNewW) > (ScrW() - TLib2.Padding4) then
        iNewX = (ScrW() - iNewW - TLib2.Padding4)
    end

    local iNewY = (iY + self:GetTall() + TLib2.Padding4)
    if (iNewY < TLib2.Padding4) then
        iNewY = TLib2.Padding4
    end
    if ((iNewY + iNewH) > (iScrH - TLib2.Padding4)) then
        iNewY = (iY - iNewH - TLib2.Padding4)
    end

    self.menu:SetPos(iNewX, iNewY)
end

vgui.Register("TLib2:ComboBox", PANEL, "TLib2:Button")