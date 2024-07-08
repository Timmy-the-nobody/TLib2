local PANEL = {}

local draw = draw
local surface = surface
local render = render

local sZoneFA = TLib2.GetFAIcon("f1b2")
local matGradU = Material("vgui/gradient-u")
local matGradD = Material("vgui/gradient-d")
local matGradL = Material("vgui/gradient-l")
local matGradR = Material("vgui/gradient-r")
local tColLowAlpha = Color(255, 255, 255, 5)
local tGreen = Color(0, 255, 0)
local tGreen2 = Color(0, 255, 0, 30)
local tVisibleCol = ZoneCreator.Cfg.Colors.Warn
local tVisibleColBg = ZoneCreator.ColorManip(ZoneCreator.Cfg.Colors.Warn, 0.8, 0.3)
local tRTCol = ColorAlpha(color_white, 5)
local tRTColHover = ColorAlpha(color_white, 35)

local tZoneRTs = {}
local tZoneMats = {}

local tCardsMap = {}
local tCardButtons = {
    {
        label = "zonecard.edit",
        fa_icon = TLib2.GetFAIcon("f013"),
        on_click = function(self, oZone)
            ZoneCreator.Menu:SelectTab("ZoneCreator:EditZone"):SetZone(oZone)
        end
    },
    {
        label = "zonecard.teleport",
        require_map = true,
        fa_icon = TLib2.GetFAIcon("f59f"),
        on_click = function(self, oZone)
            net.Start("ZoneCreator")
                net.WriteUInt(5, 4)
                net.WriteUInt(oZone:GetID(), 16)
            net.SendToServer()
        end
    },
    {
        label = "zonecard.vis_on",
        is_vis_button = true,
        require_map = true,
        fa_icon = TLib2.GetFAIcon("f070"),
        on_click = function(self, oZone)
            oZone:SetDrawDebug(not oZone:GetDrawDebug())
        end
    }
}
function PANEL:Init()
    self:SetText("")
    self:DockPadding(ZoneCreator.Padding2, ZoneCreator.Padding2, ZoneCreator.Padding2, ZoneCreator.Padding2)

    self.lerp_hover = 0
    self.outline_color = ZoneCreator.Cfg.Colors.Base2

    local iScrH = ScrH()
    local dCard = self

    -- Top
    local dTop = self:Add("DPanel")
    dTop:Dock(TOP)
    dTop:SetText("")
    dTop:DockMargin(0, 0, 0, ZoneCreator.Padding3)
    dTop:SetTall(iScrH * 0.02)
    dTop:SetMouseInputEnabled(false)
    dTop.Paint = nil

    self.zone_label = dTop:Add("DLabel")
    self.zone_label:Dock(LEFT)
    self.zone_label:SetFont("TLib2.6")
    self.zone_label:SetText("")
    self.zone_label:SetTextColor(ZoneCreator.Cfg.Colors.Base4)
    self.zone_label:SetContentAlignment(4)
    self.zone_label:SetTextInset(iScrH * 0.025, 0)
    function self.zone_label:Paint(iW, iH)
        draw.SimpleText(sZoneFA, "TLib2.FA.5", 0, (iH * 0.5), ZoneCreator.Cfg.Colors.Accent, 0, 1)
    end

    self.zone_map = dTop:Add("DLabel")
    self.zone_map:Dock(RIGHT)
    self.zone_map:SetFont("TLib2.7")
    self.zone_map:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    self.zone_map:SetContentAlignment(5)
    self.zone_map:DockMargin(ZoneCreator.Padding2, 0, 0, 0)
    self.zone_map:SetText("")
    function self.zone_map:Paint(iW, iH)
        draw.RoundedBox((iH * 0.5), 0, 0, iW, iH, ZoneCreator.Cfg.Colors.Base2)
        draw.RoundedBox((iH * 0.5) - 2, 1, 1, (iW - 2), (iH - 2), ZoneCreator.Cfg.Colors.Base1)
    end

    self.creation_date = self:Add("DLabel")
    self.creation_date:Dock(TOP)
    self.creation_date:SetFont("TLib2.7")
    self.creation_date:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    self.creation_date:SetText("")
    self.creation_date:SetMouseInputEnabled(false)

    -- Created by
    local dCreatedByBox = self:Add("DButton")
    dCreatedByBox:Dock(TOP)
    dCreatedByBox:SetText("")
    dCreatedByBox.Paint = nil
    dCreatedByBox.DoClick = function() dCard:DoClick() end

    local dCreatedBySuffix = dCreatedByBox:Add("DLabel")
    dCreatedBySuffix:Dock(LEFT)
    dCreatedBySuffix:SetFont("TLib2.7")
    dCreatedBySuffix:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    dCreatedBySuffix:SetText(ZoneCreator:I18n("zonecard.created_by")..":")
    dCreatedBySuffix:SizeToContents()
    dCreatedBySuffix.Paint = nil
    dCreatedBySuffix.DoClick = function() dCard:DoClick() end

    self.created_by_name = dCreatedByBox:Add("DButton")
    self.created_by_name:Dock(LEFT)
    self.created_by_name:DockMargin(ZoneCreator.Padding3, 0, 0, 0)
    self.created_by_name:SetFont("TLib2.7")
    self.created_by_name:SetTextColor(ZoneCreator.Cfg.Colors.Accent)
    self.created_by_name:SetText("")
    self.created_by_name.lerp_hover = 0

    function self.created_by_name:Paint(iW, iH)
        if not self:IsHovered() then return end
        surface.SetDrawColor(ZoneCreator.Cfg.Colors.Accent)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end

    self.volume = self:Add("DLabel")
    self.volume:Dock(TOP)
    self.volume:SetFont("TLib2.7")
    self.volume:SetTextColor(ZoneCreator.Cfg.Colors.Base3)
    self.volume:SetText("")
    self.volume:SizeToContents()
    self.volume:SetMouseInputEnabled(false)
