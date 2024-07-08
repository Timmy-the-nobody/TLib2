local PANEL = {}

local iBarH = 2 -- The height of the bar at the top of the navbar

function PANEL:Init()
    self.buttons = {}
    self.selected = 1

    self:SetTall((ScrH() * 0.03) + iBarH)
end

function PANEL:GetSelected()
    return self.selected
end

function PANEL:SetSelected(iButton)
    if not self.buttons[iButton] then return end
    self.selected = iButton
end

function PANEL:AddButton(sLabel, fnOnClick)
    local dNavBar = self
    local iID = (#self.buttons + 1)

    self.buttons[iID] = {
        id = iID,
        label = sLabel,
        on_click = fnOnClick
    }

    local dButton = self:Add("DButton")
    self.buttons[iID].vgui = dButton

    dButton:Dock(LEFT)
    dButton:SetTall(self.button_height)
    dButton:SetText(sLabel or "")
    dButton:SetCursor("hand")
    dButton:SetFont("TLib2.6")
    dButton:SetTextColor(TLib2.Colors.Base3)
    dButton:SetTextInset(0, -iBarH)
    dButton.lerp_select = 0

    function dButton:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawRect(0, (iH - iBarH), iW, iBarH)

        if (dNavBar:GetSelected() == iID) then
            self.lerp_select = Lerp(RealFrameTime() * 16, self.lerp_select, 1)

            surface.SetDrawColor(TLib2.Colors.Accent)
            surface.DrawRect((iW - (self.lerp_select * iW)) * 0.5, (iH - iBarH), self.lerp_select * iW, iBarH)

            self:SetTextColor(TLib2.Colors.Base4)
        else
            if (self.lerp_select == 0) then return end

            self.lerp_select = 0
            self:SetTextColor(TLib2.Colors.Base3)
        end
    end

    function dButton:DoClick()
        if fnOnClick then
            local bReturn = fnOnClick(self, dNavBar.buttons[iID])
            if (bReturn == false) then return end
        end

        dNavBar:SetSelected(iID)
    end
end

function PANEL:PerformLayout(iW, iH)
    for i = 1, #self.buttons do
        self.buttons[i].vgui:SetWide(iW / #self.buttons)
    end
end

function PANEL:Paint(iW, iH)
end

vgui.Register("TLib2:Navbar", PANEL, "DPanel")