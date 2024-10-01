local iBarH = 2 -- The height of the bar at the top of the navbar

----------------------------------------------------------------------
-- Sheet Tab
----------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
    self:SetCursor("hand")
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetTextInset(0, -iBarH)

    self.lerp_select = 0
end

function PANEL:GetNavbar()
    return self.navbar
end

function PANEL:SetNavbar(dNavbar)
    self.navbar = dNavbar
end

function PANEL:GetIndex()
    return self.index or -1
end

function PANEL:SetIndex(iIndex)
    self.index = iIndex
end

function PANEL:DoClick()
    local dNavbar = self:GetNavbar()
    if not dNavbar or not dNavbar:IsValid() then return end

    dNavbar:SetSelected(self:GetIndex())

    TLib2.PlayUISound("tlib2/switch.ogg")
end

function PANEL:Paint(iW, iH)
    local dNavbar = self:GetNavbar()
    if not dNavbar or not dNavbar:IsValid() then return end

    surface.SetDrawColor(TLib2.Colors.Base2)
    surface.DrawRect(0, (iH - iBarH), iW, iBarH)

    if (dNavbar:GetSelected() == self:GetIndex()) then
        self.lerp_select = Lerp(RealFrameTime() * 16, self.lerp_select, 1)

        surface.SetDrawColor(TLib2.Colors.Accent)
        surface.DrawRect((iW - (self.lerp_select * iW)) * 0.5, (iH - iBarH), self.lerp_select * iW, iBarH)
    else
        self.lerp_select = 0
    end
end

vgui.Register("TLib2:NavbarTab", PANEL, "DButton")

----------------------------------------------------------------------
-- Sheet
----------------------------------------------------------------------

local PANEL = {}

function PANEL:Init()
    self.tabs = {}

    self.tabs_container = self:Add("DPanel")
    self.tabs_container:Dock(TOP)
    self.tabs_container:DockMargin(0, 0, 0, TLib2.Padding4)
    self.tabs_container:SetTall((ScrH() * 0.03) + iBarH)
    self.tabs_container.Paint = nil
end

function PANEL:GetSelected()
    return self.selected
end

function PANEL:SetSelected(iTab)
    if not self.tabs[iTab] then return end

    local iOld = self:GetSelected()
    if self.tabs[iOld] then
        local dOldPanel, dOldButton = self.tabs[iOld].panel, self.tabs[iOld].button
        if dOldPanel and dOldPanel:IsValid() then
            dOldPanel:SetVisible(false)
        end
        if dOldButton and dOldButton:IsValid() then
            dOldButton:SetTextColor(TLib2.Colors.Base3)
        end
    end

    local dNewPanel, dNewButton = self.tabs[iTab].panel, self.tabs[iTab].button
    if dNewPanel and dNewPanel:IsValid() then
        dNewPanel:SetVisible(true)
        dNewPanel:Dock(FILL)
    end
    if dNewButton and dNewButton:IsValid() then
        dNewButton:SetTextColor(TLib2.Colors.Base4)
    end

    self.selected = iTab
end

function PANEL:GetTab(iTab)
    return self.tabs[iTab]
end

function PANEL:AddTab(sLabel, dPanel, bSelected)
    if not dPanel or not dPanel:IsValid() then
        dPanel = vgui.Create("DPanel")
    end
    dPanel:SetVisible(false)
    dPanel:SetParent(self)
    
    local iTab = (#self.tabs + 1)
    self.tabs[iTab] = {
        id = iTab,
        label = sLabel,
        panel = dPanel,
        button = self.tabs_container:Add("TLib2:NavbarTab")
    }

    self.tabs[iTab].button:Dock(LEFT)
    self.tabs[iTab].button:SetText(sLabel or "")
    self.tabs[iTab].button:SetIndex(iTab)
    self.tabs[iTab].button:SetNavbar(self)

    if not self:GetSelected() or bSelected then
        self:SetSelected(iTab)
    end

    return self.tabs[iTab], iTab
end

function PANEL:PerformLayout(iW, iH)
    local iButtonW = (iW / #self.tabs)
    for i = 1, #self.tabs do
        if not self.tabs[i].button:IsValid() then continue end
        if (self.tabs[i].button:GetWide() == iButtonW) then continue end

        self.tabs[i].button:SetWide(iButtonW)
    end
end

function PANEL:Paint(iW, iH)
    -- draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base1)
end

vgui.Register("TLib2:Navbar", PANEL, "DPanel")