local PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:SetTall(1)
    self:SetBackgroundColor(ZoneCreator.Cfg.Colors.Base1)
    self:DockMargin(0, ZoneCreator.Padding1, 0, ZoneCreator.Padding1)
end

vgui.Register("ZoneCreator:Separator", PANEL, "DPanel")