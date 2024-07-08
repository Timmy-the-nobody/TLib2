local PANEL = {}

function PANEL:Init()
    self:SetFont("TLib2.7")
    self:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    self:SetTall(ScrH() * 0.03)

    self:SetAutoStretchVertical(true)
    self:SetWrap(true)
end

-- function PANEL:PerformLayout(iW, iH)
--     self:SetText(self:GetText():upper())
-- end

vgui.Register("ZoneCreator:Subtitle", PANEL, "DLabel")