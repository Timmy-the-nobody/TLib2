local PANEL = {}

local draw = draw
local render = render

local sFACheck = TLib2.GetFAIcon("f00c")

function PANEL:Init()
    local dCheckBox = self

    self.Button:SetSize(ScrH() * 0.016, ScrH() * 0.016)
    self.Button.check_approach = 0

    self.Label:SetFont("TLib2.6")
    self.Label:SetTextColor(TLib2.Colors.Base4)
    self.Label:SetCursor("hand")

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
                draw.SimpleText(sFACheck, "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
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
        self.Description:SetContentAlignment(7)
        self.Description:SetCursor("hand")
        self.Description:SetMouseInputEnabled(true)
        self.Description:SetWrap(true)
        self.Description:SetAutoStretchVertical(true)
        self.Description:SetWide(ScrW() * 0.2)
        self.Description.DoClick = function() self:Toggle() end
    end

    self.Description:SetText(sText)
end

function PANEL:PerformLayout(iW, iH)
	self.Button:SetPos(0, 0)

	self.Label:SizeToContents()
	self.Label:SetPos(self.Button:GetWide() + TLib2.Padding3, math.floor((self.Button:GetTall() - self.Label:GetTall()) * 0.5))

    local iTall = math.max(self.Button:GetTall(), self.Label:GetTall())

    if self.Description and self.Description:IsValid() and (self.Description:GetText() ~= "") then
        self.Description:SetWide(iW)
        self.Description:SetPos(self.Button:GetWide() + TLib2.Padding3, iTall)
        self.Description:InvalidateLayout(true)

        iTall = (iTall + self.Description:GetTall())
    end

    self:SetTall(iTall)
end

vgui.Register("TLib2:Checkbox", PANEL, "DCheckBoxLabel")