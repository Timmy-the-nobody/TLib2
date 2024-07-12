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

    -- self:SetTall(dNavbar.tabs_container:GetTall())
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
end

function PANEL:Paint(iW, iH)
    local dNavbar = self:GetNavbar()
    if not dNavbar or not dNavbar:IsValid() then return end

    -- Draw the bar
    surface.SetDrawColor(TLib2.Colors.Base2)
    surface.DrawRect(0, (iH - iBarH), iW, iBarH)

    if (dNavbar:GetSelected() == self:GetIndex()) then
        self.lerp_select = Lerp(RealFrameTime() * 16, self.lerp_select, 1)

        surface.SetDrawColor(TLib2.Colors.Accent)
        surface.DrawRect((iW - (self.lerp_select * iW)) * 0.5, (iH - iBarH), self.lerp_select * iW, iBarH)

            -- self:SetTextColor(TLib2.Colors.Base4)
    else
        if (self.lerp_select == 0) then return end

        self.lerp_select = 0
        -- self:SetTextColor(TLib2.Colors.Base3)
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

function PANEL:AddTab(sLabel, dPanel, bSelected)
    local iTab = (#self.tabs + 1)

    dPanel:SetVisible(false)
    dPanel:SetParent(self)

    self.tabs[iTab] = {
        id = iTab,
        label = sLabel,
        panel = dPanel,
        button = self.tabs_container:Add("TLib2:NavbarTab")
    }

    local dButton = self.tabs[iTab].button
    dButton:Dock(LEFT)
    dButton:SetText(sLabel or "")
    dButton:SetIndex(iTab)
    dButton:SetNavbar(self)

    if not self:GetSelected() or bSelected then
        self:SetSelected(iTab)
    end
end

function PANEL:PerformLayout(iW, iH)
    for i = 1, #self.tabs do
        self.tabs[i].button:SetWide(iW / #self.tabs)
    end
end

function PANEL:Paint(iW, iH)
    -- draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base1)
end

vgui.Register("TLib2:Navbar", PANEL, "DPanel")