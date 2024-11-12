---@class TLib2:Title : DLabel
local PANEL = {}

function PANEL:Init()
    self:SetFont("TLib2.5")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetTall(ScrH() * 0.03)

    self:SetAutoStretchVertical(true)
    self:SetWrap(true)
end

vgui.Register("TLib2:Title", PANEL, "DLabel")