local surface = surface

local matGradD = Material("vgui/gradient-d", "noclamp smooth")
local tDefaultSkin = derma.GetNamedSkin("Default")
local fnShadowTex = false
if tDefaultSkin and tDefaultSkin.tex then
    fnShadowTex = tDefaultSkin.tex.Shadow
end

---@class TLib2:Frame : DFrame
local PANEL = {}

function PANEL:Init()
    local dPanel = self
    local iScrH = ScrH()

    self:DockPadding(0, 0, 0, 0)
    
    self.anim_time = 0.25
    self.default_w = self:GetWide()
    self.default_h = self:GetTall()
    self.min_w = (iScrH * 0.7)
    self.min_h = (iScrH * 0.4)

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
            TLib2.DrawFAIcon(dPanel.title_faicon, "TLib2.FA.6", (iH * 0.5) + TLib2.Padding4, (iH * 0.5), TLib2.Colors.Base4, 1, 1)
            iTitleX = iH + (TLib2.Padding4 * 2)
        end

        if dPanel.title then
            draw.SimpleText(dPanel.title, "TLib2.6", iTitleX, (iH * 0.5), TLib2.Colors.Base4, 0, 1)
        end

        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
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
        dPanel:OnMouseReleased(...)
    end


    self.close_btn = self.header:Add("DButton")
    self.close_btn:Dock(RIGHT)
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

            TLib2.DrawFAIcon("f31e", "TLib2.FA.6", (iW * 0.5), (iH * 0.5) + 1, TLib2.Colors.Base0, 1, 1)
            TLib2.DrawFAIcon("f31e", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base5, 1, 1)
        else
            TLib2.DrawFAIcon("f31e", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base3, 1, 1)
        end
    end
    function self.expand_btn:DoClick()
        dPanel:ToggleExpand()
    end
end

---`🔸 Client`<br>
---Returns whether the frame is expanded (maximized to full screen)
---@return boolean @Whether the frame is expanded
function PANEL:IsExpanded()
    return ((self:GetWide() == ScrW()) and (self:GetTall() == ScrH()))
end

---`🔸 Client`<br>
---Sets whether the frame is expanded (maximized to full screen)
---@param bExpanded boolean @Whether the frame is expanded
function PANEL:SetExpanded(bExpanded)
    local fAnimTime = self:GetAnimatonTime()

    if bExpanded then
        self:SizeTo(ScrW(), ScrH(), fAnimTime, 0, 0.5)
        self:MoveTo(0, 0, fAnimTime, 0, 0.5)

        TLib2.PlayUISound("tlib2/maximize.ogg")
    else
        local iDefaultW, iDefaultH = self:GetDefaultSize()

        self:SizeTo(iDefaultW, iDefaultH, fAnimTime, 0, 0.5)
        self:MoveTo((ScrW() - iDefaultW) * 0.5, (ScrH() - iDefaultH) * 0.5, fAnimTime, 0, 0.5)

        TLib2.PlayUISound("tlib2/minimize.ogg")
    end
end

---`🔸 Client`<br>
---Toggles whether the frame is expanded (maximized to full screen)
function PANEL:ToggleExpand()
    self:SetExpanded(not self:IsExpanded())
end

---`🔸 Client`<br>
---Returns the minimum size the frame can be
---@return number @The minimum size the frame can be
function PANEL:GetMinWidth()
    return self.min_w
end

---`🔸 Client`<br>
---Sets the minimum size the frame can be
---@param iWidth number @The minimum size the frame can be
function PANEL:SetMinWidth(iWidth)
    if (type(iWidth) ~= "number") then return end
    self.min_w = math.Round(iWidth)
end

---`🔸 Client`<br>
---Returns the minimum height the frame can be
---@return number @The minimum height the frame can be
function PANEL:GetMinHeight()
    return self.min_h
end

---`🔸 Client`<br>
---Sets the minimum height the frame can be
---@param iHeight number @The minimum height the frame can be
function PANEL:SetMinHeight(iHeight)
    if (type(iHeight) ~= "number") then return end
    self.min_h = math.Round(iHeight)
end

---`🔸 Client`<br>
---Util method that return the minimum width and the minimum height of the frame
---@return number @The minimum width the frame can be
---@return number @The minimum height the frame can be
function PANEL:GetMinSize()
    return self:GetMinWidth(), self:GetMinHeight()
end

---`🔸 Client`<br>
---Util method that sets the minimum width and the minimum height of the frame
---@param iWidth number @The minimum width the frame can be
---@param iHeight number @The minimum height the frame can be
function PANEL:SetMinSize(iWidth, iHeight)
    self:SetMinWidth(iWidth)
    self:SetMinHeight(iHeight)
