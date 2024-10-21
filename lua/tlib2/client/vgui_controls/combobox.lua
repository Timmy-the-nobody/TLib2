local PANEL = {}

local draw = draw
local surface = surface

function PANEL:Init()
    self:SetTall(TLib2.VGUIControlH2)

    self.options = {}
    self.multiple_select = false
    self.selected_options = {}
    self.title = ""
    self.menu_max_height = (ScrH() * 0.32)

    self:SetFAIcon("f0d7", "TLib2.FA.8", true, true)
end

function PANEL:DoClickInternal()
    TLib2.PlayUISound("tlib2/click.ogg")

    self:OpenMenu()
end

function PANEL:OnRemove()
    if not self.screen_canvas or not self.screen_canvas:IsValid() then return end
    self.screen_canvas:Remove()
end

---`🔸 Client`<br>
---Returns whether the combobox allows multiple options to be selected
---@return boolean
function PANEL:GetMultiple()
    return self.multiple_select
end

---`🔸 Client`<br>
---Sets whether the combobox allows multiple options to be selected
---@param bMultiple boolean
function PANEL:SetMultiple(bMultiple)
    self.multiple_select = tobool(bMultiple)

    if not self.multiple_select then
        for iOption, _ in pairs(self:GetSelectedOptions()) do
            self.selected_options = {[iFirstSelected] = true}
            break
        end
    end
end

---`🔸 Client`<br>
---Closes the menu
function PANEL:CloseMenu()
    if not self.screen_canvas or not self.screen_canvas:IsValid() then return end
    self.screen_canvas:Remove()
end

---`🔸 Client`<br>
---Returns the maximum height of the menu
---@return number
function PANEL:GetMenuMaxHeight()
    return self.menu_max_height
end

---`🔸 Client`<br>
---Sets the maximum height of the menu (when exceeded, the menu will be scrollable)
---@param iMaxH number
function PANEL:SetMenuMaxHeight(iMaxH)
    if (type(iMaxH) ~= "number") then return end

    self.menu_max_height = iMaxH
    self:InvalidateLayout(true)
end

---`🔸 Client`<br>
---Opens the menu
function PANEL:OpenMenu()
    if self.menu and self.menu:IsValid() then return end

    local dPanel = self

    self.screen_canvas = vgui.Create("Panel")
    self.screen_canvas:SetSize(ScrW(), ScrH())
    self.screen_canvas:MakePopup()
    self.screen_canvas:SetDrawOnTop(true)
    self.screen_canvas.Paint = nil
    function self.screen_canvas:OnMousePressed()
        dPanel:CloseMenu()
        TLib2.PlayUISound("tlib2/click.ogg")
    end

    self.menu = self.screen_canvas:Add("DPanel")
    self.menu:DockPadding(1, 1, 1, 1)
    function self.menu:Paint(iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base1)
    end

    self.menu.title = self.menu:Add("TLib2:Button")
    self.menu.title:Dock(TOP)
    self.menu.title:SetFont("TLib2.7")
    self.menu.title:SetTextColor(TLib2.Colors.Base3)
    self.menu.title:SetTextInset(TLib2.Padding3, 0)
    self.menu.title:SetContentAlignment(4)
    self.menu.title:SetText(self:GetTitle())
    function self.menu.title:Paint(iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base2)
        surface.DrawLine(0, (iH - 1), iW, (iH - 1))
    end

    local dMenuClose = self.menu.title:Add("DButton")
    dMenuClose:Dock(RIGHT)
    dMenuClose:SetText("")
    dMenuClose:SetSize(self.menu.title:GetTall(), self.menu.title:GetTall())
    function dMenuClose:Paint(iW, iH)
        TLib2.DrawFAIcon("f00d", "TLib2.FA.7", (iW * 0.5), (iH * 0.5), TLib2.Colors[self:IsHovered() and "Warn" or "Base3"], 1, 1)
    end
    function dMenuClose:DoClick()
        dPanel:CloseMenu()
    end

    self.menu.scroll = self.menu:Add("TLib2:Scroll")
    self.menu.scroll:Dock(FILL)
    self.menu.scroll:SetVBarMargin(0)
    self.menu.scroll:GetCanvas():DockPadding(TLib2.Padding4, TLib2.Padding4, TLib2.Padding4, TLib2.Padding4)
    self.menu.scroll.Paint = nil

    local tOptions = self:GetOptions()
    for i = 1, #tOptions do
        local dOption = self.menu.scroll:Add("TLib2:Button")
        dOption:SetText(tOptions[i].label)
        dOption:SetFont("TLib2.7")
        dOption:Dock(TOP)
        dOption:SetContentAlignment(4)
        dOption:SetTextInset((TLib2.Padding3 * 2) + (ScrH() * 0.015), 0)

        function dOption:Paint(iW, iH)
            if self:IsHovered() then
                draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
            end

            if not dPanel:IsOptionSelected(i) then return end
            TLib2.DrawFAIcon("f00c", "TLib2.FA.7", TLib2.Padding3, (iH * 0.5), TLib2.Colors.Base3, 0, 1)
        end

        function dOption:DoClick()
            dPanel:__OnClickOption(i, self)
            dPanel.menu.scroll:ScrollToChild(self)
        end

        function dOption:DoClickInternal()
            TLib2.PlayUISound("tlib2/select.ogg")
        end
    end

    self:InvalidateLayout(true)
