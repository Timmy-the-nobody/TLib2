local PANEL = {}

function PANEL:Init()
end

function PANEL:SetContents(tContents)
    self:Clear()

    for _, v in ipairs(tContents) do
        local dLine = self:Add("DLabel")
        dLine:Dock(v.dock or LEFT)
        dLine:SetFont(v.font or "TLib2.7")
        dLine:SetTextColor(v.color or "", TLib2.Colors.Base3)
        dLine:SetText(v.text or "")
        dLine:InvalidateLayout(true)
        dLine:SizeToContents()

        if v.fa_icon then
            dLine:SetWide(dLine:GetTall() * 1.5)
            dLine:DockMargin(0, 0, TLib2.Padding4, 0)
        end

        if v.url then
            dLine:SetMouseInputEnabled(true)
            dLine:SetTextColor(TLib2.Colors.Accent)
            function dLine:OnMousePressed()
                gui.OpenURL(v.url)
            end
        end

        function dLine:Paint(iW, iH)
            if v.url and self:IsHovered() then
                surface.SetDrawColor(TLib2.Colors.Accent)
                surface.DrawLine(0, (iH - 1), iW, (iH - 1))
            end
            if v.underline then
                surface.SetDrawColor(v.underline_color or TLib2.Colors.Base2)
                surface.DrawLine(0, (iH - 1), iW, (iH - 1))
            end
            if v.fa_icon then
                TLib2.DrawFAIcon(v.fa_icon, v.font or "TLib2.FA.7", (iW * 0.5), (iH * 0.5), v.color or TLib2.Colors.Base2, 1, 1)
            end
        end
    end
end

function PANEL:Paint(iW, iH)
end

function PANEL:PerformLayout(iW, iH)
    self:SizeToChildren(false, true)
end

vgui.Register("TLib2:InfoLine", PANEL, "DPanel")