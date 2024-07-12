local PANEL = {}

local matGradD = Material("vgui/gradient-d")

function PANEL:Init()
    local dPanel = self
    local iScrH = ScrH()

    self:DockPadding(0, 0, 0, 0)
    self.expanded = false
    self.anim_time = 0.25

    self.lblTitle:Remove()
    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()

    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetCursor("sizeall")
    self.header.last_click = 0

    function self.header:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base1)
        surface.DrawRect(0, 0, iW, iH)

        local iTitleX = TLib2.Padding4
        if dPanel.title_faicon then
            TLib2.DrawFAIcon(dPanel.title_faicon, "TLib2.FA.6", (iH + TLib2.Padding4) * 0.5, (iH * 0.5), TLib2.Colors.Base4, 1, 1)
            iTitleX = iH + TLib2.Padding4
        end

        if dPanel.title then
            draw.SimpleText(dPanel.title, "TLib2.6", iTitleX, (iH * 0.5), TLib2.Colors.Base4, 0, 1)
        end
    end

    function self.header:OnMousePressed(...)
        local fTime = CurTime()
        if ((fTime - self.last_click) < 0.3) then
            dPanel:ToggleExpand()
        end
        self.last_click = fTime

        if dPanel:IsExpanded() then return end
        dPanel:OnMousePressed(...)
    end

    function self.header:OnMouseReleased(...)
        if dPanel:IsExpanded() then return end
        dPanel:OnMouseReleased(...)
    end

    self.header_line = self:Add("DPanel")
    self.header_line:Dock(TOP)
    self.header_line:SetTall(1)
    self.header_line:SetBackgroundColor(TLib2.Colors.Base2)

    self.close_btn = self.header:Add("DButton")
    self.close_btn:Dock(RIGHT)
    self.close_btn:DockMargin((iScrH * 0.002), 0, 0, 0)
    self.close_btn:SetWide(self.header:GetTall())
    self.close_btn:SetText("")
    self.close_btn:SetCursor("hand")
    function self.close_btn:Paint(iW, iH)
        if self:IsHovered() then
            surface.SetDrawColor(TLib2.Colors.Warn)
            surface.DrawRect(0, 0, iW, iH)

            TLib2.DrawFAIcon("f057", "TLib2.FA.6", (iW * 0.5), (iH * 0.5) + 1, TLib2.Colors.Base0, 1, 1)
            TLib2.DrawFAIcon("f057", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base5, 1, 1)
        else
            TLib2.DrawFAIcon("f057", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base3, 1, 1)
        end
    end
    function self.close_btn:DoClick()
        dPanel:Remove()
    end

    self.expand_btn = self.header:Add("DButton")
    self.expand_btn:Dock(RIGHT)
    self.expand_btn:SetWide(self.header:GetTall())
    self.expand_btn:SetText("")
    self.expand_btn:SetCursor("hand")
    function self.expand_btn:Paint(iW, iH)
        if self:IsHovered() then
            surface.SetDrawColor(TLib2.Colors.Base3)
            surface.DrawRect(0, 0, iW, iH)

            TLib2.DrawFAIcon("f2d0", "TLib2.FA.6", (iW * 0.5), (iH * 0.5) + 1, TLib2.Colors.Base0, 1, 1)
            TLib2.DrawFAIcon("f2d0", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base5, 1, 1)
        else
            TLib2.DrawFAIcon("f2d0", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base3, 1, 1)
        end
    end
    function self.expand_btn:DoClick()
        dPanel:ToggleExpand()
    end
end

function PANEL:IsExpanded()
    return self.expanded
end

function PANEL:SetExpanded(bExpanded)
    local fAnimTime = self:GetAnimatonTime()

    self.expanded = tobool(bExpanded)

    if self.expanded then
        self:SizeTo(ScrW(), ScrH(), fAnimTime, 0, 0.5)
        self:MoveTo(0, 0, fAnimTime, 0, 0.5)
    else
        local tMinSize = self:GetMinimizedSize()
        if not tMinSize then return end

        self:SizeTo(tMinSize.w, tMinSize.h, fAnimTime, 0, 0.5)
        self:MoveTo((ScrW() - tMinSize.w) * 0.5, (ScrH() - tMinSize.h) * 0.5, fAnimTime, 0, 0.5)
    end
end

function PANEL:ToggleExpand()
    self:SetExpanded(not self:IsExpanded())
end

function PANEL:GetMinimizedSize()
    return self.minimized_size
end

function PANEL:SetMinimizedSize(iW, iH)
    if (type(iW) ~= "number") or (type(iH) ~= "number") then return end

    self.minimized_size = {w = iW, h = iH}
end

function PANEL:GetAnimatonTime()
    return self.anim_time
end

function PANEL:SetAnimationTime(fTime)
    if (type(fTime) ~= "number") then return end

    self.anim_time = fTime
end

function PANEL:Paint(iW, iH)
    surface.SetDrawColor(TLib2.Colors.Base0)
    surface.DrawRect(0, 0, iW, iH)
end

function PANEL:SetTitle(sTitle, sFAIcon)
    self.title = sTitle
    self.title_faicon = sFAIcon
end

function PANEL:PerformLayout()
    if self.header and self.header:IsValid() then
        self.header:SetTall(ScrH() * 0.026)
    end
    if self.close_btn and self.close_btn:IsValid() then
        self.close_btn:SetWide(self.header:GetTall())
    end
    if self.expand_btn and self.expand_btn:IsValid() then
        self.expand_btn:SetWide(self.header:GetTall())
    end
end

vgui.Register("TLib2:Frame", PANEL, "DFrame")