local dLabel = dCanvas:Add("DLabel")
dLabel:Dock(TOP)
dLabel:DockMargin(0, 0, 0, 0)
dLabel:SetFont("TLib2.6")
dLabel:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
dLabel:SetTall(iScrH * 0.03)
dLabel:SetText("Zone name")

local dName = dCanvas:Add("DPanel")
dName:Dock(TOP)
dName:DockMargin(0, 0, ZoneCreator.Padding3, ZoneCreator.Padding2)
dName:SetTall(iScrH * 0.03)
dName.Paint = nil

local dZoneTextEntry = dName:Add("ZoneCreator:TextEntry")
dZoneTextEntry:Dock(FILL)
dZoneTextEntry:DockMargin(0, 0, ZoneCreator.Padding2, 0)
dZoneTextEntry:SetWide(self:GetParent():GetParent():GetWide() * 0.5)
dZoneTextEntry:SetPlaceholderText("Enter zone name here")

local dRename = dName:Add("ZoneCreator:Button")
dRename:Dock(RIGHT)
dRename:SetText("Rename")
dRename:SetFAIcon("f02b", "TLib2.FA.6", true)

function PANEL:Init()
    self.lower_box = self:Add("DPanel")
    self.lower_box:Dock(BOTTOM)
    self.lower_box:SetTall(iScrH * 0.03)
    self.lower_box.Paint = nil

    self.text_entry = self.lower_box:Add("ZoneCreator:TextEntryEx")
    self.text_entry:Dock(FILL)
    self.text_entry:DockMargin(0, 0, ZoneCreator.Padding2, 0)
    self.text_entry:SetPlaceholderText("Enter zone name here")

    self.button = self.lower_box:Add("ZoneCreator:Button")
    self.button:Dock(RIGHT)
    self.button:SetText("Rename")
    self.button:SetFAIcon("f02b", "TLib2.FA.6", true)
end

function PANEL:SetTitle(sTitle)
    if not self.title or not self.title:IsValid() then
        self.title = self:Add("DLabel")
        self.title:Dock(TOP)
        self.title:DockMargin(0, 0, 0, 0)
        self.title:SetFont("TLib2.6")
        self.title:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
        self.title:SetTall(iScrH * 0.03)
        self.title.Paint = nil
    end

    self.title:SetText(sTitle)
    self:SizeToChildren(false, true)
end

function PANEL:DoClick()
end

vgui.Register("ZoneCreator:TextEntryEx", PANEL, "DPanel")