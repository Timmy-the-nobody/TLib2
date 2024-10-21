local matGradC = Material("gui/center_gradient", "nocull smooth")
local PANEL = {}

function PANEL:Init()
    self.display_text = ""
    self.current_page = 1
    self.total_pages = 10

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

    self.page_display = self:Add("DPanel")
    self.page_display:Dock(FILL)
    self.page_display.Paint = function(_, iW, iH)
        surface.SetDrawColor(TLib2.Colors.Base1)
        surface.SetMaterial(matGradC)
        surface.DrawTexturedRect(0, 0, iW, iH)

        draw.SimpleText(self.display_text, "TLib2.7", (iW * 0.5), (iH * 0.5), TLib2.Colors.Base4, 1, 1)
    end

    self.item_count = self:Add("TLib2:ComboBox")
    self.item_count:SetVisible(false)
    self.item_count:Dock(RIGHT)
    self.item_count:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.item_count:SetText("1")
    self.item_count:SetFAIcon("f0d7", "TLib2.FA.8", true, true)
    self.item_count.OnSelect = function(_, iIndex, sLabel, xData)
        self.item_count:SetText(sLabel)
        self.item_count:AdjustWidth()

        self:OnItemsPerPageChange(xData, iIndex)
    end

    self.last_page = self:Add("TLib2:Button")
    self.last_page:Dock(RIGHT)
    self.last_page:DockMargin(TLib2.Padding4, 0, 0, 0)
    self.last_page:SetFAIcon("f101", "TLib2.FA.8", true, true)
    self.last_page.DoClick = function()
        self:SetPage(self.total_pages)
        self:OnLastPage()
    end

    self.next_page = self:Add("TLib2:Button")
    self.next_page:Dock(RIGHT)
    self.next_page:SetFAIcon("f105", "TLib2.FA.8", true, true)
    self.next_page.DoClick = function()
        local iPage = self:GetPage()
        if (iPage < self.total_pages) then
            self:SetPage(iPage + 1)
            self:OnNextPage()
        end
    end

    self:UpdateButtons()
end

function PANEL:Paint(iW, iH)
end

function PANEL:GetTotalPages()
    return self.total_pages
end

function PANEL:SetTotalPages(iPages)
    self.total_pages = iPages
end

function PANEL:GetPage()
    return self.current_page
end

function PANEL:SetPage(iPage)
    self.current_page = math.Clamp(iPage, 1, self.total_pages)

    self:UpdateButtons()
    self:OnPageChange(self.current_page)
end

function PANEL:OnFirstPage()
end

function PANEL:OnPrevPage()
end

function PANEL:OnNextPage()
end

function PANEL:OnLastPage()
end

function PANEL:OnPageChange(iPage)
end

function PANEL:GetItemsPerPage()
    return self.items_per_page
end

function PANEL:SetItemsPerPage(...)
    local tArgs = {...}
    local tItemCounts = {}

    for i = 1, #tArgs do
        if (type(tArgs[i]) ~= "number") then continue end
        tItemCounts[#tItemCounts + 1] = tArgs[i]
    end

    if (#tItemCounts == 0) then
        self.items_per_page = nil
        self.item_count:SetVisible(false)
        return
    end

    table.sort(tItemCounts, function(iA, iB)
        return iA < iB
    end)

    self.items_per_page = tItemCounts

    self.item_count:ClearOptions()
    self.item_count:SetVisible(true)
    self.item_count:SetFAIcon("f107", "TLib2.FA.8", true, true)
    for i = 1, #tItemCounts do
        self.item_count:AddOption(tItemCounts[i], tItemCounts[i], (i == 1))
    end

    self.item_count:SetText(tItemCounts[1])
    timer.Simple(0, function()
        self.item_count:AdjustWidth()
    end)
end

function PANEL:OnItemsPerPageChange(iItemsPerPage, iChoiceIndex)
end

function PANEL:SetDisplayTextFormat(sText)
    if (type(sText) ~= "string") then return end

    self.format_display_text = sText
    self:UpdateButtons()
end

function PANEL:UpdateButtons()
    self.first_page:SetClickable(self.current_page > 1)
    self.prev_page:SetClickable(self.current_page > 1)
    self.next_page:SetClickable(self.current_page < self.total_pages)
    self.last_page:SetClickable(self.current_page < self.total_pages)

    self.display_text = (self.format_display_text or "Page %s/%s"):format(self.current_page, self.total_pages)
end

vgui.Register("TLib2:Pagination", PANEL, "DPanel")