local PANEL = {}

local draw = draw
local surface = surface

function PANEL:Init()
    self.lblTitle:SetText("")

    self:SetSize(ScrH() * 0.36, 0)
    self:ShowCloseButton(false)
    self:DockPadding(ZoneCreator.Padding1, ZoneCreator.Padding1, ZoneCreator.Padding1, ZoneCreator.Padding1)
    self:Center()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.5, 0.1)
    self:MakePopup()
	self.startTime = SysTime()

    self.close_button_container = self:Add("DPanel")
    self.close_button_container:Dock(TOP)
    self.close_button_container:SetTall(0)
    self.close_button_container.Paint = nil

    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
    self.title:SetText("")
    self.title:SetFont("TLib2.4")
    self.title:SetWrap(true)
    self.title:SetAutoStretchVertical(true)
    self.title:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
    self.title:DockMargin(0, 0, 0, ZoneCreator.Padding2)

    self.subtitle = self:Add("DLabel")
    self.subtitle:Dock(TOP)
    self.subtitle:SetFont("TLib2.6")
    self.subtitle:SetText("")
    self.subtitle:SetWrap(true)
    self.subtitle:SetAutoStretchVertical(true)
    self.subtitle:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    self.subtitle:DockMargin(0, 0, 0, ZoneCreator.Padding2)

    self.content_container = self:Add("DPanel")
    self.content_container:Dock(TOP)
    self.content_container.Paint = nil
end

function PANEL:OnRemove()
    if self.bg_fullscreen and self.bg_fullscreen:IsValid() then
        self.bg_fullscreen:Remove()
    end
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
    if not bShowCloseButton then
        if self.close_button and self.close_button:IsValid() then
            self.close_button:Remove()
        end
        self.close_button_container:DockMargin(0, 0, 0, 0)
        return
    end

    if self.close_button and self.close_button:IsValid() then return end

    self.close_button_container:DockMargin(0, 0, 0, ZoneCreator.Padding2)
    self.close_button = self.close_button_container:Add("ZoneCreator:Button")
    self.close_button:Dock(RIGHT)
    self.close_button:DockMargin(0, 0, 0, 0)
    self.close_button:SetFont("TLib2.6")
    self.close_button:SetText(ZoneCreator:I18n("generic.close"))
    self.close_button:SetTall(ScrH() * 0.024)
    self.close_button:SetFAIcon("f00d", "TLib2.FA.6", true)
    self.close_button:SetTextColor(ZoneCreator.Cfg.Colors.Base4)

    local dModal = self
    function self.close_button:DoClick()
        dModal:Remove()
    end
end

function PANEL:Paint(iW, iH)
    Derma_DrawBackgroundBlur(self, self.startTime)

    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base2)
    draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, ZoneCreator.Cfg.Colors.Base0)
end

function PANEL:PerformLayout(iW, iH)
    if not self:IsValid() then return end

    if (self.bg_fullscreen) then
        self.bg_fullscreen:SetSize(ScrW(), ScrH())
    end
    if (self.close_button_container) then
        self.close_button_container:SizeToChildren(false, true)
    end
    if (self.content_container) then
        self.content_container:SizeToChildren(false, true)
    end

    self:SizeToChildren(false, true)

    local iNewX, iNewY = (ScrW() - iW) * 0.5, (ScrH() - iH) * 0.5
    if (iX ~= iNewX) or (iY ~= iNewY) then
        self:SetPos(iNewX, iNewY)
    end
end

function PANEL:AddSeparator()
    local dSeparator = self.content_container:Add("ZoneCreator:Separator")
    dSeparator:DockMargin(0, ZoneCreator.Padding2, 0, ZoneCreator.Padding2)

    return dSeparator
end

function PANEL:AddButton(sLabel, fnCallback)
    local dModal = self
    local dBtn = self.content_container:Add("ZoneCreator:Button")
    dBtn:Dock(TOP)
    dBtn:DockMargin(0, ZoneCreator.Padding2, 0, 0)
    dBtn:SetText(sLabel)

    function dBtn:DoClick()
        dModal:Remove()

        if (type(fnCallback) == "function") then
            fnCallback()
        end
    end

    return dBtn
end

function PANEL:AddTextEntry()
    local dTextEntry = self.content_container:Add("ZoneCreator:TextEntry")
    dTextEntry:Dock(TOP)
    dTextEntry:DockMargin(0, ZoneCreator.Padding2, 0, 0)
    dTextEntry:SetTall(ScrH() * 0.03)

    return dTextEntry
end

vgui.Register("ZoneCreator:Modal", PANEL, "DFrame")

-- local modal = vgui.Create("ZoneCreator:Modal")
-- modal:SetShowCloseButton(true)
-- modal:SetTitle("Delete zone?")
-- modal:SetSubtitle("Are you sure you want to delte this zone? This Action cannot be undone.")
-- modal:SetFAIcon("f055")
-- modal:AddTextEntry()
-- modal:AddSeparator()
-- modal:AddButton("Yes", function() end)
-- modal:AddButton("No", function() end)
