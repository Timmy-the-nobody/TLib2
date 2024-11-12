---@class TLib2:Separator : DPanel
local PANEL = {}

function PANEL:Init()
    self:SetTall(1)
    self:SetBackgroundColor(TLib2.Colors.Base1)
    self:DockMargin(0, TLib2.Padding3, 0, TLib2.Padding3)
end

vgui.Register("TLib2:Separator", PANEL, "DPanel")