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
    dDrawnTT:SetAnchorDir(BOTTOM)

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

-- Control
----------------------------------------------------------------------

local tAnchorDirs = {
    [TOP] = function(iAX, iAY, iAW, iAH, iTTW, iTTH)
        return iAX + ((iAW - iTTW) * 0.5), iAY - iTTH - (TLib2.Padding4 * 2)
    end,
    [BOTTOM] = function(iAX, iAY, iAW, iAH, iTTW, iTTH)
        return iAX + ((iAW - iTTW) * 0.5), iAY + iAH + (TLib2.Padding4 * 2)
    end,
    [LEFT] = function(iAX, iAY, iAW, iAH, iTTW, iTTH)
        return iAX - iTTW - (TLib2.Padding4 * 2), iAY + ((iAH - iTTH) * 0.5)
    end,
    [RIGHT] = function(iAX, iAY, iAW, iAH, iTTW, iTTH)
        return iAX + iAW + (TLib2.Padding4 * 2), iAY + ((iAH - iTTH) * 0.5)
    end
}

local PANEL = {}

local draw = draw
local surface = surface
local DisableClipping = DisableClipping

function PANEL:Init()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)

    self:SetDrawOnTop(true)
    self:SetFont("TLib2.7")
    self:SetContentAlignment(5)
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetWrap(true)
    self:SetAutoStretchVertical(true)

    self.padding = TLib2.Padding3
    self.anchor_dir = TOP
end

function PANEL:Think()
    if self.anchor then
        if not self.anchor:IsValid() then
            self:Remove()
        end
    end
end

---`🔸 Client`<br>
---Returns the anchor panel
---@return Panel? @Anchor panel, or `nil` if none
function PANEL:GetAnchor()
    return self.anchor
end

---`🔸 Client`<br>
---Sets the anchor panel
---@param xPanel Panel|nil @Anchor panel, or `nil` to clear 
function PANEL:SetAnchor(xPanel)
    self.anchor = ispanel(xPanel) and xPanel or nil
    self:InvalidateLayout(true)
end

---`🔸 Client`<br>
---Returns the anchor direction
---@return number @Anchor direction (TOP, BOTTOM, LEFT, RIGHT)
function PANEL:GetAnchorDir()
    return self.anchor_dir
end

---`🔸 Client`<br>
---Sets the anchor direction
---@param iDir number @Anchor direction (TOP, BOTTOM, LEFT, RIGHT)
function PANEL:SetAnchorDir(iDir)
    self.anchor_dir = tAnchorDirs[iDir] and iDir or TOP
    self:InvalidateLayout(true)
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

    if (iW ~= iNewW) then
        self:SetWide(iNewW)
    end

    local dAnchor = self:GetAnchor()
    if dAnchor and dAnchor:IsValid() then
        local iAnchX, iAnchY = dAnchor:LocalToScreen(0, 0)
        local iAnchW, iAnchH = dAnchor:GetSize()

        local iX, iY = tAnchorDirs[self:GetAnchorDir()](
            iAnchX,
            iAnchY,
            iAnchW,
            iAnchH,
            iNewW,
            iH
        )

        if (self:GetX() ~= iX) or (self:GetY() ~= iY) then
            self:SetPos(iX, iY)
        end
    end
end

vgui.Register("TLib2:Tooltip", PANEL, "DLabel")