end

function PANEL:GetZone()
    return self.zone
end

function PANEL:GenerateZoneMaterial()
    local oZone = self:GetZone()
    if not oZone then return end

    local iZoneID = oZone:GetID()
    if tZoneMats[iZoneID] then
        return tZoneMats[iZoneID]
    end

    if not tZoneRTs[iZoneID] then
        tZoneRTs[iZoneID] = GetRenderTarget("zc_card_rt_"..iZoneID, 512, 512)
    end

    local iX, iY = self:LocalToScreen(0, 0)
    local tBMin, tBMax = oZone:GetBounds()
    local tStart, tEnd
    if (tBMin.z > tBMax.z) then
        tStart, tEnd = tBMax, (tBMin + Vector(0, 0, 10))
    else
        tStart, tEnd = tBMin, (tBMax + Vector(0, 0, 10))
    end

    render.PushRenderTarget(tZoneRTs[iZoneID])
        render.Clear(0, 0, 0, 0, true, true)
        render.SetShadowsDisabled(true)

        local bOldClipping = DisableClipping(false)

        render.RenderView({
            origin = tEnd,
            angles = (tStart - tEnd):Angle(),
            x = iX,
            y = iY,
            w = 512,
            h = 512,
            bloomtone = false,
            drawmonitors = false,
            drawviewmodel = false
        })

        render.SetShadowsDisabled(false)

        local tStart, tEnd = oZone:GetBounds()

        DisableClipping(bOldClipping)

        cam.Start3D()
            render.SetColorMaterial()
            render.DrawBox(vector_origin, angle_zero, tStart, tEnd, tGreen2)
            render.DrawWireframeBox(vector_origin, angle_zero, tStart, tEnd, tGreen, true)
        cam.End3D()
    render.PopRenderTarget()

    tZoneMats[iZoneID] = CreateMaterial("zc_rt_mat_"..iZoneID, "UnlitGeneric", {
        ["$basetexture"] = tZoneRTs[iZoneID]:GetName(),
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1
    })

    return tZoneMats[iZoneID]
