local PANEL = {}

local draw = draw
local surface = surface

local matGradR = Material("vgui/gradient-r")

function PANEL:Init()
    local dTextEntry = self

    self.is_empty = (self:GetValue() == "")
    self.fa_icon = "f002"
    self.outline_color = TLib2.Colors.Base2
    self.outline_color_editing = TLib2.Colors.Accent
   
    self:SetTall(TLib2.VGUIControlH2)
    self:SetFont("TLib2.6")
    self:SetPlaceholderColor(TLib2.Colors.Base2)
    self:SetDrawLanguageID(false)
    self:SetPaintBackground(false)
    self:SetUpdateOnType(true)
    self:SetTextColor(TLib2.Colors.Base4)
    self:SetCursorColor(TLib2.Colors.Base3)
    self:SetHighlightColor(TLib2.Colors.Base2)

    self.btn_right = self:Add("TLib2:Button")
    self.btn_right:Dock(RIGHT)
    self.btn_right:SetText("")
    self.btn_right:SetMouseInputEnabled(false)
    self.btn_right.active_fa_icon = self.fa_icon

    local iPadding = math.ceil(TLib2.BorderRadius * 0.5)
    function self.btn_right:Paint(iW, iH)
        if not dTextEntry.is_empty then
            surface.SetDrawColor(TLib2.Colors.Base1)
            surface.SetMaterial(matGradR)
            surface.DrawTexturedRect(0, (iPadding * 0.5), (iW - iPadding), (iH - iPadding))
            surface.DrawTexturedRect(0, (iPadding * 0.5), (iW - iPadding), (iH - iPadding))
        end

        if dTextEntry.is_empty then
            TLib2.DrawFAIcon(self.active_fa_icon, "TLib2.FA.7", iW - (iH * 0.5), (iH * 0.5), TLib2.Colors.Base2, 1, 1)
        else
            TLib2.DrawFAIcon(self.active_fa_icon, "TLib2.FA.7", iW - (iH * 0.5) + 1, (iH * 0.5) + 1, TLib2.Colors.Base2, 1, 1)
            TLib2.DrawFAIcon(self.active_fa_icon, "TLib2.FA.7", iW - (iH * 0.5), (iH * 0.5), self:IsHovered() and TLib2.Colors.Warn or TLib2.Colors.Base3, 1, 1)
        end
    end

    function self.btn_right:DoClick()
        if dTextEntry.is_empty then return end

        dTextEntry:SetValue("")
        dTextEntry:OnChange()
    end
end

---`🔸 Client`<br>
---Returns the text entry's FA icon
---@return string? @The text entry's FA icon, or nil if not set
function PANEL:GetFAIcon()
    return self.fa_icon
end

---`🔸 Client`<br>
---Sets the text entry's FA icon
---@param sFAIcon string @The text entry's FA icon
function PANEL:SetFAIcon(sFAIcon)
    self.fa_icon = sFAIcon
    self:__HandleStyle()
end

---`🔸 Client`<br>
---Used internally to handle style updates, you should not need to call this
function PANEL:__HandleStyle()
    local sVal = self:GetValue() or ""
    if (sVal == "") then
        self.btn_right.active_fa_icon = self.fa_icon
        self.btn_right:SetMouseInputEnabled(false)
        self.is_empty = true
    else
        self.btn_right.active_fa_icon = "f00d"
        self.btn_right:SetMouseInputEnabled(true)
        self.is_empty = false
    end
end

---`🔸 Client`<br>
---Sets the visibility of the button
---@param bVisible boolean @Whether the button should be visible
function PANEL:SetButtonVisible(bVisible)
    self.btn_right:SetVisible(bVisible)
end

function PANEL:OnChange()
    self:__HandleStyle()

    local dParent = self:GetParent()
    while dParent do
        if not dParent:IsValid() then break end

        if dParent.ScrollToChild then
            dParent:ScrollToChild(self) 
            break
        end

        dParent = dParent:GetParent()
    end
end

function PANEL:OnKeyCode(iKey)
    if self.__next_playable_sound and (CurTime() < self.__next_playable_sound) then
        return
    end
    
    TLib2.PlayUISound("tlib2/typing.ogg", 0.25, (iKey == KEY_BACKSPACE) and 90 or math.Rand(95, 105))
    self.__next_playable_sound = (CurTime() + 0.05)
end

function PANEL:IsPlaceholderVisible()
    if not self:HasFocus() and (self:GetText() == "") and self.m_txtPlaceholder then
        return true
    end
end

function PANEL:PerformLayout(iW, iH)
    if not self.btn_right or not self.btn_right:IsValid() then return end

    self.btn_right:SetWide(iH)
end

function PANEL:Paint(iW, iH)
    draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, self:IsEditing() and self.outline_color_editing or self.outline_color)
    draw.RoundedBox((TLib2.BorderRadius - 2), 1, 1, (iW - 2), (iH - 2), TLib2.Colors.Base0)

    if self:IsPlaceholderVisible() then
        draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), TLib2.Padding4, (iH * 0.5), self:GetPlaceholderColor(), 0, 1)
    else
        self:DrawTextEntryText(self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor())
    end
end

vgui.Register("TLib2:TextEntry", PANEL, "DTextEntry")