local PANEL = {}

function PANEL:Init()
    self:SetTall(math.max(ScrH() * 0.016, TLib2.BorderRadius))

    if self.TextArea and self.TextArea:IsValid() then self.TextArea:Remove() end
    self.TextArea = self:Add("TLib2:TextEntry")
	self.TextArea:Dock(RIGHT)
    self.TextArea:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.TextArea:SetWide(ScrH() * 0.06)
	self.TextArea:SetNumeric(true)
    self.TextArea:SetButtonVisible(false)
	self.TextArea.OnChange = function(_, _) self:SetValue(self.TextArea:GetText()) end


    if self.Slider and self.Slider:IsValid() then self.Slider:Remove() end
    self.Slider = self:Add("TLib2:Slider")
    self.Slider:Dock(FILL)
	self.Slider.TranslateValues = function(_, iX, iY)
        return self:TranslateSliderValues(iX, iY)
    end

	self.Label:SetFont(self.TextArea:GetFont())
    self.Label:SetTextColor(TLib2.Colors.Base4)

    local sFAScratch = TLib2.GetFAIcon("f05b")
    self.Scratch:DockMargin(0, 0, TLib2.Padding4, 0)

    function self.Scratch:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, (iW - iH), 0, iH, iH, TLib2.Colors.Base1)

        draw.SimpleText(sFAScratch, "TLib2.FA.7", (iW - (iH * 0.5)), (iH * 0.5), self:IsHovered() and TLib2.Colors.Accent or TLib2.Colors.Base3, 1, 1)
    end
end

vgui.Register("TLib2:NumSlider", PANEL, "DNumSlider")