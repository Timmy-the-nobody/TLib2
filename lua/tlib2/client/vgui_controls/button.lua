local PANEL = {}

local draw = draw
local surface = surface

function PANEL:Init()
    self:SetTall(TLib2.VGUIControlH2)
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursor("hand")

    self.bg_color = TLib2.Colors.Base1
    self.bg_color_hover = TLib2.Colors.Base2

    self.outline_color = TLib2.Colors.Base2
    self.outline_color_hover = TLib2.Colors.Base3
end

function PANEL:SetBackgroundColor(oCol, oColHover)
    self.bg_color = oCol
end

function PANEL:SetOutlineColor(oCol, oColHover)
    self.outline_color = oCol
end

function PANEL:SetBackgroundHoverColor(oCol)
    self.bg_color_hover = oCol
end

function PANEL:SetOutlineHoverColor(oCol)
    self.outline_color_hover = oCol
end

function PANEL:SetColorTheme(oCol)
    if not IsColor(oCol) then return end

    self:SetColor(oCol)
    self:SetBackgroundColor(TLib2.ColorManip(oCol, 0.5, 0.2))
    self:SetOutlineColor(oCol)

    self:SetBackgroundHoverColor(TLib2.ColorManip(oCol, 0.5, 0.5))
    self:SetOutlineHoverColor(TLib2.ColorManip(oCol, 0.5, 0.5))
end

function PANEL:SetFlatColorTheme(oCol)
    if not IsColor(oCol) then return end

    self:SetBackgroundColor(oCol)
    self:SetOutlineColor(oCol)

    self:SetBackgroundHoverColor(TLib2.ColorManip(oCol, 0.9, 0.9))
    self:SetOutlineHoverColor(TLib2.ColorManip(oCol, 0.9, 0.9))
end

---@param sIcon string @The icon to use
---@param sFont string @The font to use
---@param bAdjustWidth boolean @Whether to adjust the width of the button
---@param bAlignRight boolean @Whether to align the button to the right
function PANEL:SetFAIcon(sIcon, sFont, bAdjustWidth, bAlignRight)
    sFont = sFont or "TLib2.FA.7"

    surface.SetFont(sFont)
    local iFAIconW, _ = surface.GetTextSize(TLib2.GetFAIcon(sIcon))
    
    self:InvalidateLayout(true)
    local iMargin = (self:GetTall() * 0.25)

    self:SetContentAlignment(4)
    self:SetTextInset(bAlignRight and iMargin or (iFAIconW + (iMargin * 2)), 0)

    self.fa_icon_pnl = self.fa_icon_pnl or self:Add("Panel")
    self.fa_icon_pnl:Dock(bAlignRight and RIGHT or LEFT)
    self.fa_icon_pnl:DockMargin(iMargin, 0, iMargin, 0)
    self.fa_icon_pnl:SetWide(iFAIconW)
    self.fa_icon_pnl:SetMouseInputEnabled(false)
    self.fa_icon_pnl.Paint = function(_, iW, iH)
        TLib2.DrawFAIcon(sIcon, sFont or "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self:GetTextColor(), 1, 1)
    end

    if bAdjustWidth then
        local iTextW, _ = self:GetTextSize()
        self:SetWide(iTextW + iFAIconW + (iMargin * (iTextW == 0 and 2 or 3)))
    end
end

function PANEL:PerformLayout(iW, iH)
    if self.fa_icon_pnl and self.fa_icon_pnl:IsValid() then
        
    end
end

function PANEL:SetClickable(bClickable)
    if bClickable then
        self:SetEnabled(true)
        self:SetAlpha(255)
    else
        self:SetEnabled(false)
        self:SetAlpha(100)
    end
end

function PANEL:Paint(iW, iH)
    local iRad, iBoxX, iBoxY, iBoxW, iBoxH

    local bHovered = self:IsHovered()
    local bOutlineHover = (self.outline_color_hover and bHovered) and true or false

    if self.outline_color or bOutlineHover then
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, bOutlineHover and self.outline_color_hover or self.outline_color)
        iRad, iBoxX, iBoxY, iBoxW, iBoxH = TLib2.BorderRadius - 2, 1, 1, (iW - 2), (iH - 2)
    else
        iRad, iBoxX, iBoxY, iBoxW, iBoxH = TLib2.BorderRadius, 0, 0, iW, iH
    end

    draw.RoundedBox(iRad, iBoxX, iBoxY, iBoxW, iBoxH, (self.bg_color_hover and bHovered) and self.bg_color_hover or self.bg_color)
end

vgui.Register("TLib2:Button", PANEL, "DButton")