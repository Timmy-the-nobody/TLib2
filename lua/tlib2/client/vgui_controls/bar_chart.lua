local PANEL = {}

function PANEL:Init()
    self:DockPadding(TLib2.Padding3, TLib2.Padding3, TLib2.Padding3, TLib2.Padding3)
    self:DockMargin(0, 0, TLib2.Padding2, TLib2.Padding3)
    self.data = {}

    self:SetXAxis({
        min = 0,
        max = 100,
        steps = 10,
        format_step = function(iPerc, iStep)
            return math.Round(iPerc)
        end
    })

    self:SetYAxis({
        visible = true,
        labels_enabled = true,
        label_width = 0.25,
        format_value = function(xKey, xValue)
            return xValue
        end
    })
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
    self.data[iKey] = {label = sLabel, value = fValue}

    local dLine = self:Add("DPanel")
    self.data[iKey].line = dLine

    dLine:Dock(TOP)
    dLine:SetTall(TLib2.VGUIControlH2)
    dLine:DockMargin(0, 0, 0, TLib2.Padding4)
    dLine.Paint = nil
    dLine.PerformLayout = function(_, iW, iH)
        if not dLine.label or not dLine.label:IsValid() then return end
        if not dLine.progress or not dLine.progress:IsValid() then return end

        local iCurXLabelW = dLine.label:GetWide()
        local iXLabelW = (iW * self.y_axis.label_width)
        if (iCurXLabelW ~= iXLabelW) then
            dLine.label:SetSize(iXLabelW)
        end

        local iProgressW = (iW - iCurXLabelW) * (fValue / self.x_axis.max)
        if (dLine.progress:GetWide() ~= iProgressW) then
            dLine.progress:SetWide(iProgressW)
        end

        print("rewrite")
    end

    dLine.label = dLine:Add("DLabel")
    dLine.label:Dock(LEFT)
    dLine.label:SetFont("TLib2.7")
    dLine.label:SetTextColor(TLib2.Colors.Base4)
    dLine.label:SetContentAlignment(6)
    dLine.label:SetTextInset(TLib2.Padding2, 0)
    dLine.label:SetText(sLabel)

    dLine.progress = dLine:Add("DPanel")
    dLine.progress:Dock(FILL)
    dLine.progress.lerp_w = 0
    dLine.progress.Paint = function(_, iW, iH)
        dLine.progress.lerp_w = math.Approach(dLine.progress.lerp_w, iW, FrameTime() * 256)

        surface.SetDrawColor(dLine.progress:IsHovered() and TLib2.Colors.Action or TLib2.Colors.Accent)
        surface.DrawRect(0, 0, dLine.progress.lerp_w, iH)

        draw.SimpleText(self.y_axis.format_value(iKey, fValue), "TLib2.7", math.min(dLine.progress.lerp_w, iW) - TLib2.Padding4, iH * 0.5, TLib2.Colors.Base4, 2, 1)
    end

    return iKey
end

function PANEL:RemoveData(iKey)
    local tNewData = {}
    for i = 1, #self.data do
        if (i ~= iKey) then
            tNewData[#tNewData + 1] = self.data[i]
        else
            if self.data[i].line and self.data[i].line:IsValid() then
                self.data[i].line:Remove()
            end
        end
    end
    self.data = tNewData
end

function PANEL:Paint(iW, iH)
    local iXLabelW = (iW * self.y_axis.label_width)

    surface.SetDrawColor(TLib2.Colors.Base1)
    surface.DrawRect(0, 0, iW, iH)

    surface.SetDrawColor(TLib2.Colors.Base3)

    for i = 0, (self.x_axis.steps) do
        local iX = ((iW - iXLabelW - TLib2.Padding2) * ((i) / (self.x_axis.steps))) + iXLabelW - 1

        surface.DrawLine(iX, 0, iX, iH - (TLib2.Padding4 * 5))
        draw.SimpleText(self.x_axis.format_step(((self.x_axis.max / self.x_axis.steps) * i), i), "TLib2.7", iX, iH, TLib2.Colors.Base3, 1, 4)
    end
end

function PANEL:PerformLayout(iW, iH)
    local iTall = 0

    for i = 1, #self.data do
        local dLine = self.data[i].line
        if dLine and dLine:IsValid() then
            local _, iMT, _, iMB = dLine:GetDockMargin()
            iTall = iTall + dLine:GetTall() + iMT + iMB
        end
    end

    iTall = iTall + (TLib2.Padding4 * 8)

    if (iH ~= iTall) then
        self:SetTall(iTall)
    end
end

vgui.Register("TLib2:BarChart", PANEL, "DPanel")