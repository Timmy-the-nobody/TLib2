local surface = surface
local draw = draw

local matGradC = Material("gui/center_gradient", "nocull smooth")

---@class TLib2:Pagination : DPanel
local PANEL = {}

function PANEL:Init()
    self.display_text = ""
    self.current_page = 1
    self.total_pages = 10

    self.items_per_page_choices = {}
    self.items_per_page = 100

    self:SetWide(ScrH() * 0.28)
    self:SetTall(TLib2.VGUIControlH2)

    self.first_page = self:Add("TLib2:Button")
    self.first_page:Dock(LEFT)
    self.first_page:SetFAIcon("f100", "TLib2.FA.8", true, true)
    self.first_page:DockMargin(0, 0, TLib2.Padding4, 0)
    self.first_page.DoClick = function()
        self:SetPage(1)
        self:OnFirstPage()
    end

    self.prev_page = self:Add("TLib2:Button")
    self.prev_page:Dock(LEFT)
    self.prev_page:SetFAIcon("f104", "TLib2.FA.8", true, true)
    self.prev_page:DockMargin(0, 0, TLib2.Padding4, 0)
    self.prev_page.DoClick = function()
        local iPage = self:GetPage()
        if (iPage > 1) then
            self:SetPage(iPage - 1)
            self:OnPrevPage()
        end
    end

    self.page_display = self:Add("TLib2:ComboBox")
    self.page_display:Dock(FILL)
    self.page_display:SetFAIcon()
    self.page_display.OnSelect = function(_, iIndex, sLabel, xData)
        self:SetPage(xData)
    end
    self.page_display.Paint = function(_, iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base1)
        surface.SetMaterial(matGradC)
        surface.DrawTexturedRect(0, 0, iW, iH)

        draw.SimpleText(self.display_text, "TLib2.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
    end

    self.item_count_box = self:Add("TLib2:ComboBox")
    self.item_count_box:SetVisible(false)
    self.item_count_box:Dock(RIGHT)
    self.item_count_box:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.item_count_box:SetFAIcon("f107", "TLib2.FA.8", true, true)
    self.item_count_box.OnSelect = function(_, iIndex, sLabel, xData)
        self:SetItemsPerPage(xData)
    end

    self.last_page = self:Add("TLib2:Button")
    self.last_page:Dock(RIGHT)
    self.last_page:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.last_page:SetFAIcon("f101", "TLib2.FA.8", true, true)
    self.last_page.DoClick = function()
        self:SetPage(self:GetTotalPages())
        self:OnLastPage()
    end

    self.next_page = self:Add("TLib2:Button")
    self.next_page:Dock(RIGHT)
    self.next_page:SetFAIcon("f105", "TLib2.FA.8", true, true)
    self.next_page.DoClick = function()
        local iPage = self:GetPage()
        if (iPage < self:GetTotalPages()) then
            self:SetPage(iPage + 1)
            self:OnNextPage()
        end
    end

    self:UpdateButtons()
end

---`🔸 Client`<br>
---Returns the total number of pages
---@return number @Total number of pages
function PANEL:GetTotalPages()
    return self.total_pages
end

---`🔸 Client`<br>
---Sets the total number of pages
---@param iPages number @Total number of pages
function PANEL:SetTotalPages(iPages)
    self.total_pages = iPages
    self:UpdateButtons()
end

---`🔸 Client`<br>
---Returns the current page
---@return number @Current page
function PANEL:GetPage()
    return self.current_page
end

---`🔸 Client`<br>
---Sets the current page
---@param iPage number @Current page
function PANEL:SetPage(iPage)
    self.current_page = math.Clamp(iPage, 1, self.total_pages)

    self:UpdateButtons()
    self:OnPageChange(self.current_page)
end

---`🔸 Client`<br>
---Called when the first page button is clicked
function PANEL:OnFirstPage()
end

---`🔸 Client`<br>
---Called when the previous page button is clicked
function PANEL:OnPrevPage()
end

---`🔸 Client`<br>
---Called when the next page button is clicked
function PANEL:OnNextPage()
end

---`🔸 Client`<br>
---Called when the last page button is clicked
function PANEL:OnLastPage()
end

---`🔸 Client`<br>
---Called when the page is changed
---@param iPage number @Current page
function PANEL:OnPageChange(iPage)
end

---`🔸 Client`<br>
---Returns a table of the items per page choices
---@return table <number, number> @Items per page choices
function PANEL:GetItemsPerPageChoices()
    return self.items_per_page_choices
end

---`🔸 Client`<br>
---Sets the items per page choices
---@param ... number @Items per page choices
function PANEL:SetItemsPerPageChoices(...)
    local tArgs = {...}
    local tItemCounts = {}
    local dItemCount = self.item_count_box

    for i = 1, #tArgs do
        if (type(tArgs[i]) ~= "number") then continue end
        tItemCounts[#tItemCounts + 1] = tArgs[i]
    end

    if (#tItemCounts == 0) then
        self.items_per_page_choices = {}
        dItemCount:SetVisible(false)
        return
    end

    table.sort(tItemCounts, function(iA, iB)
        return iA < iB
    end)

    self.items_per_page_choices = tItemCounts
    dItemCount:SetVisible(true)

    self:SetItemsPerPage(tItemCounts[1])

    timer.Simple(0, function()
        if not dItemCount or not dItemCount:IsValid() then return end
        dItemCount:AdjustWidth()
    end)
end

---`🔸 Client`<br>
---Returns the items per page
---@return number @Items per page
function PANEL:GetItemsPerPage()
    return self.items_per_page
end

---`🔸 Client`<br>
---Sets the items per page
---@param iCount number @Items per page
function PANEL:SetItemsPerPage(iCount)
    if (type(iCount) ~= "number") then return end

    self.items_per_page = iCount

    self.item_count_box:SetText(iCount)
    self.item_count_box:AdjustWidth()

    self:OnItemsPerPageChange(iCount)
end

---`🔸 Client`<br>
---Called when the items per page is changed
---@param iItemsPerPage number @Items per page
function PANEL:OnItemsPerPageChange(iItemsPerPage)
end

---`🔸 Client`<br>
---Returns the title of the item count box
---@return string @Title of the item count box
function PANEL:SetItemCountBoxTitle(sTitle)
    if (type(sTitle) ~= "string") then return end
    self.item_count_box:SetTitle(sTitle)
end

---`🔸 Client`<br>
---Sets the formatting of the display text, use "%s/%s" for the current page and total pages
---@param sText string @Display text
function PANEL:SetDisplayTextFormat(sText)
    if (type(sText) ~= "string") then return end

    self.format_display_text = sText
    self:UpdateButtons()
end

---`🔸 Client`<br>
---Refresh the buttons and display text
function PANEL:UpdateButtons()
    self.first_page:SetClickable(self.current_page > 1)
    self.prev_page:SetClickable(self.current_page > 1)
    self.next_page:SetClickable(self.current_page < self.total_pages)
    self.last_page:SetClickable(self.current_page < self.total_pages)

    if self:GetPage() > self:GetTotalPages() then
        self:SetPage(1)
    end

    -- Items per page choices box
    local tItemsPerPageChoices = self:GetItemsPerPageChoices()

    self.item_count_box:ClearOptions()
    for i = 1, #tItemsPerPageChoices do
        local iVal = tItemsPerPageChoices[i]
        if (iVal == self:GetItemsPerPage()) then
            self.item_count_box:AddOption(iVal, iVal, true)
            self.item_count_box:SetText(iVal)
        else
            self.item_count_box:AddOption(iVal, iVal, faalse)
        end
    end

    -- Page display update
    self.page_display:ClearOptions()
    for i = 1, self:GetTotalPages() do
        self.page_display:AddOption(i, i, self:GetPage() == i)
    end

    self.display_text = (self.format_display_text or "%s/%s"):format(self.current_page, self.total_pages)
end

function PANEL:Paint(iW, iH)
end

vgui.Register("TLib2:Pagination", PANEL, "DPanel")