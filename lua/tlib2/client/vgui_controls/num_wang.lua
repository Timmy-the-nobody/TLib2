local PANEL = {}

function PANEL:Init()
    self:SetTall(TLib2.VGUIControlH2)
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetDrawLanguageID(false)
    self:SetPaintBackground(false)
    self:SetUpdateOnType(true)
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursorColor(TLib2.Colors.Base3)
    self:SetHighlightColor(TLib2.Colors.Base2)

    self.Up.Paint = function(dPanel, iW, iH)
        -- draw.SimpleText("▲", "TLib2.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
        TLib2.DrawFAIcon("f0d8", "TLib2.FA.8", (iW * 0.5), (iH * 0.5), dPanel:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
    end

    self.Down.Paint = function(dPanel, iW, iH)
        -- draw.SimpleText("▼", "TLib2.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
        TLib2.DrawFAIcon("f0d7", "TLib2.FA.8", (iW * 0.5), (iH * 0.5), dPanel:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
    end

    self.outline_color = TLib2.Colors.Base2
    self.outline_color_editing = TLib2.Colors.Accent
end

function PANEL:PerformLayout(iW, iH)
	self.Up:SetSize(iH, (iH * 0.5))
	self.Up:AlignRight(1)
	self.Up:AlignTop(1)

	self.Down:SetSize(iH, (iH * 0.5))
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