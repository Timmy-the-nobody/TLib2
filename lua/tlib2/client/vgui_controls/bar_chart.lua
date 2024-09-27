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

function PANEL:SetXAxis(tAxis)
    self.x_axis = self.x_axis or {}
    for k, v in pairs(tAxis) do
        self.x_axis[k] = v
    end
end

function PANEL:SetYAxis(tAxis)
    self.y_axis = self.y_axis or {}
    for k, v in pairs(tAxis) do
        self.y_axis[k] = v
    end
end

function PANEL:AddData(sLabel, fValue)
    local iKey = (#self.data + 1)
    self.data[iKey] = {
        label = sLabel,
        value = fValue,
        line_panel = self.right:Add("DPanel")
    }

    local dDataLine = self.data[iKey].line_panel
    dDataLine:Dock(TOP)
    dDataLine:SetTall(TLib2.VGUIControlH2)
    dDataLine.Paint = nil

    local dProgress = dDataLine:Add("DPanel")
    dProgress:Dock(LEFT)
    dProgress:DockPadding(0, TLib2.Padding4, 0, TLib2.Padding4)
    dProgress.approach_w = 0
    dProgress.bar_h = 0.5

    dProgress.PerformLayout = function(_, iW, iH)
        local iProgressW = self.right:GetWide() * (fValue / self.x_axis.max)
        if (iW ~= iProgressW) then
            dProgress:SetWide(math.max(iProgressW, 3))
        end
    end

    dDataLine.PerformLayout = function(_, iW, iH)
        dProgress:InvalidateLayout()
    end

    dProgress.Paint = function(_, iW, iH)
        local bHovered = dProgress:IsHovered()
        local fBarH = (dProgress.bar_h * iH)

        dProgress.approach_w = math.Approach(dProgress.approach_w, iW - 2, RealFrameTime() * 256)
        dProgress.approach_w = math.min(dProgress.approach_w, iW)

        surface.SetDrawColor(bHovered and TLib2.Colors.Action or TLib2.Colors.Accent)
        surface.DrawRect(1, (iH - fBarH) * 0.5, dProgress.approach_w, fBarH)

        draw.SimpleText(self.y_axis.format_value(iKey, fValue), "TLib2.6", dProgress.approach_w - TLib2.Padding4, (iH * 0.5), TLib2.Colors.Base4, 2, 1)

        local bOldClipping = DisableClipping(true)
            draw.SimpleText(sLabel, "TLib2.7", -TLib2.Padding2, (iH * 0.5), bHovered and TLib2.Colors.Base4 or TLib2.Colors.Base3, 2, 1)
        DisableClipping(bOldClipping)
    end

    self:InvalidateLayout()

    return iKey
end

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

function PANEL:Paint(iW, iH)
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

vgui.Register("TLib2:BarChart", PANEL, "DPanel")