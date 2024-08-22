local PANEL = {}

local draw = draw
local surface = surface

function PANEL:Init()
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursor("hand")
    self:SetTall(ScrH() * 0.03)

    self.bg_color = TLib2.Colors.Base1
    self.outline_color = TLib2.Colors.Base2

    self.bg_color_hover = TLib2.Colors.Base2
    self.outline_color_hover = TLib2.Colors.Base3
end

function PANEL:SetBackgroundColor(tCol)
    if not IsColor(oColor) then return end

    self.bg_color = tCol
end

function PANEL:SetBackgroundHoverColor(tCol)
    if not IsColor(oColor) then return end

    self.bg_color_hover = tCol
end

function PANEL:SetOutlineColor(oColor)
    if not IsColor(oColor) then return end

    self.outline_color = oColor
end

function PANEL:SetOutlineHoverColor(oColor)
    if not IsColor(oColor) then return end

    self.outline_color_hover = oColor
end

function PANEL:SetColorTheme(tCol)
    if not IsColor(tCol) then return end

    self:SetColor(tCol)
    self:SetOutlineColor(tCol)
    self:SetBackgroundColor(TLib2.ColorManip(tCol, 0.5, 0.2))

    self:SetOutlineHoverColor(TLib2.ColorManip(tCol, 0.5, 0.5))
    self:SetBackgroundHoverColor(TLib2.ColorManip(tCol, 0.5, 0.5))
end

function PANEL:SetFAIcon(sIcon, sFont, bAdjustWidth, bAlignRight)
    self.fa_icon = TLib2.GetFAIcon(sIcon)
    self.fa_icon_font = sFont or "TLib2.FA.7"
    self.fa_align_right = tobool(bAlignRight)

    if not bAdjustWidth then return end

    surface.SetFont(self.fa_icon_font)
    local iFAIconW, iFAIconH = surface.GetTextSize(self.fa_icon)
    local iTextW, iTextH = self:GetTextSize()

    self:SetWide(iTextW + iFAIconW + (TLib2.Padding3 * 2.5))

    self:SetContentAlignment(4)
    if self.fa_align_right then
        self:SetTextInset(TLib2.Padding3, 0)
    else
        self:SetTextInset(iFAIconW + (TLib2.Padding3 * 1.5), 0)
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
    if self.outline_color then
        if self.outline_color_hover then
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self:IsHovered() and self.outline_color_hover or self.outline_color)
        else
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self.outline_color)
        end
        iRad, iBoxX, iBoxY, iBoxW, iBoxH = TLib2.BorderRadius - 2, 1, 1, (iW - 2), (iH - 2)
    else
        iRad, iBoxX, iBoxY, iBoxW, iBoxH = TLib2.BorderRadius, 0, 0, iW, iH
    end
    draw.RoundedBox(iRad, iBoxX, iBoxY, iBoxW, iBoxH, self:IsHovered() and self.bg_color_hover or self.bg_color)

    if self.fa_icon then
        if (self.fa_align_right) then
            draw.SimpleText(self.fa_icon, self.fa_icon_font, (iW - (iH * 0.25)), (iH * 0.5), self:GetTextColor(), TEXT_ALIGN_RIGHT, 1)
        else
            draw.SimpleText(self.fa_icon, self.fa_icon_font, (iH * 0.25), (iH * 0.5), self:GetTextColor(), 0, 1)
        end
    end
end

vgui.Register("TLib2:Button", PANEL, "DButton")