local PANEL = {}

local draw = draw
local render = render

function PANEL:Init()
    self.rtl = false

    self.Button:SetSize(TLib2.VGUIControlH2 * 0.75, TLib2.VGUIControlH2 * 0.75)
    self.Button.DoClick = function() self:Toggle() end
    self.Button.check_approach = 0

    self.Label:SetFont("TLib2.6")
    self.Label:SetTextColor(TLib2.Colors.Base4)
    self.Label:SetCursor("hand")
    -- self.Label:SetTall(self.Button:GetTall())

    function self.Button:Paint(iW, iH)
        local bChecked = self:GetChecked()

        self.check_approach = math.Approach(self.check_approach, bChecked and 1 or 0, RealFrameTime() * 4)

        if (self.check_approach ~= 1) then
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base3)
            draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base1)
        end

        if bChecked then
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Accent)
        end

        if (self.check_approach > 0) then
            local iX, iY = self:LocalToScreen(0, 0)

            render.SetScissorRect(iX, iY, iX + (iW * self.check_approach), (iY + iH), true)
                TLib2.DrawFAIcon("f00c", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    end

    self.__toggle_detour = self.Toggle
    function self:Toggle(...)
        self:__toggle_detour(...)
        TLib2.PlayUISound("buttons/lightswitch2.wav")
    end
end

function PANEL:Paint(iW, iH)
end

function PANEL:SetDescription(sText)
    if not sText then
        if self.Description and self.Description:IsValid() then
            self.Description:Remove()
        end
        return
    end

    if not self.Description then
        self.Description = self:Add("DLabel")
        self.Description:SetFont("TLib2.7")
        self.Description:SetTextColor(TLib2.Colors.Base3)
        self.Description:SetTall(ScrH() * 0.03)
        self.Description:SetContentAlignment(self:IsRTL() and 9 or 7)
        self.Description:SetCursor("hand")
        self.Description:SetMouseInputEnabled(true)
        self.Description:SetWrap(not self:IsRTL())
        self.Description:SetAutoStretchVertical(true)
        self.Description:SetWide(ScrW() * 0.2)
        self.Description.DoClick = function() self:Toggle() end
    end

    self.Description:SetText(sText)
end

function PANEL:PerformLayout(iW, iH)
	self.Button:SetPos(0, 0)

	self.Label:SizeToContentsX()
	self.Label:SetPos(self.Button:GetWide() + TLib2.Padding3, math.floor((self.Button:GetTall() - self.Label:GetTall()) * 0.5))

    local iTall = math.max(self.Button:GetTall(), self.Label:GetTall())

    if self.Description and self.Description:IsValid() and (self.Description:GetText() ~= "") then
        self.Description:SetWide(iW)
        self.Description:SetPos(self.Button:GetWide() + TLib2.Padding3, iTall)
        self.Description:InvalidateLayout(true)

        iTall = (iTall + self.Description:GetTall())
    end

    self:SetTall(iTall)

    if self:IsRTL() then
        self.Button:SetX(iW - self.Button:GetWide())

        self.Label:SetX(iW - self.Button:GetWide() - self.Label:GetWide() - TLib2.Padding3)

        if self.Description and self.Description:IsValid() and (self.Description:GetText() ~= "") then
            self.Description:SetX(iW - self.Button:GetWide() - self.Description:GetWide() - TLib2.Padding3)
        end
    end
end

function PANEL:IsRTL()
    return self.rtl
end

function PANEL:SetRTL(bRTL)
    bRTL = tobool(bRTL)
    if (bRTL == self.rtl) then return end

    self.rtl = bRTL

    if self.Description and self.Description:IsValid() then
        self.Description:SetContentAlignment(9)
        self.Description:SetWrap(not bRTL)
    end
end

vgui.Register("TLib2:Checkbox", PANEL, "DCheckBoxLabel")