local PANEL = {}

function PANEL:Init()
    self:SetFont("TLib2.5")
    self:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
    self:SetTall(ScrH() * 0.03)

    self:SetAutoStretchVertical(true)
    self:SetWrap(true)
end

vgui.Register("ZoneCreator:Title", PANEL, "DLabel")