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
        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base1)
        surface.DrawRect(0, 0, iW, iH)

        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base0)
        surface.SetMaterial(matGradD)
        surface.DrawTexturedRect(0, 0, iW, iH)

        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base2)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))

        local iTitleX = ZoneCreator.Padding3
        if dPanel.title_faicon then
            draw.SimpleText(dPanel.title_faicon, "TLib2.FA.6", (iH + ZoneCreator.Padding3) * 0.5, (iH * 0.5), ZoneCreator.Cfg.Colors.Base4, 1, 1)
            iTitleX = iH + ZoneCreator.Padding3
        end

        if dPanel.title then
            draw.SimpleText(dPanel.title, "TLib2.6", iTitleX, (iH * 0.5), ZoneCreator.Cfg.Colors.Base4, 0, 1)
        end
    end

    function self.header:OnMousePressed(...)
        local fTime = CurTime()
        if ((fTime - self.last_click) < 0.3) then
            ZoneCreator.Menu:ToggleExpand()
        end
        self.last_click = fTime

        if ZoneCreator.Menu:IsExpanded() then return end
        ZoneCreator.Menu:OnMousePressed(...)
    end

    function self.header:OnMouseReleased(...)
        if ZoneCreator.Menu:IsExpanded() then return end
        ZoneCreator.Menu:OnMouseReleased(...)
    end

    self.close_btn = self.header:Add("DButton")
    self.close_btn:Dock(RIGHT)
    self.close_btn:DockMargin((iScrH * 0.002), 0, 0, 0)
    self.close_btn:SetWide(self.header:GetTall())
    self.close_btn:SetText("")
    self.close_btn:SetCursor("hand")

    local sCloseBtnFA = TLib2.GetFAIcon("f057")
    function self.close_btn:Paint(iW, iH)
        if self:IsHovered() then
            surface.SetDrawColor(ZoneCreator.Cfg.Colors.Warn)
            surface.DrawRect(0, 0, iW, iH)

            draw.SimpleText(sCloseBtnFA, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Base4, 1, 1)
        else
            draw.SimpleText(sCloseBtnFA, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Base3, 1, 1)
        end
    end
    function self.close_btn:DoClick()
        ZoneCreator.Menu:Remove()
    end

    self.expand_btn = self.header:Add("DButton")
    self.expand_btn:Dock(RIGHT)
    self.expand_btn:SetWide(self.header:GetTall())
    self.expand_btn:SetText("")
    self.expand_btn:SetCursor("hand")

    local sExpandBtnFA = TLib2.GetFAIcon("f2d0")
    function self.expand_btn:Paint(iW, iH)
        if self:IsHovered() then
            surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base2)
            surface.DrawRect(0, 0, iW, iH)

            draw.SimpleText(sExpandBtnFA, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Base4, 1, 1)
        else
            draw.SimpleText(sExpandBtnFA, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Base3, 1, 1)
        end
    end
    function self.expand_btn:DoClick()
        ZoneCreator.Menu:ToggleExpand()
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
    surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base0)
    surface.DrawRect(0, 0, iW, iH)
end

function PANEL:SetTitle(sTitle, sFAIcon)
    self.title = sTitle
    self.title_faicon = sFAIcon
end

function PANEL:PerformLayout()
    if self.header and (self.header:IsValid()) then
        self.header:SetTall(ScrH() * 0.028)
    end
    if self.close_btn and (self.close_btn:IsValid()) then
        self.close_btn:SetWide(self.header:GetTall())
    end
    if self.expand_btn and (self.expand_btn:IsValid()) then
        self.expand_btn:SetWide(self.header:GetTall())
    end
end

vgui.Register("ZoneCreator:Frame", PANEL, "DFrame")