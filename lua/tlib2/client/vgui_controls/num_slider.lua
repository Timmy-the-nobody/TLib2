local draw = draw
local math = math
local input = input

---@class TLib2:NumSlider : DNumSlider
local PANEL = {}

function PANEL:Init()
    self:SetTall(TLib2.VGUIControlH2)

    if self.TextArea and self.TextArea:IsValid() then self.TextArea:Remove() end
    self.TextArea = self:Add("TLib2:TextEntry")
    self.TextArea:SetFont("TLib2.6")
    self.TextArea:SetTextColor(TLib2.Colors.Base4)
	self.TextArea:Dock(RIGHT)
    self.TextArea:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.TextArea:SetWide(ScrH() * 0.06)
	self.TextArea:SetNumeric(true)
    self.TextArea:SetButtonVisible(false)
	self.TextArea.OnChange = function()
        self:SetValue(self.TextArea:GetText())

        if self.SingleValueChanged then
            self:SingleValueChanged(self:GetValue())
        end
    end

    if self.Slider and self.Slider:IsValid() then self.Slider:Remove() end
    self.Slider = self:Add("TLib2:Slider")
    self.Slider:Dock(FILL)
	self.Slider.TranslateValues = function(_, iX, iY)
        return self:TranslateSliderValues(iX, iY)
    end

    local fnOldSliderSetDragging = self.Slider.SetDragging
    self.Slider.SetDragging = function(_, bDragging)
        fnOldSliderSetDragging(self.Slider, bDragging)

        if not bDragging and self.SingleValueChanged then
            self:SingleValueChanged(self:GetValue())
        end
    end

    local fnOldSliderMoved = self.Slider.OnCursorMoved
    self.Slider.OnCursorMoved = function(d, iX, iY)
        fnOldSliderMoved(d, iX, iY)

        input.SetCursorPos(d:LocalToScreen(
            math.Clamp(iX, 0, d:GetWide()),
            math.Clamp(iY, 0, d:GetTall()))
        )
    end

	self.Label:SetFont("TLib2.6")
    self.Label:SetTextColor(TLib2.Colors.Base4)
    self.Label:Dock(LEFT)

    if self.Scratch and self.Scratch:IsValid() then self.Scratch:Remove() end
    self.Scratch = self:Add("TLib2:NumScratch")
	self.Scratch:SetImageVisible(false)
	self.Scratch:Dock(LEFT)
    self.Scratch:DockMargin(0, 0, TLib2.Padding4, 0)
	self.Scratch.OnValueChanged = function()
        self:ValueChanged(self.Scratch:GetFloatValue())
    end

    local fnOldMouseReleased = self.Scratch.OnMouseReleased
    self.Scratch.OnMouseReleased = function(_, iKey)
        fnOldMouseReleased(self.Scratch, iKey)

        if self.SingleValueChanged then
            self:SingleValueChanged(self:GetValue())
        end
    end

    function self.Scratch:Paint(iW, iH)
        local bActive = self:GetActive()

        draw.RoundedBox(TLib2.BorderRadius, (iW - iH), 0, iH, iH, bActive and TLib2.Colors.Accent or TLib2.Colors.Base2)
        draw.RoundedBox(TLib2.BorderRadius - 2, (iW - iH) + 1, 1, iH - 2, iH - 2, TLib2.Colors.Base1)

        if bActive then
            TLib2.DrawFAIcon("f05b", "TLib2.FA.7", (iW - (iH * 0.5)), (iH * 0.5), TLib2.Colors.Accent, 1, 1)
        else
            TLib2.DrawFAIcon("f05b", "TLib2.FA.7", (iW - (iH * 0.5)), (iH * 0.5), self:IsHovered() and TLib2.Colors.Base4 or TLib2.Colors.Base3, 1, 1)
        end
    end
end

function PANEL:PerformLayout(iW, iH)
    if self.Label and self.Label:IsValid() then
        if (self.Label:GetText() == "") then
            if self.Label:IsVisible() then
                self.Label:SetVisible(false)
            end
        else
            if not self.Label:IsVisible() then
                self.Label:SetVisible(true)
            end
            if (self.Label:GetWide() ~= (iW * 0.25)) then
                self.Label:SetWide(iW * 0.25)
            end
        end
    end

    if self.Scratch and self.Scratch:IsValid() and (self.Scratch:GetWide() ~= iH) then
        self.Scratch:SetWide(iH)
    end
end

vgui.Register("TLib2:NumSlider", PANEL, "DNumSlider")