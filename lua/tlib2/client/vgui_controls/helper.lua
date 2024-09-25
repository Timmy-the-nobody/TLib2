local render = render
local surface = surface
local draw = draw
local math = math

local PANEL = {}

function PANEL:Init()
    self:SetSize(TLib2.VGUIControlH2, TLib2.VGUIControlH2)
    self:SetMouseInputEnabled(true)

    self.helper_text = ""
    self.fa_icon = "f05a"

    self.hover_approach = 0
end

function PANEL:GetHelperText()
    return self.helper_text
end

function PANEL:SetHelperText(sText)
    if (type(sText) ~= "string") then return end
    self.helper_text = sText
end

function PANEL:GetFAIcon()
    return self.fa_icon
end

function PANEL:SetFAIcon(sFAIcon)
    if (type(sFAIcon) ~= "string") then return end
    self.fa_icon = sFAIcon
end

function PANEL:Paint(iW, iH)
    if self:IsHovered() then
        self.hover_approach = math.Approach(self.hover_approach, 1, RealFrameTime() * 4)

        local iX, iY = self:LocalToScreen(0, 0)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iH, iH, TLib2.Colors.Accent)
        TLib2.DrawFAIcon(self.fa_icon, "TLib2.FA.5", (iH * 0.5), (iH * 0.5), TLib2.Colors.Base2, 1, 1)

        render.SetScissorRect(iX, iY, iX + (iW * self.hover_approach), iY + iH, true)
            TLib2.DrawFAIcon(self.fa_icon, "TLib2.FA.5", (iH * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
        render.SetScissorRect(0, 0, 0, 0, false)
    else
        self.hover_approach = 0

        TLib2.DrawFAIcon(self.fa_icon, "TLib2.FA.5", (iH * 0.5), (iH * 0.5), TLib2.Colors.Base2, 1, 1)
    end
end

function PANEL:OnCursorEntered()
    if self.tooltip and self.tooltip:IsValid() then return end

    self.tooltip = vgui.Create("TLib2:Tooltip")
    self.tooltip:SetAnchor(self)
    self.tooltip:SetText(self:GetHelperText())
end

function PANEL:OnCursorExited()
    if not self.tooltip or not self.tooltip:IsValid() then return end

    self.tooltip:Remove()
    self.tooltip = nil
end

function PANEL:OnRemove()
    if self.tooltip and self.tooltip:IsValid() then
        self.tooltip:Remove()
        self.tooltip = nil
    end
end

function PANEL:PerformLayout(iW, iH)
    if (iW == iH) then return end
    self:SetWide(iH)
end

vgui.Register("TLib2:Helper", PANEL, "DPanel")