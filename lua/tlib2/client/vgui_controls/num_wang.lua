---@class TLib2:NumWang : DNumberWang
local PANEL = {}

function PANEL:Init()
    self:SetTall(TLib2.VGUIControlH2)
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetDrawLanguageID(false)
    self:SetPaintBackground(false)
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursorColor(TLib2.Colors.Base3)
    self:SetHighlightColor(TLib2.Colors.Base2)

    self.Up.Paint = function(dPanel, iW, iH)
        TLib2.DrawFAIcon("f0d8", "TLib2.FA.8", (iW * 0.5), (iH * 0.5), dPanel:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
    end

    self.Down.Paint = function(dPanel, iW, iH)
        TLib2.DrawFAIcon("f0d7", "TLib2.FA.8", (iW * 0.5), (iH * 0.5), dPanel:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
    end

    self.Up.DoClickInternal = function() TLib2.PlayUISound("tlib2/click.ogg") end
    self.Down.DoClickInternal = function() TLib2.PlayUISound("tlib2/click.ogg") end

    self.outline_color = TLib2.Colors.Base2
    self.outline_color_editing = TLib2.Colors.Accent
end

function PANEL:PerformLayout(iW, iH)
    local iUpW, iUpH = self.Up:GetSize()
    if (iUpW ~= iH) then
        self.Up:SetWide(iH)
    end
    if (iUpH ~= (iH * 0.5)) then
        self.Up:SetTall(iH * 0.5)
    end
	self.Up:AlignRight(1)
	self.Up:AlignTop(1)

    local iDownW, iDownH = self.Down:GetSize()
    if (iDownW ~= iH) then
        self.Down:SetWide(iH)
    end
    if (iDownH ~= (iH * 0.5)) then
        self.Down:SetTall(iH * 0.5)
    end
	self.Down:AlignRight(1)
	self.Down:AlignBottom(1)
end

function PANEL:IsPlaceholderVisible()
    if not self:HasFocus() and (self:GetText() == "") and self.m_txtPlaceholder then
        return true
    end
end

function PANEL:Paint(iW, iH)
    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self:IsEditing() and self.outline_color_editing or self.outline_color)
    draw.RoundedBox((TLib2.BorderRadius - 2), 1, 1, (iW - 2), (iH - 2), TLib2.Colors.Base0)

    if self:IsPlaceholderVisible() then
        draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), TLib2.Padding4, (iH * 0.5), self:GetPlaceholderColor(), 0, 1)
    else
        self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
    end
end

vgui.Register("TLib2:NumWang", PANEL, "DNumberWang")