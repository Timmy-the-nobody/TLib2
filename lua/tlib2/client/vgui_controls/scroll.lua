local PANEL = {}

local surface = surface

local matGradU = Material("vgui/gradient-u")
local matGradD = Material("vgui/gradient-d")

function PANEL:Init()
    self.edge_gradient_color = TLib2.Colors.Base0

    local iVBarW = math.max(math.ceil(ScrH() * 0.004), 3)

    local dVBar = self:GetVBar()
    dVBar:SetWide(iVBarW + TLib2.Padding3)
    dVBar:SetHideButtons(true)
    dVBar.drag_approach = 0

    function dVBar:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base1)
        surface.DrawRect((iW - iVBarW), 0, iVBarW, iH)

        self.drag_approach = math.Approach(self.drag_approach, self.Dragging and 1 or 0, RealFrameTime() * 4)
    end

    function dVBar.btnUp:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawRect((iW - iVBarW), 0, iVBarW, iH)
    end

    function dVBar.btnDown:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawRect((iW - iVBarW), 0, iVBarW, iH)
    end

    function dVBar.btnGrip:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors[self:IsHovered() and "Base4" or "Base3"])
        surface.DrawRect((iW - iVBarW), 0, iVBarW, iH)

        if (dVBar.drag_approach > 0.001) then
            local iDragBarH = (iH * dVBar.drag_approach)

            surface.SetDrawColor(TLib2.Colors.Accent)
            surface.DrawRect((iW - iVBarW), (iH - iDragBarH) * 0.5, iVBarW, iDragBarH)
        end
    end

    self.lerp_up = 0
    self.lerp_down = 0
    self.gradient_height = (ScrH() * 0.02)
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
            draw.SimpleText(self.bg_info.faicon, "TLib2.FA.5", (iW * 0.5), (iH * 0.5) - TLib2.Padding3, tFACol, 1, 1)
        end
        if self.bg_info.markup then
            self.bg_info.markup:Draw((iW * 0.5), (iH * 0.5) + TLib2.Padding3, 1, 3, iW, iH)
        end
    end
end

function PANEL:GetEdgeGradientColor()
    return self.edge_gradient_color
end

function PANEL:SetEdgeGradientColor(oColor)
    if not IsColor(oColor) then return end

    self.edge_gradient_color = oColor
end

-- function PANEL:PaintOver(iW, iH)
--     local dVBar = self:GetVBar()
--     if not dVBar or (dVBar.CanvasSize < iH) then return end

--     local fGradSpeed = (RealFrameTime() * 8)
--     local iScroll = dVBar:GetScroll()

--     self.lerp_up = Lerp(fGradSpeed, self.lerp_up, (iScroll > 0) and 1 or 0)
--     self.lerp_down = Lerp(fGradSpeed, self.lerp_down, (iScroll < dVBar.CanvasSize) and 1 or 0)

--     if (self.lerp_up > 0.001) then
--         surface.SetMaterial(matGradU)
--         surface.SetDrawColor(self.edge_gradient_color)
--         surface.DrawTexturedRect(0, 0, iW - dVBar:GetWide(), math.floor(self.gradient_height * self.lerp_up))
--     end

--     if (self.lerp_down > 0.001) then
--         local iGradH = math.floor(self.gradient_height * self.lerp_down)

--         surface.SetMaterial(matGradD)
--         surface.SetDrawColor(self.edge_gradient_color)
--         surface.DrawTexturedRect(0, (iH - iGradH), iW - dVBar:GetWide(), iGradH)
--     end
-- end

vgui.Register("TLib2:Scroll", PANEL, "DScrollPanel")