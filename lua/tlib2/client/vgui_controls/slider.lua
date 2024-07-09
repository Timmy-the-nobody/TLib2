local PANEL = {}

local draw = draw

function PANEL:Init()
    self:SetTrapInside(true)
    self:SetTall(math.max(ScrH() * 0.016, TLib2.BorderRadius))

    self.Knob:SetSize(self:GetTall(), self:GetTall())

    function self.Knob:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Accent)
    end
end

function PANEL:Paint(iW, iH)
    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
    draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base1)
end


vgui.Register("TLib2:Slider", PANEL, "DSlider")