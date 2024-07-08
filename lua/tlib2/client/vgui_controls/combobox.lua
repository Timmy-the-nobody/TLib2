local PANEL = {}

local draw = draw

function PANEL:Init()
    self.options = {}
    self.selected = nil
    self.title = ""
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
    local sCloseFA = TLib2.GetFAIcon("f00d")
    function dMenuClose:Paint(iW, iH)
        draw.SimpleText(sCloseFA, "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors[self:IsHovered() and "Warn" or "Base3"], 1, 1)
    end
    function dMenuClose:DoClick()
        dPanel:CloseMenu()
    end

    local sFASelected = TLib2.GetFAIcon("f00c")
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
            if (dPanel.selected == i) then
                draw.SimpleText(sFASelected, "TLib2.FA.7", TLib2.Padding3, (iH * 0.5), TLib2.Colors.Base3, 0, 1)
            end
        end

        function dOption:DoClick()
            dPanel:ChooseOption(i)
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

function PANEL:GetSelected()
    local iIndex = self.selected
    return iIndex, self.options[iIndex].label, self.options[iIndex].data
end

function PANEL:ChooseOption(iIndex)
    if not self.options[iIndex] then return end

    self.selected = iIndex
    self:OnSelect(iIndex, self.options[iIndex].label, self.options[iIndex].data)

    self:CloseMenu()
end

function PANEL:AddOption(sLabel, xData, bSelect)
    local iInd = (#self.options + 1)

    self.options[iInd] = {
        label = sLabel,
        data = xData
    }

    if bSelect then
        self:ChooseOption(iInd)
    end

    return iInd
end

function PANEL:RemoveOption(iIndex)
    if not self.options[iIndex] then return end

    table.remove(self.options, iIndex)
end

function PANEL:PerformLayout(iW, iH)
    if not self.menu or not self.menu:IsValid() then return end

    local iMinW = math.max(self.menu.title:GetWide() + (TLib2.Padding3 * 2), 50)
    local tChildren = self.menu.scroll:GetCanvas():GetChildren()
    local iChildrenH = self.menu.title:GetTall() + (TLib2.Padding4 * 2) + 2

    for i = 1, #tChildren do
        local dChild = tChildren[i]

        surface.SetFont(dChild:GetFont())
        local iTextW, iTextH = surface.GetTextSize(dChild:GetText())
        local iInsetX = dChild:GetTextInset()

        dChild:InvalidateLayout(true)
        iMinW = math.max(iMinW, iTextW + iInsetX + iTextH + TLib2.Padding2)
        iChildrenH = iChildrenH + dChild:GetTall()
    end

    local _, iMenuY = self:LocalToScreen(0, 0)
    self.menu:SetTall(math.min(iChildrenH, ScrH() - iMenuY - (TLib2.Padding4 * 2) - TLib2.Padding2))
    self.menu:SetWide(iMinW)

    local iVPLeft, iVPTop = self:LocalToScreen(0, 0)
    self.menu:SetPos(iVPLeft - (self.menu:GetWide() - self:GetWide()), iVPTop + self:GetTall() + TLib2.Padding4)
end

vgui.Register("TLib2:ComboBox", PANEL, "TLib2:Button")