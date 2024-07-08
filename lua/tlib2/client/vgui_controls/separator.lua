local PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
    self:SetTall(1)
    self:SetBackgroundColor(TLib2.Colors.Base1)
    self:DockMargin(0, TLib2.Padding2, 0, TLib2.Padding2)
end

vgui.Register("TLib2:Separator", PANEL, "DPanel")