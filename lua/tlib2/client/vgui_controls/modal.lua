local PANEL = {}

local draw = draw

function PANEL:Init()
    self.lblTitle:SetText("")

    if self.header and self.header:IsValid() then
        self.header:Remove()
    end

    self:SetSize(ScrH() * 0.36, 0)
    self:ShowCloseButton(false)
    self:DockPadding(TLib2.Padding2, TLib2.Padding2, TLib2.Padding2, TLib2.Padding2)
    self:Center()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.5, 0.1)
    self:MakePopup()
	self.startTime = SysTime()

    self.close_button = self:Add("TLib2:Button")
    self.close_button:SetVisible(false)
    self.close_button:SetFont("TLib2.6")
    self.close_button:SetSize(TLib2.VGUIControlH2, TLib2.VGUIControlH2)
    self.close_button:SetFAIcon("f00d", "TLib2.FA.6", true)
    self.close_button:SetTextColor(TLib2.Colors.Base4)
    self.close_button.DoClick = function()
        self:Remove()
    end

    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
    self.title:SetText("")
    self.title:SetFont("TLib2.4")
    self.title:SetWrap(true)
    self.title:SetAutoStretchVertical(true)
    self.title:SetTextColor(TLib2.Colors.Base4)
    self.title:DockMargin(0, 0, 0, TLib2.Padding3)

    self.subtitle = self:Add("DLabel")
    self.subtitle:Dock(TOP)
    self.subtitle:SetFont("TLib2.6")
    self.subtitle:SetText("")
    self.subtitle:SetWrap(true)
    self.subtitle:SetAutoStretchVertical(true)
    self.subtitle:SetTextColor(TLib2.Colors.Base3)
    self.subtitle:DockMargin(0, 0, 0, TLib2.Padding3)

    self.content_container = self:Add("DPanel")
    self.content_container:Dock(TOP)
    self.content_container.Paint = nil
end

function PANEL:OnRemove()
end

function PANEL:SetFAIcon(sFAIcon)
    self.fa_icon = sFAIcon
end

function PANEL:SetTitle(sTitle)
    self.title:SetText(sTitle)
end

function PANEL:SetSubtitle(sSubtitle)
    self.subtitle:SetText(sSubtitle)
end

function PANEL:SetShowCloseButton(bShowCloseButton)
    if bShowCloseButton then
        self.close_button:SetVisible(true)

        self.title:DockMargin(0, 0, TLib2.VGUIControlH2 + (TLib2.Padding4 * 2), TLib2.Padding3)
        self.subtitle:DockMargin(0, 0, TLib2.VGUIControlH2 + (TLib2.Padding4 * 2), TLib2.Padding3)
    else
        self.close_button:SetVisible(false)

        self.title:DockMargin(0, 0, 0, TLib2.Padding3)
        self.subtitle:DockMargin(0, 0, 0, TLib2.Padding3)
    end
end

function PANEL:Paint(iW, iH)
    Derma_DrawBackgroundBlur(self, self.startTime)

    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
    draw.RoundedBox((TLib2.BorderRadius - 2), 1, 1, (iW - 2), (iH - 2), TLib2.Colors.Base0)
end

function PANEL:PerformLayoutInternal(iW, iH)
    if self.content_container and self.content_container:IsValid() then
        self.content_container:SizeToChildren(false, true)
    end

    self:SizeToChildren(false, true)

    local iNewX, iNewY = (ScrW() - iW) * 0.5, (ScrH() - iH) * 0.5
    if (iX ~= iNewX) or (iY ~= iNewY) then
        self:SetPos(iNewX, iNewY)
    end

    if self.close_button and self.close_button:IsValid() then
        local iButtonX, iButtonY = self.close_button:GetPos()
        local iTargetX, iTargetY = (iW - self.close_button:GetWide() - TLib2.VGUIControlH2), TLib2.VGUIControlH2

        if (iButtonX ~= iTargetX) or (iButtonY ~= iTargetY) then
            self.close_button:SetPos(iTargetX, iTargetY)
        end
    end
end

function PANEL:AddSeparator()
    local dSeparator = self.content_container:Add("TLib2:Separator")
    dSeparator:Dock(TOP)
    dSeparator:DockMargin(0, TLib2.Padding3, 0, TLib2.Padding3)

    return dSeparator
end

function PANEL:AddButton(sLabel, fnCallback)
    local dBtn = self.content_container:Add("TLib2:Button")
    dBtn:SetTall(TLib2.VGUIControlH1)
    dBtn:Dock(TOP)
    dBtn:DockMargin(0, TLib2.Padding3, 0, 0)
    dBtn:SetText(sLabel)
    dBtn.DoClick = function()
        if (type(fnCallback) ~= "function") or not fnCallback() then
            self:Remove()
        end
    end

    return dBtn
end

function PANEL:AddTextEntry()
    local dTextEntry = self.content_container:Add("TLib2:TextEntry")
    dTextEntry:Dock(TOP)
    dTextEntry:DockMargin(0, TLib2.Padding3, 0, 0)
    dTextEntry:SetTall(TLib2.VGUIControlH1)

    return dTextEntry
end

vgui.Register("TLib2:Modal", PANEL, "TLib2:Frame")