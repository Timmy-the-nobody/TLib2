local PANEL = {}

local draw = draw

function PANEL:Init()
    local iScrH = ScrH()
    local dPanel = self

    self.lines = {}

    self.title = self:Add("TLib2:Title")
    self.title:Dock(TOP)
    self.title:SetText("")
    self.title:SetVisible(false)

    self.subtitle = self:Add("TLib2:Subtitle")
    self.subtitle:Dock(TOP)
    self.subtitle:DockMargin(0, 0, 0, TLib2.Padding3)
    self.subtitle:SetText("")
    self.subtitle:SetVisible(false)

    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetTall(TLib2.VGUIControlH1)
    self.header.Paint = nil

    self.search_bar = self.header:Add("TLib2:TextEntry")
    self.search_bar:Dock(FILL)
    self.search_bar:DockMargin(0, 0, TLib2.Padding4, 0)

    function self.search_bar:OnValueChange(sValue)
        sValue = sValue:lower()

        for i = 1, #self.lines do
            local dLine = self.lines[i]
            local bVisible = (sValue == "") and true or (dLine:GetText():lower():find(sValue) ~= nil)

            dLine:SetVisible(bVisible)
        end

        local dList = dPanel:GetList()
        dList:InvalidateChildren(true)
        dList:InvalidateLayout(true)
    end

    self.button = self.header:Add("TLib2:Button")
    self.button:Dock(RIGHT)
    self.button:SetText("")
    self.button:SetFAIcon("f0c0", "TLib2.FA.6", true, true)
    
    function self.button:DoClick()
        if (type(dPanel.OnClickButton) ~= "function") then return end
        dPanel:OnClickButton()
    end

    self.list = self:Add("TLib2:Scroll")
    self.list:Dock(FILL)
    self.list:DockMargin(0, TLib2.Padding3, 0, 0)
    self.list:SetTall(iScrH * 0.24)
end

function PANEL:Paint()
end

---`🔸 Client`<br>
---Returns the header's search bar
---@return TLib2:TextEntry @The search bar
function PANEL:GetSearchBar()
    return self.search_bar
end

---`🔸 Client`<br>
---Returns the header's button
---@return TLib2:Button @The button
function PANEL:GetButton()
    return self.button
end

---`🔸 Client`<br>
---Returns the list
---@return TLib2:Scroll @The list
function PANEL:GetList()
    return self.list
end

---`🔸 Client`<br>
---Clears the list
function PANEL:Clear()
    self:GetList():Clear()
    self:InvalidateLayout()

    self.lines = {}
    self:__OnLinesUpdate()
end

---`🔸 Client`<br>
---Sets the title
---@param sTitle string @The title
function PANEL:SetTitle(sTitle)
    self.title:SetText(sTitle)
    self.title:SetVisible(true)

    if not self.subtitle:IsVisible() then
        self.title:DockMargin(0, 0, 0, TLib2.Padding3)
    end
end

---`🔸 Client`<br>
---Sets the subtitle
---@param sSubtitle string @The subtitle
function PANEL:SetSubtitle(sSubtitle)
    self.subtitle:SetText(sSubtitle)
    self.subtitle:SetVisible(true)

    if self.title:IsVisible() then
        self.title:DockMargin(0, 0, 0, 0)
    end

    self.subtitle:DockMargin(0, 0, 0, TLib2.Padding3)
end

---`🔸 Client`<br>
---Adds a line to the list
---@param sLabel string @The label of the line
---@param xValue any @The value of the line
function PANEL:AddLine(sLabel, xValue)
    local iScrH = ScrH()
    local dPanel = self
    local dList = self:GetList()
    local iLine = (#self.lines + 1)

    self.lines[iLine] = dList:Add("TLib2:Button")

    local dLine = self.lines[iLine]
    dLine:SetTextColor(TLib2.Colors.Base4)
    dLine:SetContentAlignment(4)
    dLine:SetTextInset(TLib2.Padding3, 0)
    dLine:SetText(sLabel)
    dLine:Dock(TOP)
    dLine.value = xValue
    dLine.index = iLine

    function dLine:IsHovered()
        local dHovered = vgui.GetHoveredPanel()
        if not dHovered then return false end
        if (dHovered == self) then return true end
        return self:IsChildHovered(false)
    end

    function dLine:Paint(iW, iH)
        if not self:IsHovered() then return end
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base1)
    end

    function dLine:DoClick()
        dList:ScrollToChild(self)
    end

    local dDelete = dLine:Add("DButton")
    dDelete:Dock(RIGHT)
    dDelete:SetText("")
    dDelete:SetWide(dLine:GetTall())

    function dDelete:Paint(iW, iH)
        TLib2.DrawFAIcon("f1f8", "TLib2.FA.6", (iW * 0.5), (iH * 0.5), self:IsHovered() and TLib2.Colors.Warn or TLib2.Colors.Base3, 1, 1)
    end

    function dDelete:DoClick()
        if (type(dPanel.OnClickRemove) == "function") then
            local bRemove = dPanel:OnClickRemove(dLine, iLine, xValue)
            if (bRemove == false) then return end
        end
        dPanel:RemoveLine(iLine)
    end

    self:__OnLinesUpdate()

    return dLine, iLine
end

---`🔸 Client`<br>
---Removes a line by index
---@param iIndex number @Index of the line
function PANEL:RemoveLine(iIndex)
    if not self.lines[iIndex] then return end
    if not self.lines[iIndex]:IsValid() then return end

    self.lines[iIndex]:Remove()
    self.lines[iIndex] = nil

    for k, v in pairs(self.lines) do
        if (v.index ~= k) then
            self.lines[k] = v
            v.index = k
        end
    end

    self.list:InvalidateLayout()
    self:__OnLinesUpdate()
end

---`🔸 Client`<br>
---Called when the lines of the list are updated, used internally
---@private
function PANEL:__OnLinesUpdate()
    if (#self.lines == 0) then
        self:GetList():SetBackgroundInfo("Empty List", "f15b")
    else
        self:GetList():SetBackgroundInfo()
    end
end

---`🔸 Client`<br>
---Returns a line by index
---@param iIndex number @Index of the line
---@return TLib2:Button? @The line panel
function PANEL:GetLine(iIndex)
    return self.lines[iIndex]
end

---`🔸 Client`<br>
---Called when the button of the header is clicked
function PANEL:OnClickButton()
end

---`🔸 Client`<br>
---Called when the remove button of a line is clicked
---@param dLine TLib2:Button @The line panel
---@param iLine number @Index of the line
---@param xValue any @Value of the line
function PANEL:OnClickRemove(dLine, iLine, xValue)
end

vgui.Register("TLib2:List", PANEL, "DPanel")