end

function PANEL:SetZone(oZone)
    if (getmetatable(oZone) ~= ZCZone) then return end

    local iScrH = ScrH()
    local dCard = self
    local iZoneID = oZone:GetID()

    tCardsMap[oZone] = self

    self.zone = oZone

    self.zone_label:SetText(oZone:GetLabel())
    self.zone_label:SizeToContentsX()

    self.zone_map:SetText(oZone:GetMap())
    self.zone_map:SizeToContentsX()
    self.zone_map:SetWide(self.zone_map:GetWide() + (ZoneCreator.Padding3 * 2))

    self.creation_date:SetText(ZoneCreator:I18n("zonecard.added_on")..": "..os.date(ZoneCreator:I18n("zonecard.added_on_format"), oZone:GetCreationDate()))
    self.creation_date:SizeToContents()

    -- Created by
    local sCreatedBy = oZone:GetCreatedBy()
    self.created_by_name:SetText(sCreatedBy)

    function self.created_by_name:DoClick()
        gui.OpenURL("https://steamcommunity.com/profiles/"..sCreatedBy)
    end

    steamworks.RequestPlayerInfo(sCreatedBy, function(sName)
        self.created_by_name:SetText(sName)
        self.created_by_name:SizeToContents()
    end)

    -- Volume
    local sVolume = string.Comma(math.Round(oZone:GetVolume()))
    self.volume:SetText(ZoneCreator:I18n("zonecard.volume"):format(sVolume))
    self.volume:SizeToContents()

    -- Config button
    self.buttons_box = self:Add("DPanel")
    self.buttons_box:Dock(BOTTOM)
    self.buttons_box:SetTall(iScrH * 0.03)
    self.buttons_box:SetCursor("hand")
    self.buttons_box.Paint = nil

    function self.buttons_box:OnMousePressed()
        dCard:DoClick()
    end

    local sZoneMap = oZone:GetMap()
    local sCurMap = game.GetMap()

    for i = 1, #tCardButtons do
        local tBtn = tCardButtons[i]

        local dButton = self.buttons_box:Add("DButton")
        dButton:Dock(RIGHT)
        dButton:SetWide(iScrH * 0.03)
        dButton:SetText("")
        dButton.bg_lerp = 0
        dButton.fa_icon = tBtn.fa_icon
        dButton.label = ZoneCreator:I18n(tBtn.label)

        if tBtn.require_map and (sZoneMap ~= sCurMap) then
            dButton:SetMouseInputEnabled(false)
            dButton:SetAlpha(50)
        end

        if tBtn.is_vis_button then
            self.UpdateVisButton = function(_)
                if oZone:GetDrawDebug() then
                    dButton.fa_icon = TLib2.GetFAIcon("f070")
                    dButton.fa_icon_col = tVisibleCol
                    dButton.fa_icon_bg = tVisibleColBg
                    dButton.label = ZoneCreator:I18n("zonecard.vis_off")
                else
                    dButton.fa_icon = TLib2.GetFAIcon("f06e")
                    dButton.fa_icon_col = nil
                    dButton.fa_icon_bg = nil
                    dButton.label = ZoneCreator:I18n("zonecard.vis_on")
                end
                if dButton.tooltip and dButton.tooltip:IsValid() then
                    dButton.tooltip:SetText(dButton.label)
                end
            end
            self:UpdateVisButton()
        end

        function dButton:Paint(iW, iH)
            if self:IsHovered() then
                self.bg_lerp = 1

                draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self.fa_icon_bg or ZoneCreator.Cfg.Colors.Accent)
                draw.SimpleText(self.fa_icon, "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self.fa_icon_col or ZoneCreator.Cfg.Colors.Base4, 1, 1)
            else
                if (self.bg_lerp > 0.001) then
                    self.bg_lerp = Lerp(RealFrameTime() * 8, self.bg_lerp, 0)

                    local iBoxW, iBoxH = (iW * self.bg_lerp), (iH * self.bg_lerp)
                    draw.RoundedBox(TLib2.BorderRadius, (iW - iBoxW) * 0.5, (iH - iBoxH) * 0.5, iBoxW, iBoxH, ZoneCreator.Cfg.Colors.Base3)
                end

                draw.SimpleText(self.fa_icon, "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self.fa_icon_col or ZoneCreator.Cfg.Colors.Base3, 1, 1)
            end
        end

        function dButton:DoClick()
            if (type(tBtn.on_click) ~= "function") then return end
            tBtn.on_click(self, oZone)
        end

        function dButton:OnCursorEntered()
            if self.tooltip and self.tooltip:IsValid() then return end

            self.tooltip = vgui.Create("ZoneCreator:Tooltip")
            self.tooltip:SetAnchor(self)
            self.tooltip:SetText(dButton.label)
        end

        function dButton:OnCursorExited()
            if not self.tooltip or not self.tooltip:IsValid() then return end

            self.tooltip:Remove()
            self.tooltip = nil
        end
    end

    -- Zone RT
    if (oZone:GetMap() ~= game.GetMap()) then return end
    self.rt_mat = self:GenerateZoneMaterial()
end

function PANEL:IsHovered()
    local dHovered = vgui.GetHoveredPanel()
    if not dHovered then return false end
    if (dHovered == self) then return true end

    return self:IsChildHovered(false)
end

function PANEL:Paint(iW, iH)
    local bHovered = self:IsHovered()

    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, bHovered and ZoneCreator.Cfg.Colors.Base3 or self.outline_color)
    draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, (iW - 2), (iH - 2), ZoneCreator.Cfg.Colors.Base0)

    if self.volume_string then
        draw.SimpleText(self.volume_string, "TLib2.7", iW * 0.5, iH * 0.5, ZoneCreator.Cfg.Colors.Base4, 1, 4)
    end

    if not self.rt_mat then return end

    ZoneCreator.QuickMask(
        function()
            local iRad = (TLib2.BorderRadius * 0.5)
            draw.RoundedBox(iRad, iRad, iRad, iW - (iRad * 2), iH - (iRad * 2), color_white)    
        end,
        function()
            local iMax = math.max(iW, iH) * (bHovered and 1.2 or 1)

            surface.SetDrawColor(bHovered and tRTColHover or tRTCol)
            surface.SetMaterial(self.rt_mat)
            surface.DrawTexturedRect((iW - iMax) * 0.5, (iH - iMax) * 0.5, iMax, iMax)
    
            surface.SetDrawColor(ZoneCreator.Cfg.Colors.Base0)
            surface.SetMaterial(matGradU)
            surface.DrawTexturedRect(0, 0, iW, (iH * 0.5))
    
            surface.SetMaterial(matGradD)
            surface.DrawTexturedRect(0, iH - (iH * 0.5), iW, (iH * 0.5))
    
            surface.SetMaterial(matGradL)
            surface.DrawTexturedRect(0, 0, (iH * 0.5), iH)
    
            surface.SetMaterial(matGradR)
            surface.DrawTexturedRect(iW - (iH * 0.5), 0, (iH * 0.5), iH)
        end
    )
end

hook.Add("ZoneCreator:OnZoneDrawDebug", "ZoneCreator:ZoneCard:OnZoneDrawDebug", function(oZone, bDraw)
    if not tCardsMap[oZone] or not tCardsMap[oZone].UpdateVisButton then return end
    tCardsMap[oZone]:UpdateVisButton()
end)

vgui.Register("ZoneCreator:ZoneCard", PANEL, "DButton")