end

---`🔸 Client`<br>
---Returns the combobox's title
---@return string @Title of the combobox
function PANEL:GetTitle(sTitle)
    return self.title
end

---`🔸 Client`<br>
---Sets the combobox's title
---@param sTitle string @Title of the combobox
function PANEL:SetTitle(sTitle)
    self.title = sTitle
end

---`🔸 Client`<br>
---Called when an option is selected
---@param iIndex number @Index of the option
---@param sLabel string @Label of the option
---@param xData any @Data of the option
function PANEL:OnSelect(iIndex, sLabel, xData)
end

---`🔸 Client`<br>
---Called when an option is unselected
---@param iIndex number @Index of the option
---@param sLabel string @Label of the option
---@param xData any @Data of the option
function PANEL:OnUnselect(iIndex, sLabel, xData)
end

---`🔸 Client`<br>
---Internal method called when an option is clicked
---@param iIndex number @Index of the option
function PANEL:__OnClickOption(iIndex)
    local tOption = self.options[iIndex]
    if not tOption then return end

    if self:GetMultiple() then
        self:SetSelectedOption(iIndex, not self:IsOptionSelected(iIndex))
    else
        self:SetSelectedOption(iIndex, true)
        self:CloseMenu()
    end
end

---`🔸 Client`<br>
---Checks if an option is selected
---@param iIndex number @Index of the option
---@return boolean @Whether the option is selected
function PANEL:IsOptionSelected(iIndex)
    return (self.selected_options[iIndex] == true)
end

---`🔸 Client`<br>
---Sets an option as selected/unselected
---@param iIndex number @Index of the option
---@param bSelected boolean @Whether the option is selected or not
---@param bSilent boolean @Whether the On[Select/Unselect] event should be fired
function PANEL:SetSelectedOption(iIndex, bSelected, bSilent)
    if not self.options[iIndex] then return end

    if bSelected then
        if self.selected_options[iIndex] then return end

        if not self:GetMultiple() then
            for i, _ in pairs(self.selected_options) do
                self.selected_options[i] = nil
                if not bSilent then
                    self:OnUnselect(i, self.options[i].label, self.options[i].data)
                end
            end
        end

        self.selected_options[iIndex] = true
        if not bSilent then
            self:OnSelect(iIndex, self.options[iIndex].label, self.options[iIndex].data)
        end
    else
        if not self.selected_options[iIndex] then return end

        self.selected_options[iIndex] = nil
        if not bSilent then
            self:OnUnselect(iIndex, self.options[iIndex].label, self.options[iIndex].data)
        end
    end
