local PANEL = {}

local draw = draw
local surface = surface
local TLib2 = TLib2

local tNotifTypes = {
    [NOTIFY_GENERIC] = {
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/confirmation.ogg")
        end
    },
    [NOTIFY_ERROR] = {
        color = TLib2.Colors.Warn,
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/error.ogg")
        end
    },
    [NOTIFY_UNDO] = {
        color = TLib2.Colors.Accent,
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    },
    [NOTIFY_HINT] = {
        color = Color(243, 156, 18),
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    },
    [NOTIFY_CLEANUP] = {
        color = Color(243, 156, 18),
        on_click = function(dButton)
            TLib2.PlayUISound("tlib2/drop.ogg")
        end
    }
}

function PANEL:Init()
    self:SetAnimationEnabled(false)
    self:SetText("")
    self:SetTall(TLib2.VGUIControlH2)
    self:SetFont("TLib2.6")
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursor("hand")

    self.bg_color = TLib2.Colors.Base1
    self.bg_color_hover = TLib2.Colors.Base2

    self.outline_color = TLib2.Colors.Base2
    self.outline_color_hover = TLib2.Colors.Base3
end

---`🔸 Client`<br>
---Returns the button's background color
---@return Color @The color
function PANEL:GetBackgroundColor()
    return self.bg_color
end

---`🔸 Client`<br>
---Sets the button's background color
---@param oCol Color @The color to use
function PANEL:SetBackgroundColor(oCol)
    self.bg_color = oCol
end

---`🔸 Client`<br>
---Returns the button's outline color
---@return Color @The color
function PANEL:GetOutlineColor()
    return self.outline_color
end

---`🔸 Client`<br>
---Sets the button's outline color
---@param oCol Color @The color to use
function PANEL:SetOutlineColor(oCol)
    self.outline_color = oCol
end

---`🔸 Client`<br>
---Returns the button's background hover color
---@return Color @The color
function PANEL:GetBackgroundHoverColor()
    return self.bg_color_hover
end

---`🔸 Client`<br>
---Returns the button's background hover color
---@return Color @The color to use
function PANEL:SetBackgroundHoverColor(oCol)
    self.bg_color_hover = oCol
end

---`🔸 Client`<br>
---Returns the button's outline hover color
---@return Color @The color
function PANEL:GetOutlineHoverColor()
    return self.outline_color_hover
end

---`🔸 Client`<br>
---Sets the button's outline hover color
---@param oCol Color @The color to use
function PANEL:SetOutlineHoverColor(oCol)
    self.outline_color_hover = oCol
end

---`🔸 Client`<br>
---Sets the button's color theme (handles background and outline colors)
---@param oCol Color @The color to use
function PANEL:SetColorTheme(oCol)
    if not IsColor(oCol) then return end

    self:SetColor(oCol)
    self:SetBackgroundColor(TLib2.ColorManip(oCol, 0.5, 0.2))
    self:SetOutlineColor(oCol)

    self:SetBackgroundHoverColor(TLib2.ColorManip(oCol, 0.5, 0.5))
    self:SetOutlineHoverColor(TLib2.ColorManip(oCol, 0.5, 0.5))
end

---`🔸 Client`<br>
---Sets the button's flat color theme (handles background and outline colors)
---@param oCol Color @The color to use
function PANEL:SetFlatColorTheme(oCol)
    if not IsColor(oCol) then return end

    self:SetBackgroundColor(oCol)
    self:SetOutlineColor(oCol)

    self:SetBackgroundHoverColor(TLib2.ColorManip(oCol, 0.9, 0.9))
    self:SetOutlineHoverColor(TLib2.ColorManip(oCol, 0.9, 0.9))
end

