local PANEL = {}

local draw = draw

function PANEL:Init()
    local dPanel = self

    self.color = Color(23, 22, 88)
    self.alpha_bar = true

    self:SetTall(ScrH() * 0.02)
    self:SetText("")

    self.color_box = self:Add("DButton")
    self.color_box:Dock(LEFT)
    self.color_box:SetText("")

    function self.color_box:Paint(iW, iH)
        if self:IsHovered() or dPanel:IsHovered() or dPanel.color_mixer and dPanel.color_mixer:IsValid() then
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base4)
        else
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base3)
        end
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, dPanel.color)
    end

    function self.color_box:DoClick()
        dPanel:CreateColorMixer()
    end

    function self.color_box:OnRemove()
        if not dPanel.color_mixer or not dPanel.color_mixer:IsValid() then return end
        dPanel.color_mixer:Remove()
    end
end

function PANEL:CreateColorMixer()
    if self.color_mixer_bg and self.color_mixer_bg:IsValid() then
        self.color_mixer_bg:Remove()
    end

    local dPanel = self

    self.color_mixer_bg = vgui.Create("EditablePanel")
    self.color_mixer_bg:SetSize(ScrW(), ScrH())
    self.color_mixer_bg:MakePopup()
    self.color_mixer_bg.Paint = nil

    function self.color_mixer_bg:OnMousePressed()
        if (type(dPanel.OnColorMixerClose) == "function") then
            dPanel:OnColorMixerClose(dPanel:GetColor())
        end
        self:Remove()
    end

    self.color_mixer = self.color_mixer_bg:Add("DColorMixer")
    local dColorMixer = self.color_mixer

    dColorMixer:SetAlphaBar(self:GetAlphaBar())
    dColorMixer:SetPalette(false)
    dColorMixer:SetWangs(true)
    dColorMixer:SetSize(ScrH() * 0.26, ScrH() * 0.16)
    dColorMixer:SetColor(self.color)
    dColorMixer:DockPadding(ZoneCreator.Padding3, ZoneCreator.Padding3, ZoneCreator.Padding3, ZoneCreator.Padding3)

    dColorMixer.RGB:SetWidth(ScrH() * 0.02)
    dColorMixer.RGB:DockMargin(ZoneCreator.Padding3, 0, 0, 0)

    dColorMixer.Alpha:SetWidth(ScrH() * 0.02)
    dColorMixer.Alpha:DockMargin(ZoneCreator.Padding3, 0, 0, 0)

    dColorMixer.WangsPanel:DockMargin(ZoneCreator.Padding3, 0, 0, 0)

    function dColorMixer:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base2)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, ZoneCreator.Cfg.Colors.Base1)
    end

    function dColorMixer:ValueChanged(oColor)
        dPanel:SetColor(Color(oColor.r, oColor.g, oColor.b, oColor.a))
    end

    local tChilds = {dColorMixer.txtR, dColorMixer.txtG, dColorMixer.txtB, dColorMixer.txtA}
    for _, v in ipairs(tChilds) do
        v:SetFont("TLib2.7")
        v:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
        v:SetTall(ScrH() * 0.02)
        v:SetDrawLanguageID(false)
        function v:Paint(iW, iH)
            draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base0)
            self:DrawTextEntryText(self.m_colText, ZoneCreator.Cfg.Colors.Base3, ZoneCreator.Cfg.Colors.Base4)
        end
    end

    local iX, iY = self.color_box:LocalToScreen(0, 0)
    dColorMixer:SetPos(iX + self.color_box:GetWide() + ZoneCreator.Padding2, iY)

    if self:GetDefaultColor() then
        local dReset = dColorMixer.WangsPanel:Add("ZoneCreator:Button")
        dReset:SetTall(ScrH() * 0.024)
        dReset:Dock(BOTTOM)
        dReset:DockMargin(0, ZoneCreator.Padding3, 0, 0)
        dReset:SetText("")
        dReset:SetFAIcon("f2ea", "TLib2.FA.7", true, true)
        dReset:SetBackgroundColor(ZoneCreator.Cfg.Colors.Base0)

        function dReset:DoClick()
            dPanel:SetColor(dPanel:GetDefaultColor())
        end
    end
end

function PANEL:GetColor()
    return self.color
end

function PANEL:SetColor(oColor)
    if not IsColor(oColor) then return end

    self.color = Color(
        oColor.r,
        oColor.g,
        oColor.b,
        oColor.a
    )

    if (type(self.OnColorChange) == "function") then
        self:OnColorChange(oColor)
    end

    self:InvalidateLayout()
end

function PANEL:SetLabel(sText)
    self.text = sText

    self.label = self:Add("DLabel")
    self.label:Dock(FILL)
    self.label:DockMargin(ZoneCreator.Padding2, 0, 0, 0)
    self.label:SetFont("TLib2.6")
    self.label:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
    self.label:SetText(sText)

    self:InvalidateLayout()
end

function PANEL:GetText()
    return self.text
end

function PANEL:GetAlphaBar()
    return self.alpha_bar
end

function PANEL:SetAlphaBar(bAlphaBar)
    self.alpha_bar = tobool(bAlphaBar)
end

function PANEL:GetDefaultColor()
    return self.default_color
end

function PANEL:SetDefaultColor(oColor)
    if not IsColor(oColor) then
        self.default_color = nil
        return
    end
    self.default_color = oColor
end

function PANEL:PerformLayout(iW, iH)
    self.color_box:SetSize(iH, iH)

    if self.color_mixer and self.color_mixer:IsValid() then
        local iX, iY = self.color_box:LocalToScreen(0, 0)
        self.color_mixer:SetPos(iX + self.color_box:GetWide() + ZoneCreator.Padding2, iY)
    end
end

function PANEL:DoClick()
    self:CreateColorMixer()
end

function PANEL:Paint(iW, iH)
end

vgui.Register("ZoneCreator:ColorInput", PANEL, "DButton")