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

-- Control
----------------------------------------------------------------------

local tAnchorDirs = {
    [TOP] = function(iAnchorX, iAnchorY, iAnchorW, iAnchorH, iTooltipW, iTooltipH)
        return
            iAnchorX + ((iAnchorW - iTooltipW) * 0.5),
            iAnchorY - iTooltipH - (TLib2.Padding4 * 2)
    end,
    [BOTTOM] = function(iAnchorX, iAnchorY, iAnchorW, iAnchorH, iTooltipW, iTooltipH)
        return
            iAnchorX + ((iAnchorW - iTooltipW) * 0.5),
            iAnchorY + iAnchorH + (TLib2.Padding4 * 2)
    end,
    [LEFT] = function(iAnchorX, iAnchorY, iAnchorW, iAnchorH, iTooltipW, iTooltipH)
        return
            iAnchorX - iTooltipW - (TLib2.Padding4 * 2),
            iAnchorY + ((iAnchorH - iTooltipH) * 0.5)
    end,
    [RIGHT] = function(iAnchorX, iAnchorY, iAnchorW, iAnchorH, iTooltipW, iTooltipH)
        return
            iAnchorX + iAnchorW + (TLib2.Padding4 * 2),
            iAnchorY + ((iAnchorH - iTooltipH) * 0.5)
    end
}

---@class TLib2:Tooltip : DPanel
local PANEL = {}

local draw = draw
local surface = surface
local DisableClipping = DisableClipping

function PANEL:Init()
    self:SetMouseInputEnabled(false)
    self:SetDrawOnTop(true)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0.1)
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
    return self.anchor_dir or TOP
end

---`🔸 Client`<br>
---Sets the anchor direction
---@param iDir number @Anchor direction (TOP, BOTTOM, LEFT, RIGHT)
function PANEL:SetAnchorDir(iDir)
    self.anchor_dir = tAnchorDirs[iDir] and iDir or TOP
    self:InvalidateLayout(true)
end

function PANEL:Paint(iW, iH)
    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
    draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base0)

    if self.markup then
        local iMarkupW, iMarkupH = self.markup:Size()

        self.markup:Draw((iW - iMarkupW) * 0.5, (iH - iMarkupH) * 0.5)
    end
end

---`🔸 Client`<br>
---Updates the tooltip markupn, you shouldn't have to call this manually
function PANEL:UpdateMarkup()
    local sFont = self:GetFont()
    local sTextCol = tostring(self:GetTextColor())
    local sText = markup.Escape(self:GetText())

    self.markup = markup.Parse(("<font=%s><colour=%s>%s</colour></font>"):format(sFont, sTextCol, sText), (ScrH() * 0.25))

    local iW, iH = self.markup:Size()
    self:SetSize(iW + TLib2.Padding3, iH + TLib2.Padding4)
end

---`🔸 Client`<br>
---Returns the font of the tooltip
---@return string @Font name
function PANEL:GetFont()
    return self.font or "TLib2.7"
end

---`🔸 Client`<br>
---Sets the font of the tooltip
---@param sFont string @Font name
function PANEL:SetFont(sFont)
    self.font = sFont
    self:UpdateMarkup()
end

---`🔸 Client`<br>
---Returns the text color of the tooltip
---@return Color @Text color
function PANEL:GetTextColor()
    return self.text_col or TLib2.Colors.Base4
end

---`🔸 Client`<br>
---Sets the text color of the tooltip
---@param oCol Color @Text color
function PANEL:SetTextColor(oCol)
    self.text_col = oCol
    self:UpdateMarkup()
end

---`🔸 Client`<br>
---Returns the text of the tooltip
function PANEL:GetText()
    return self.text or ""
end

---`🔸 Client`<br>
---Sets the text of the tooltip
function PANEL:SetText(sText)
    self.text = sText
    self:UpdateMarkup()
end

function PANEL:PerformLayout(iW, iH)
    local dAnchor = self:GetAnchor()
    if not dAnchor or not dAnchor:IsValid() then return end

    local iAnchX, iAnchY = dAnchor:LocalToScreen(0, 0)
    local iAnchW, iAnchH = dAnchor:GetSize()

    local iX, iY = tAnchorDirs[self:GetAnchorDir()](iAnchX, iAnchY, iAnchW, iAnchH, iW, iH)

    iX = math.Clamp(iX, TLib2.Padding4, ScrW() - iW - TLib2.Padding4)
    iY = math.Clamp(iY, TLib2.Padding4, ScrH() - iH - TLib2.Padding4)

    if (self:GetX() ~= iX) or (self:GetY() ~= iY) then
        self:SetPos(iX, iY)
    end
end

vgui.Register("TLib2:Tooltip", PANEL, "DPanel")