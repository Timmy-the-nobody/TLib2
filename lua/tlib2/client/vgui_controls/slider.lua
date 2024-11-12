local draw = draw

---@class TLib2:Slider : DSlider
local PANEL = {}

function PANEL:Init()
    local dSlider = self

    self:SetTrapInside(true)
    self:SetTall(math.ceil(TLib2.VGUIControlH2 * 0.5))

    self.Knob:SetSize(self:GetTall(), self:GetTall())

    function self.Knob:Paint(iW, iH)
        local bOldClipping = DisableClipping(true)
        TLib2.DrawFAIcon("f192", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Accent, 1, 1)
        DisableClipping(bOldClipping)
    end
end

function PANEL:Paint(iW, iH)
    local fBarH = (iH * 0.5)

    draw.RoundedBox(TLib2.BorderRadius, 0, ((iH - fBarH) * 0.5) + 0, iW, fBarH, TLib2.Colors.Base2)
    draw.RoundedBox(TLib2.BorderRadius - 2, 1, ((iH - fBarH) * 0.5) + 1, iW - 2, fBarH - 2, TLib2.Colors.Base1)
end

vgui.Register("TLib2:Slider", PANEL, "DSlider")