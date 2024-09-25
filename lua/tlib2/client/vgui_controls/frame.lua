local PANEL = {}

local surface = surface

local matGradD = Material("vgui/gradient-d")

function PANEL:Init()
    local dPanel = self
    local iScrH = ScrH()

    self:DockPadding(0, 0, 0, 0)
    
    self.anim_time = 0.25
    self.__w = self:GetWide()
    self.__h = self:GetTall()
    self.min_w = (iScrH * 0.85)
    self.min_h = (iScrH * 0.6)

    self.lblTitle:Remove()
    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()

    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetTall(TLib2.VGUIControlH2)
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
    return ((self:GetWide() == ScrW()) and (self:GetTall() == ScrH()))
end

function PANEL:SetExpanded(bExpanded)
    local fAnimTime = self:GetAnimatonTime()

    if bExpanded then
        self:SizeTo(ScrW(), ScrH(), fAnimTime, 0, 0.5)
        self:MoveTo(0, 0, fAnimTime, 0, 0.5)
    else
        local iDefaultW, iDefaultH = self:GetDefaultSize()

        self:SizeTo(iDefaultW, iDefaultH, fAnimTime, 0, 0.5)
        self:MoveTo((ScrW() - iDefaultW) * 0.5, (ScrH() - iDefaultH) * 0.5, fAnimTime, 0, 0.5)
    end
end

function PANEL:ToggleExpand()
    self:SetExpanded(not self:IsExpanded())
end

function PANEL:GetMinWidth()
    return self.min_w
end

function PANEL:SetMinWidth(iWidth)
    if (type(iWidth) ~= "number") then return end
    self.min_w = iWidth
end

function PANEL:GetMinHeight()
    return self.min_h
end

function PANEL:SetMinHeight(iHeight)
    if (type(iHeight) ~= "number") then return end
    self.min_h = iHeight
end

function PANEL:GetDefaultSize()
    return self.__w, self.__h
end

function PANEL:SetDefaultSize(iW, iH)
    self.__w = iW
    self.__h = iH
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

function PANEL:SetResizable(bResizable)
    if self.resize_btn and self.resize_btn:IsValid() then
        self.resize_btn:Remove()
    end

    if not bResizable then return end

    local dPanel = self

    self.resize_btn = self:Add("DButton")
    self.resize_btn:SetText("")
    self.resize_btn:SetSize(TLib2.VGUIControlH2, TLib2.VGUIControlH2)
    self.resize_btn:SetCursor("sizenesw")
    self.resize_btn:AlignRight(0)
    self.resize_btn:AlignBottom(0)
    self.resize_btn:MoveToFront()
    self.resize_btn.dragging = false
    
    function self.resize_btn:PerformLayout(iW, iH)
        self:MoveToFront()
    end
    
    function self.resize_btn:OnMousePressed(iMouseBtn)
        if (iMouseBtn ~= MOUSE_LEFT) then return end

        local iCursorX, iCursorY = input.GetCursorPos()
        self.dragging = {
            x = iCursorX,
            y = iCursorY,
            w = dPanel:GetWide(),
            h = dPanel:GetTall()
        }
    end

    function self.resize_btn:Think()
        if self.dragging then
            if not input.IsMouseDown(MOUSE_LEFT) then
                self.dragging = nil
                return
            end
            
            local iCursorX, iCursorY = input.GetCursorPos()
            local iDiffX = (iCursorX - self.dragging.x)
            local iDiffY = (iCursorY - self.dragging.y)
            local iNewW = math.floor(math.max((self.dragging.w + iDiffX), dPanel:GetMinWidth()))
            local iNewH = math.floor(math.max((self.dragging.h + iDiffY), dPanel:GetMinHeight()))

            if (iNewW ~= dPanel:GetWide()) then
                dPanel:SetWide(iNewW)
            end

            if (iNewH ~= dPanel:GetTall()) then
                dPanel:SetTall(iNewH)
            end
        end
    end

    function self.resize_btn:Paint(iW, iH)
        if self.dragging then
            TLib2.DrawFAIcon("f424", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Accent, 1, 1)
            return
        end
        TLib2.DrawFAIcon("f424", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
    end
end

function PANEL:PerformLayout(iW, iH)
    if self.header and self.header:IsValid() then
        local iHeaderH = self.header:GetTall()
        if self.close_btn and self.close_btn:IsValid() and (self.close_btn:GetWide() ~= iHeaderH) then
            self.close_btn:SetWide(iHeaderH)
        end
        if self.expand_btn and self.expand_btn:IsValid() and (self.expand_btn:GetWide() ~= iHeaderH) then
            self.expand_btn:SetWide(iHeaderH)
        end
    end

    if self.resize_btn and self.resize_btn:IsValid() then
        if (self:GetWide() >= ScrW()) and (self:GetTall() >= ScrH()) then
            if self.resize_btn:IsVisible() then
                self.resize_btn:Hide()
            end
        else
            if not self.resize_btn:IsVisible() then
                self.resize_btn:Show()
            end
        end

        local iX, iY = self.resize_btn:GetPos()
        local iTargetX, iTargetY = (iW - TLib2.VGUIControlH2), (iH - TLib2.VGUIControlH2)

        if (iX ~= iTargetX) then
            self.resize_btn:SetX(iTargetX)
        end

        if (iY ~= iTargetY) then
            self.resize_btn:SetY(iTargetY)
        end
    end
end

vgui.Register("TLib2:Frame", PANEL, "DFrame")