end

---`🔸 Client`<br>
---Returns the default width
---@return number @The default width
function PANEL:GetDefaultWidth()
    return self.default_w
end

---`🔸 Client`<br>
---Sets the default width
---@param iWidth number @The default width
function PANEL:SetDefaultWidth(iWidth)
    if (type(iWidth) ~= "number") then return end
    self.default_w = math.Round(iWidth)
end

---`🔸 Client`<br>
---Returns the default height
---@return number @The default height
function PANEL:GetDefaultHeight()
    return self.default_h
end

---`🔸 Client`<br>
---Sets the default height
---@param iHeight number @The default height
function PANEL:SetDefaultHeight(iHeight)
    if (type(iHeight) ~= "number") then return end
    self.default_h = math.Round(iHeight)
end

---`🔸 Client`<br>
---Util method that return the default width and the default height of the frame
---@return number @The default width the frame can be
---@return number @The default height the frame can be
function PANEL:GetDefaultSize()
    return self:GetDefaultWidth(), self:GetDefaultHeight()
end

---`🔸 Client`<br>
---Util method that sets the default width and the default height of the frame
---@param iW number @The default width the frame can be
---@param iH number @The default height the frame can be
function PANEL:SetDefaultSize(iW, iH)
    self:SetDefaultWidth(iW)
    self:SetDefaultHeight(iH)
end

---`🔸 Client`<br>
---Returns the time it takes for the frame to animate
---@return number @The time it takes for the frame to animate
function PANEL:GetAnimatonTime()
    return self.anim_time
end

---`🔸 Client`<br>
---Sets the time it takes for the frame to animate
---@param fTime number @The time it takes for the frame to animate
function PANEL:SetAnimationTime(fTime)
    if (type(fTime) ~= "number") then return end
    self.anim_time = fTime
end

function PANEL:Paint(iW, iH)
    if fnShadowTex then
        local bOldClipping = DisableClipping(true)
        tDefaultSkin.tex.Shadow(-TLib2.Padding3, -TLib2.Padding3, iW + (TLib2.Padding3 * 2), iH + (TLib2.Padding3 * 2), color_white)
        DisableClipping(bOldClipping)
    end

    surface.SetDrawColor(TLib2.Colors.Base0)
    surface.DrawRect(0, 0, iW, iH)
end

---`🔸 Client`<br>
---Sets the title of the frame
---@param sTitle string @The title of the frame
---@param sFAIcon string @The FA icon of the frame
function PANEL:SetTitle(sTitle, sFAIcon)
    self.title = sTitle
    self.title_faicon = sFAIcon
end

---`🔸 Client`<br>
---Returns if the frame can be resized
---@return boolean @Whether the frame can be resized
function PANEL:IsResizable()
    return self.resize_btn and self.resize_btn:IsValid()
end

---`🔸 Client`<br>
---Sets if the frame can be resized
---@param bResizable boolean @Whether the frame can be resized
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
        TLib2.DrawFAIcon("f424", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base2, 1, 1)
    end
end

function PANEL:PerformLayout(iW, iH)
    if self.PerformLayoutInternal then
        self:PerformLayoutInternal(iW, iH)
    end

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
        self.resize_btn:MoveToFront()

        if (iW == ScrW()) and (iH == ScrH()) then
            if self.resize_btn:IsVisible() then
                self.resize_btn:Hide()
            end
        else
            if not self.resize_btn:IsVisible() then
                self.resize_btn:Show()
            end
        end

        if self.resize_btn:IsVisible() then
            local iX, iY = self.resize_btn:GetPos()
            local iTargetX, iTargetY = (iW - TLib2.VGUIControlH2), (iH - TLib2.VGUIControlH2)

            if (iX ~= iTargetX) or (iY ~= iTargetY) then
                self.resize_btn:SetPos(iTargetX, iTargetY)
                self.resize_btn:MoveToFront()
            end
        end
    end

    if self.notifs then
        local iTotalH = 0
        for i = 1, #self.notifs do
            local dNotif = self.notifs[i]
            if not dNotif:IsValid() then continue end

            local iNotifH = dNotif:GetTall()

            local iX = (iW - dNotif:GetWide()) * 0.5
            local iY = (iH - iNotifH) - TLib2.Padding2 - iTotalH - (TLib2.Padding4 * (i - 1))
            
            iTotalH = (iTotalH + iNotifH)

            if (dNotif:GetX() ~= iX) or (dNotif:GetY() ~= iY) then
                dNotif:SetPos(iX, iY)
            end
        end
    end