---`🔸 Client`<br>
---Sets the button's FA icon
---@param sIcon string @The icon to use
---@param sFont string @The font to use
---@param bAdjustWidth boolean @Whether to adjust the width of the button
---@param bAlignRight boolean @Whether to align the button to the right
function PANEL:SetFAIcon(sIcon, sFont, bAdjustWidth, bAlignRight)
    if not sIcon then
        if self.fa_icon_pnl and self.fa_icon_pnl:IsValid() then
            self.fa_icon_pnl:Remove()
        end
        return
    end

    sFont = sFont or "TLib2.FA.7"

    surface.SetFont(sFont)
    local iFAIconW, _ = surface.GetTextSize(TLib2.GetFAIcon(sIcon))
    
    self:InvalidateLayout(true)
    local iMargin = (self:GetTall() * 0.25)

    self:SetContentAlignment(4)
    self:SetTextInset(bAlignRight and iMargin or (iFAIconW + (iMargin * 2)), 0)

    self.fa_icon_pnl = self.fa_icon_pnl or self:Add("Panel")
    self.fa_icon_pnl:Dock(bAlignRight and RIGHT or LEFT)
    self.fa_icon_pnl:DockMargin(iMargin, 0, iMargin, 0)
    self.fa_icon_pnl:SetWide(iFAIconW)
    self.fa_icon_pnl:SetMouseInputEnabled(false)
    self.fa_icon_pnl.fa_icon = sIcon
    self.fa_icon_pnl.Paint = function(_, iW, iH)
        TLib2.DrawFAIcon(self.fa_icon_pnl.fa_icon, sFont or "TLib2.FA.7", (iW * 0.5), (iH * 0.5), self:GetTextColor(), 1, 1)
    end

    if bAdjustWidth then
        self:AdjustWidth()
    end
end

---`🔸 Client`<br>
---Adjusts the width of the button based on the text it contains and/or FA icon
function PANEL:AdjustWidth()
    local iTextW, _ = self:GetTextSize()
    local iMargin = (self:GetTall() * 0.25)

    self:SetWide(iTextW + ((self.fa_icon_pnl and self.fa_icon_pnl:IsValid()) and self.fa_icon_pnl:GetWide() or 0) + (iMargin * (iTextW == 0 and 2 or 3)))
end

---`🔸 Client`<br>
---Sets whether the button is clickable
---@param bClickable boolean @Whether the button is clickable
function PANEL:SetClickable(bClickable)
    if bClickable then
        self:SetEnabled(true)
        self:SetMouseInputEnabled(true)
        self:SetAlpha(255)
    else
        self:SetEnabled(false)
        self:SetMouseInputEnabled(false)
        self:SetAlpha(100)
    end
end

---`🔸 Client`<br>
---Makes the button display a notification
---@param iType number @The type of notification
---@param sText? string @The text of the notification
---@param bAdjustWidth? boolean @Whether to adjust the width of the button
---@param fDuration? number @The duration of the notification
---@param fnOnFinish? function @The function to be called when the notification finishes
function PANEL:DoNotify(iType, sText, bAdjustWidth, fDuration, fnOnFinish)
    if self.__notifinfo then return end
    if not tNotifTypes[iType] then return end

    self.__notifinfo = {
        bg_color = self:GetBackgroundColor(),
        bg_color_hover = self:GetBackgroundHoverColor(),
        outline_color = self:GetOutlineColor(),
        outline_color_hover = self:GetOutlineHoverColor(),
        width = self:GetWide(),
        text = self:GetText()
    }

    self:SetText(sText or "")

    if tNotifTypes[iType].color then
        self:SetFlatColorTheme(tNotifTypes[iType].color)
    end

    if tNotifTypes[iType].on_click then
        tNotifTypes[iType].on_click(self)
    end


    if bAdjustWidth then
        self:AdjustWidth()
    end

    timer.Simple((type(fDuration) == "number") and fDuration or 2, function()
        if not IsValid(self) then return end

        self:SetBackgroundColor(self.__notifinfo.bg_color)
        self:SetBackgroundHoverColor(self.__notifinfo.bg_color_hover)
        self:SetOutlineColor(self.__notifinfo.outline_color)
        self:SetOutlineHoverColor(self.__notifinfo.outline_color_hover)
        self:SetText(self.__notifinfo.text)
        
        if bAdjustWidth and (self:GetWide() ~= self.__notifinfo.width) then
            self:SetWide(self.__notifinfo.width)
        end
        
        self.__notifinfo = nil

        if (type(fnOnFinish) == "function") then
            fnOnFinish()
        end
    end)
end

function PANEL:Paint(iW, iH)
    local bOutlineHover = (self.outline_color_hover and bHovered) and true or false

    if self.outline_color or bOutlineHover then
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, bOutlineHover and self.outline_color_hover or self.outline_color)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, (iW - 2), (iH - 2), (self.bg_color_hover and self:IsHovered()) and self.bg_color_hover or self.bg_color)
    else
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, (self.bg_color_hover and self:IsHovered()) and self.bg_color_hover or self.bg_color)
    end
end

function PANEL:DoClickInternal(iButton)
    TLib2.PlayUISound("tlib2/click.ogg")
end

vgui.Register("TLib2:Button", PANEL, "DButton")