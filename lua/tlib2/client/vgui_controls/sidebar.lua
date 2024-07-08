local PANEL = {}

local tGradColor = TLib2.ColorManip(TLib2.Colors.Accent, 0.3, 0.25)
local matGradL = Material("vgui/gradient-l")

local draw = draw
local surface = surface

function PANEL:Init()
    local iScrH = ScrH()
    local dSideBar = self

    self.expanded_width = (iScrH * 0.24)
    self.button_height = (iScrH * 0.042)

    self:Dock(LEFT)
    self:SetWide(self.expanded_width)
    self.expanded = true
    self.buttons = {}
    self.selected = false

    self.expand_btn = dSideBar:Add("DButton")
    self.expand_btn:Dock(TOP)
    self.expand_btn:SetTall(self.button_height)
    self.expand_btn:SetText("")
    self.expand_btn:SetCursor("hand")
    function self.expand_btn:DoClick()
        dSideBar:ToggleExpand()
    end

    local sMaximizeFA = TLib2.GetFAIcon("f054")
    local sMinimizeFA = TLib2.GetFAIcon("f053")
    function self.expand_btn:Paint(iW, iH)
        draw.SimpleText(
            dSideBar.expanded and sMinimizeFA or sMaximizeFA,
            "TLib2.FA.6",
            iW - (dSideBar.button_height * 0.5),
            (iH * 0.5),
            self:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3,
            1,
            1
        )

        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end
end

function PANEL:AddButton(sLabel, sFAIcon, xData, fnOnClick)
    local iScrH = ScrH()
    local dSideBar = self
    local iID = (#self.buttons + 1)

    sLabel = sLabel or ""
    sFAIcon = sFAIcon or TLib2.GetFAIcon("f00d")

    self.buttons[iID] = {
        id = iID,
        label = sLabel,
        fa_icon = sFAIcon,
        data = xData,
        on_click = fnOnClick
    }

    local dButton = self:Add("DButton")
    dButton:Dock(TOP)
    dButton:SetTall(self.button_height)
    dButton:SetText("")
    dButton:SetCursor("hand")
    dButton.lerp = 0
    dButton.text_color = TLib2.Colors.Accent
    dButton.offset_x = 0

    function dButton:Paint(iW, iH)
        local tTextCol = self:GetTextColor()
        local bExpanded = dSideBar:IsExpanded()

        if bExpanded and (self.lerp > 0.001) then
            surface.SetDrawColor(tGradColor)
            surface.SetMaterial(matGradL)
            surface.DrawTexturedRect(0, 0, iW * self.lerp, iH)
        end

        if dSideBar.selected and (dSideBar.selected == iID) then
            self.lerp = Lerp(RealFrameTime() * 16, self.lerp, 1)

            if bExpanded then
                self.text_color = TLib2.Colors.Accent
                self.offset_x = (iScrH * 0.005)

                surface.SetDrawColor(TLib2.Colors.Accent)
                surface.DrawRect(0, 0, self.offset_x, iH)
            else
                self.text_color = TLib2.Colors.Base4
                self.offset_x = 0

                surface.SetDrawColor(TLib2.Colors.Accent)
                surface.DrawRect(0, 0, iH, iH)
            end
        else
            self.lerp = bExpanded and Lerp(RealFrameTime() * 16, self.lerp, 0) or 0
            self.text_color = self:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3
            self.offset_x = 0
        end

        local fIconW = dSideBar.button_height
        local fY = (iH * 0.5)

        if bExpanded then
            draw.SimpleText(sFAIcon, "TLib2.FA.5", (fIconW * 0.5) + 1 + self.offset_x, fY + 1, TLib2.Colors.Base1, 1, 1)
        end

        draw.SimpleText(sFAIcon, "TLib2.FA.5", (fIconW * 0.5) + self.offset_x, fY, self.text_color, 1, 1)

        if bExpanded then
            draw.SimpleText(sLabel, "TLib2.6", fIconW + 1 + self.offset_x, fY + 1, TLib2.Colors.Base1, 0, 1)
            draw.SimpleText(sLabel, "TLib2.6", fIconW + self.offset_x, fY, self.text_color, 0, 1)
        end
    end

    function dButton:DoClick()
        if fnOnClick then
            local bReturn = fnOnClick(self, dSideBar.buttons[iID])
            if (bReturn == false) then return end
        end

        dSideBar:SetSelected(iID)
    end

    if not self:GetSelected() then
        self:SetSelected(iID)
    end
end

function PANEL:GetSelected()
    return self.selected
end

function PANEL:SetSelected(iButton)
    if not self.buttons[iButton] then return end
    self.selected = iButton
end    

function PANEL:Paint(iW, iH)
    surface.SetDrawColor(TLib2.Colors.Base1)
    surface.DrawRect(0, 0, iW, iH)

    surface.SetDrawColor(TLib2.Colors.Base2)
    surface.DrawLine(iW - 1, 0, iW - 1, iH)
end

function PANEL:IsExpanded()
    return self.expanded
end

function PANEL:SetExpanded(bExpanded)
    bExpanded = tobool(bExpanded)

    self.expanded = bExpanded
    self:SizeTo(bExpanded and self.expanded_width or self.button_height, self:GetTall(), 0.25, 0, 0.5)
end

function PANEL:ToggleExpand()
    self:SetExpanded(not self:IsExpanded())
end

vgui.Register("Tlib2:Sidebar", PANEL, "DPanel")