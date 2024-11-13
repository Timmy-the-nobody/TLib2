local surface = surface
local draw = draw
local math = math

local DisableClipping = DisableClipping
local RealFrameTime = RealFrameTime

---@class TLib2:BarChart : DPanel
local PANEL = {}

function PANEL:Init()
    self.data = {}

    self:SetXAxis({
        min = 0,
        max = 100,
        steps = 10,
        format_step = function(iPerc, iStep)
            return math.Round(iPerc, 1)
        end
    })

    self:SetYAxis({
        visible = true,
        labels_enabled = true,
        format_value = function(xKey, xValue)
            return xValue
        end
    })

    self.bottom = self:Add("DPanel")
    self.bottom:Dock(BOTTOM)
    self.bottom:SetTall(TLib2.VGUIControlH2)
    self.bottom.Paint = function(_, iW, iH)
        if not self.right or not self.right:IsValid() then return end

        local iRightW = self.right:GetWide()
        surface.SetDrawColor(TLib2.Colors.Base3)

        for i = 0, self.x_axis.steps do
            local iX = self.left:GetWide() + (self.right:GetWide() * (i / (self.x_axis.steps))) - 1

            local bOldClipping = DisableClipping(true)
            draw.SimpleText(self.x_axis.format_step(((self.x_axis.max / self.x_axis.steps) * i), i), "TLib2.7", iX, iH, TLib2.Colors.Base3, 1, 4)
            DisableClipping(bOldClipping)
        end
    end

    self.left = self:Add("DPanel")
    self.left:Dock(LEFT)
    self.left:SetWide(ScrH() * 0.25)
    self.left.Paint = nil

    self.right = self:Add("DPanel")
    self.right:Dock(FILL)
    self.right:DockMargin(0, 0, TLib2.Padding2, 0)
    self.right.Paint = function(_, iW, iH)    
        surface.SetDrawColor(TLib2.Colors.Base3)

        for i = 0, self.x_axis.steps do
            local iX = math.floor(iW * (i / (self.x_axis.steps))) - ((i == 0) and 0 or 1)
            surface.DrawLine(iX, 0, iX, iH)
        end
    end
end

---`🔸 Client`<br>
---Sets the X axis settings<br>
---Supported settings: `min` (number), `max` (number), `steps` (number), `format_step` (function)
---@param tAxis table @Table of axis settings
function PANEL:SetXAxis(tAxis)
    self.x_axis = self.x_axis or {}
    for k, v in pairs(tAxis) do
        self.x_axis[k] = v
    end
end

---`🔸 Client`<br>
---Sets the Y axis settings<br>
---Supported settings: `visible` (boolean), `labels_enabled` (boolean), `format_value` (function)
---@param tAxis table @Table of axis settings
function PANEL:SetYAxis(tAxis)
    self.y_axis = self.y_axis or {}
    for k, v in pairs(tAxis) do
        self.y_axis[k] = v
    end
end

---`🔸 Client`<br>
---Adds data to the chart
---@param sLabel string @Label of the data
---@param fValue number @Value of the data
---@return number @Index of the data
function PANEL:AddData(sLabel, fValue)
    local iKey = (#self.data + 1)
    local iValueW, iValueH = 0, 0
    local fApproachW = 0
    local oHoverCol = TLib2.ColorManip(TLib2.Colors.Accent, 0.8, 0.8)
    local oHorizontalLineCol = ColorAlpha(TLib2.Colors.Base2, 100)

    self.data[iKey] = {
        label = (type(sLabel) == "string") and sLabel or "",
        value = (type(fValue) == "number") and fValue or 0,
        line_panel = self.right:Add("DPanel")
    }

    local dLine = self.data[iKey].line_panel
    dLine:Dock(TOP)
    dLine:SetTall(TLib2.VGUIControlH2)

    dLine.Paint = function(_, iW, iH)
        local bHovered = dLine:IsHovered()
        local fBarW = iW * (fValue / self.x_axis.max)
        local fBarH = (iH * 0.5)

        fApproachW = math.min(math.Approach(fApproachW, fBarW - 2, RealFrameTime() * 512), (fBarW - 2))

        surface.SetDrawColor(oHorizontalLineCol)
        surface.DrawLine(0, (iH * 0.5), iW, (iH * 0.5))

        surface.SetDrawColor(bHovered and oHoverCol or TLib2.Colors.Accent)
        surface.DrawRect(1, (iH - fBarH) * 0.5, fApproachW, fBarH)

        local bOldClipping = DisableClipping(true)
            draw.RoundedBox(TLib2.BorderRadius, fApproachW - (iValueW * 0.5), (iH - iValueH) * 0.5, iValueW, iValueH, TLib2.Colors.Base2)
            draw.RoundedBox(TLib2.BorderRadius - 2, fApproachW - (iValueW * 0.5) + 1, (iH - iValueH) * 0.5 + 1, iValueW - 2, iValueH - 2, TLib2.Colors.Base1)

            iValueW, iValueH = draw.SimpleText(self.y_axis.format_value(iKey, fValue), "TLib2.7", fApproachW, (iH * 0.5), TLib2.Colors.Base4, 1, 1)
            iValueW = (iValueW + TLib2.Padding3)

            draw.SimpleText(sLabel, "TLib2.7", -TLib2.Padding2, (iH * 0.5), bHovered and TLib2.Colors.Base4 or TLib2.Colors.Base3, 2, 1)
        DisableClipping(bOldClipping)
    end

    return iKey
end

---`🔸 Client`<br>
---Removes data from the chart by index
---@param iKey number @Index of the data
function PANEL:RemoveData(iKey)
    local tNewData = {}
    for i = 1, #self.data do
        if (i ~= iKey) then
            tNewData[#tNewData + 1] = self.data[i]
        else
            if self.data[i].line_panel and self.data[i].line_panel:IsValid() then
                self.data[i].line_panel:Remove()
                self:InvalidateLayout()
            end
        end
    end
    self.data = tNewData
end

function PANEL:PerformLayout(iW, iH)
    local iTall = 0
    for i = 1, #self.data do
        local dLine = self.data[i].line_panel
        if dLine and dLine:IsValid() then
            local _, iMT, _, iMB = dLine:GetDockMargin()
            iTall = iTall + dLine:GetTall() + iMT + iMB
        end
    end
    
    if self.y_axis.labels_enabled then
        if self.bottom and self.bottom:IsValid() then
            self.bottom:InvalidateLayout()
            iTall = iTall + self.bottom:GetTall()
        end
    end

    if (iH ~= iTall) then
        self:SetTall(iTall)
    end
end

function PANEL:Paint(iW, iH)
end

vgui.Register("TLib2:BarChart", PANEL, "DPanel")