end

---`🔸 Client`<br>
---Gets the selected options as an associative table (key = index, value = true)
---@return table<number, boolean> @Selected options
function PANEL:GetSelectedOptions()
    return self.selected_options
end

---`🔸 Client`<br>
---Returns the first selected option
---@return number? @Index of the option, or nil if no option is selected
function PANEL:GetFirstSelectedOption()
    for i, _ in pairs(self.selected_options) do
        return i
    end
end

---`🔸 Client`<br>
---Returns the combobox's options
---@return table @Options
function PANEL:GetOptions()
    return self.options
end

---`🔸 Client`<br>
---Adds an option
---@param sLabel string @Label of the option
---@param xData any @Data of the option
---@param bSelected boolean @Whether the option is selected
---@return number @Index of the option
function PANEL:AddOption(sLabel, xData, bSelected)
    local iInd = (#self.options + 1)

    self.options[iInd] = {label = sLabel, data = xData}

    if bSelected then
        self:SetSelectedOption(iInd, true, true)
    end

    return iInd
end

---`🔸 Client`<br>
---Removes an option by index
---@param iIndex number @Index of the option
function PANEL:RemoveOption(iIndex)
    if not self.options[iIndex] then return end

    local tNewOptions = {}
    for i = 1, #self.options do
        if (i ~= iIndex) then
            tNewOptions[#tNewOptions + 1] = self.options[i]
        end
    end

    self.options = tNewOptions
end

---`🔸 Client`<br>
---Clears the options
function PANEL:ClearOptions()
    self.options = {}
    self.selected_options = {}
end

function PANEL:PerformLayout(iW, iH)
    local dMenu = self.menu
    if not dMenu or not dMenu:IsValid() then return end

    local dTitle = dMenu.title
    if not dTitle or not dTitle:IsValid() then return end

    local iScrW = ScrW()
    local iScrH = ScrH()
    local iX, iY = self:LocalToScreen(0, 0)

    local _, iDPT, _, iDPB = dMenu:GetDockPadding()
    local iNewW = math.max(dTitle:GetWide() + (TLib2.Padding4 * 2), (iScrH * 0.05))
    local iNewH = dTitle:GetTall() + (TLib2.Padding4 * 2) + iDPT + iDPB

    -- Set the menu size
    local tChildren = dMenu.scroll:GetCanvas():GetChildren()
    for i = 1, #tChildren do
        local dChild = tChildren[i]
        if not dChild or not dChild:IsValid() then continue end
        if not dChild.GetFont or not dChild.GetText then continue end

        surface.SetFont(dChild:GetFont())
        local iTextW, iTextH = surface.GetTextSize(dChild:GetText())
        local iInsetX, _ = dChild:GetTextInset()

        iNewW = math.max(iNewW, (iTextW + iInsetX + iTextH + TLib2.Padding2))
        iNewH = math.min(iNewH + dChild:GetTall(), self:GetMenuMaxHeight())
    end

    if (dMenu:GetWide() ~= iNewW) or (dMenu:GetTall() ~= iNewH) then
        dMenu:SetSize(iNewW, iNewH)
    end

    -- Position the menu
    local iMinX, iMinY = TLib2.Padding4, TLib2.Padding4
    local iMaxX, iMaxY = (iScrW - iNewW - TLib2.Padding4), (iScrH - iNewH - TLib2.Padding4)

    local iNewX = math.Clamp((iX + self:GetWide() - iNewW), iMinX, iMaxX)
    local iNewY = math.Clamp((iY + self:GetTall() + TLib2.Padding4), iMinY, iMaxY)

    if (dMenu:GetX() ~= iNewX) or (dMenu:GetY() ~= iNewY) then
        dMenu:SetPos(iNewX, iNewY)
    end
end

vgui.Register("TLib2:ComboBox", PANEL, "TLib2:Button")