end

local tNotifTypes = {
    [NOTIFY_GENERIC] = {
        color = TLib2.Colors.Accent,
        fa_icon = "f0eb",
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/confirmation.ogg")
        end
    },
    [NOTIFY_ERROR] = {
        color = TLib2.Colors.Warn,
        fa_icon = "f2d3",
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/error.ogg")
        end
    },
    [NOTIFY_UNDO] = {
        color = TLib2.Colors.Accent,
        fa_icon = "f0e2",
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    },
    [NOTIFY_HINT] = {
        color = Color(243, 156, 18),
        fa_icon = "f059",
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    },
    [NOTIFY_CLEANUP] = {
        color = Color(243, 156, 18),
        fa_icon = "f0c4",
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    }
}

---`🔸 Client`<br>
---Displays a notification in the frame
---@param iNotifType? number @The notification type (see `NOTIFY_*`)
---@param sText? string @The text of the notification
---@param fDuration? number @The duration of the notification
function PANEL:Notify(iNotifType, sText, fDuration)
    if not iNotifType or not tNotifTypes[iNotifType] then
        iNotifType = 1
    end

    fDuration = fDuration or 5
    local tNotif = tNotifTypes[iNotifType]

    self.notifs = self.notifs or {}

    local iMaxNotifs = 4
    if #self.notifs >= iMaxNotifs then
        for i = 1, (#self.notifs - iMaxNotifs) do
            self.notifs[i]:KillNotif()
        end
    end

    local dNotif = self:Add("DPanel")
    self.notifs[#self.notifs + 1] = dNotif

    local sMarkup = ("<font=TLib2.6><color=%s>%s</color></font>"):format(tostring(TLib2.Colors.Base4), sText or "")
    local oMarkup = markup.Parse(sMarkup, (self:GetWide() * 0.5))
    local iTextW, iTextH = oMarkup:Size()
    local iStartTime = CurTime()
    local iBoxH = (iTextH + TLib2.Padding3)

    dNotif:SetSize(0, iBoxH)
    dNotif:SizeTo(iTextW + iBoxH + (TLib2.Padding4 * 3), iBoxH, 0.2, 0, 1)
    dNotif:SetAlpha(0)
    dNotif:AlphaTo(200, 0.5)
    dNotif:SetExpensiveShadow(2, TLib2.Colors.Base0)
    dNotif:SetDrawOnTop(true)
    dNotif:SetMouseInputEnabled(false)
    dNotif.shadow_color = ColorAlpha(TLib2.ColorManip(tNotif.color, 0.5, 0.5), 200)

    function dNotif:Paint(iW, iH)
        local iPercentage = math.Clamp((CurTime() - iStartTime) / fDuration, 0, 1)
        local fProgressW = iW - ((iW - 2 - iH) * iPercentage)

        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
        draw.RoundedBox((TLib2.BorderRadius - 2), 1, 1, (iW - 2), (iH - 2), TLib2.Colors.Base1)
        
        surface.SetDrawColor(tNotif.color)
        surface.DrawLine((iH - 1), (iH - 2), fProgressW, (iH - 2))

        draw.RoundedBoxEx((TLib2.BorderRadius - 2), 1, 1, (iH - 2), (iH - 2), tNotif.color, true, false, true, false)
        TLib2.DrawFAIcon(tNotif.fa_icon, "TLib2.FA.5", (iH * 0.5) + 1, (iH * 0.5) + 1, self.shadow_color, 1, 1)
        TLib2.DrawFAIcon(tNotif.fa_icon, "TLib2.FA.5", (iH * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)

        oMarkup:Draw((iH + TLib2.Padding4), TLib2.Padding4, "TLib2.6")
    end

    dNotif.KillNotif = function()
        dNotif:MoveTo(self:GetWide(), dNotif:GetY(), 0.2, 0, 1, function()
            if not self:IsValid() then return end

            local tNewNotifs = {}
            for i = 1, #self.notifs do
                if self.notifs[i] ~= dNotif then
                    tNewNotifs[#tNewNotifs + 1] = self.notifs[i]
                end
            end
            self.notifs = tNewNotifs

            if dNotif:IsValid() then
                dNotif:Remove()
            end
        end)
    end

    timer.Simple(fDuration, function()
        if not dNotif:IsValid() then return end
        dNotif:KillNotif()
    end)
end

vgui.Register("TLib2:Frame", PANEL, "DFrame")