local PANEL = {}

local surface = surface

function PANEL:Init()
    local dPanel = self
    local dCanvas = self:GetCanvas()
 
    self.vbar_w = math.max(math.ceil(ScrH() * 0.004), 3)
    self.vbar_m = TLib2.Padding3
    
    local dVBar = self:GetVBar()
    dVBar:SetWide(0)
    dVBar:SetHideButtons(true)
    dVBar.drag_approach = 0

    function dVBar:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base1)
        surface.DrawRect((iW - dPanel.vbar_w), 0, dPanel.vbar_w, iH)

        self.drag_approach = math.Approach(self.drag_approach, self.Dragging and 1 or 0, RealFrameTime() * 4)
    end

    function dVBar.btnUp:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawRect((iW - dPanel.vbar_w), 0, dPanel.vbar_w, iH)
    end

    function dVBar.btnDown:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawRect((iW - dPanel.vbar_w), 0, dPanel.vbar_w, iH)
    end

    function dVBar.btnGrip:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors[self:IsHovered() and "Base4" or "Base3"])
        surface.DrawRect((iW - dPanel.vbar_w), 0, dPanel.vbar_w, iH)

        if (dVBar.drag_approach > 0.001) then
            local iDragBarH = (iH * dVBar.drag_approach)

            surface.SetDrawColor(TLib2.Colors.Accent)
            surface.DrawRect((iW - dPanel.vbar_w), (iH - iDragBarH) * 0.5, dPanel.vbar_w, iDragBarH)
        end
    end

    self.__old_perform_layout = self.PerformLayout
    self.PerformLayout = function()
        if self.__old_perform_layout then
            self:__old_perform_layout()
        end

        if (dCanvas:GetTall() > self:GetTall()) then
            local iTargetW = (self:GetVBarWidth() + self:GetVBarMargin())
            if (iTargetW ~= dVBar:GetWide()) then
                dVBar:SetWide(iTargetW)
            end
        else
            if (dVBar:GetWide() ~= 0) then
                dVBar:SetWide(0)
            end
        end
    end
end

function PANEL:GetVBarWidth()
    return self.vbar_w
end

function PANEL:SetVBarWidth(iWidth)
    self.vbar_w = (type(iWidth) == "number") and iWidth or 0
end

function PANEL:GetVBarMargin()
    return self.vbar_m
end

function PANEL:SetVBarMargin(iMargin)
    self.vbar_m = (type(iMargin) == "number") and iMargin or 0
end

function PANEL:GetBackgroundInfo()
    return self.bg_info
end

function PANEL:SetBackgroundInfo(sLabel, sFAIcon)
    if not sLabel and not sFAIcon then
        self.bg_info = nil
        return
    end

    self.bg_info = {}
    self.bg_info.faicon = sFAIcon

    if sLabel then
        self.bg_info.markup = markup.Parse("<font=TLib2.7><colour="..tostring(TLib2.Colors.Base3)..">"..sLabel.."</colour></font>")
    end
end

function PANEL:Paint(iW, iH)
    if (self.bg_info) then
        if self.bg_info.faicon then
            local tFACol = ((os.time() % 2) == 1) and TLib2.Colors.Base2 or TLib2.Colors.Base3
            TLib2.DrawFAIcon(self.bg_info.faicon, "TLib2.FA.5", (iW * 0.5), (iH * 0.5) - TLib2.Padding3, tFACol, 1, 1)
        end
        if self.bg_info.markup then
            self.bg_info.markup:Draw((iW * 0.5), (iH * 0.5) + TLib2.Padding3, 1, 3, iW, iH)
        end
    end
end

vgui.Register("TLib2:Scroll", PANEL, "DScrollPanel")