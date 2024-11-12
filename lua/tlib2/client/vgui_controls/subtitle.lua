---@class TLib2:Subtitle : DLabel
local PANEL = {}

function PANEL:Init()
    self:SetFont("TLib2.7")
    self:SetTextColor(TLib2.Colors.Base3)
    self:SetTall(ScrH() * 0.03)

    self:SetAutoStretchVertical(true)
    self:SetWrap(true)
end

vgui.Register("TLib2:Subtitle", PANEL, "DLabel")