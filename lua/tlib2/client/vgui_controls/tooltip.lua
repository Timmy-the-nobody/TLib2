local vgui = vgui
local draw = draw
local surface = surface
local DisableClipping = DisableClipping

TLib2.__tooltips = TLib2.__tooltips or {}
local dDrawnTT = false
local dTargetTT = false

---`🔸 Client`<br>
---Sets a tooltip for a panel.
---@param dPanel Panel @Panel to set the tooltip for
---@param sText? string @The tooltip text, anything else will clear the tooltip
function TLib2.SetTooltip(dPanel, sText)
    if not ispanel(dPanel) then return end

    TLib2.__tooltips[dPanel] = (type(sText) == "string") and sText or nil
end

local function clearTooltip()
    if not dTargetTT then return end

    if dDrawnTT and dDrawnTT:IsValid() then
        dDrawnTT:Remove()
    end

    dDrawnTT = false
    dTargetTT = false
end

hook.Add("Think", "TLib2:Tooltip:Think", function()
    local dHovered = vgui.GetHoveredPanel()
    if not dHovered or not dHovered:IsValid() then return end
    if not TLib2.__tooltips[dHovered] or (dTargetTT == dHovered) then return end

    clearTooltip()

    dDrawnTT = vgui.Create("TLib2:Tooltip")
    dDrawnTT:SetText(TLib2.__tooltips[dHovered])
    dDrawnTT:SetAnchor(dHovered)

    function dDrawnTT:Think()
        if not dHovered:IsValid() then
            TLib2.__tooltips[dHovered] = nil
            clearTooltip()
            return
        end

        local dNewHovered = vgui.GetHoveredPanel()
        if not dNewHovered or not dNewHovered:IsValid() or (dNewHovered ~= dHovered) then
            clearTooltip()
        end
    end

    dTargetTT = dHovered
end)

local PANEL = {}

local draw = draw
local surface = surface
local DisableClipping = DisableClipping

function PANEL:Init()
    self:SetAlpha(0)
    self:SetDrawOnTop(true)
    self:SetFont("TLib2.7")
    self:SetContentAlignment(5)
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetWrap(true)
    self:SetAutoStretchVertical(true)
    self:AlphaTo(255, 0.2, 0)

    self.padding = TLib2.Padding3
end

function PANEL:GetAnchor()
    return self.anchor
end

function PANEL:SetAnchor(dPanel)
    self:Hide()
    self.anchor = dPanel

    local fnOldOnRemove = dPanel.OnRemove
    dPanel.OnRemove = function(_)
        self:Remove()

        if (type(fnOldOnRemove) == "function") then
            fnOldOnRemove(dPanel)
        end
    end

    self:InvalidateLayout(true)
    self:Show()
end

function PANEL:Paint(iW, iH)
    local bOldDisableClipping = DisableClipping(true)

    local iBoxW, iBoxH = (iW + self.padding), (iH + self.padding)
    local iBoxX, iBoxY = (iW - iBoxW) * 0.5, (iH - iBoxH) * 0.5

    draw.RoundedBox(TLib2.BorderRadius, iBoxX, iBoxY, iBoxW, iBoxH, TLib2.Colors.Base2)
    draw.RoundedBox(TLib2.BorderRadius - 2, iBoxX + 1, iBoxY + 1, iBoxW - 2, iBoxH - 2, TLib2.Colors.Base0)

    DisableClipping(bOldDisableClipping)
end

function PANEL:PerformLayout(iW, iH)
    surface.SetFont(self:GetFont())
    local iTextW, iTextH = surface.GetTextSize(self:GetText())

    local iMaxW = (ScrH() * 0.2)
    local iNewW = (iTextW > iMaxW) and iMaxW or iTextW

    self:SetWide(iNewW)

    if not self.anchor or not self.anchor:IsValid() then return end

    local iX, iY = self.anchor:LocalToScreen(0, 0)
    iX = iX + (self.anchor:GetWide() * 0.5)

    self:SetPos(iX - (iNewW * 0.5), iY - self:GetTall() - (TLib2.Padding4 * 2))
end

vgui.Register("TLib2:Tooltip", PANEL, "DLabel")