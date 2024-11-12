local math = math
local string = string
local draw = draw

local ScrW = ScrW
local ScrH = ScrH

local PANEL = {}

local oSelectedDateCol = TLib2.ColorManip(TLib2.Colors.Accent, 0.5, 0.2)

local tDaysLabels = {
    [1] = {full = "Sunday", abbr = "Su"},
    [2] = {full = "Monday", abbr = "Mo"},
    [3] = {full = "Tuesday", abbr = "Tu"},
    [4] = {full = "Wednesday", abbr = "We"},
    [5] = {full = "Thursday", abbr = "Th"},
    [6] = {full = "Friday", abbr = "Fr"},
    [7] = {full = "Saturday", abbr = "Sa"}
}

local tMonthLabels = {
    [1] = "January",
    [2] = "February",
    [3] = "March",
    [4] = "April",
    [5] = "May",
    [6] = "June",
    [7] = "July",
    [8] = "August",
    [9] = "September",
    [10] = "October",
    [11] = "November",
    [12] = "December"
}

function PANEL:Init()
    local iYear, iMonth = TLib2.TimestampToDate(os.time())

    self.calendar_page = {year = iYear, month = iMonth}
    self.time_picker = true
    
    self:SetFAIcon("f073", "TLib2.FA.6", true, true)
    self:__RebuildCalendar()
end

---`🔸 Client`<br>
---Returns the date picker's calendar page
---@return integer @The date picker's calendar page year
---@return integer @The date picker's calendar page month
function PANEL:GetCalendarPage()
    if not self.calendar_page then return end
    return self.calendar_page.year, self.calendar_page.month
end

---`🔸 Client`<br>
---Sets the date picker's calendar page
---@param iYear integer @The date picker's calendar page year
---@param iMonth integer @The date picker's calendar page month
function PANEL:SetCalendarPage(iYear, iMonth)
    if not TLib2.IsDateValid(iYear, iMonth, 1) then return end

    self.calendar_page = {year = iYear, month = iMonth}
    self:__RebuildCalendar()
end

---`🔸 Client`<br>
---Returns the date picker's minimum date
---@return integer @The date picker's minimum year
---@return integer @The date picker's minimum month
---@return integer @The date picker's minimum day
---@return integer @The date picker's minimum hour
---@return integer @The date picker's minimum minute
function PANEL:GetMinDate()
    local tMin = self.min_date
    if not tMin then return end

    return tMin.year, tMin.month, tMin.day, tMin.hour, tMin.min
end

---`🔸 Client`<br>
---Sets the date picker's minimum date
---@param iYear integer|nil @The date picker's minimum year (Set to nil to disable the minimum date)
---@param iMonth integer @The date picker's minimum month
---@param iDay integer @The date picker's minimum day
---@param iHour integer? @The date picker's minimum hour
---@param iMin integer? @The date picker's minimum minute
function PANEL:SetMinDate(iYear, iMonth, iDay, iHour, iMin)
    if not TLib2.IsDateValid(iYear, iMonth, iDay) then
        self.min_date = nil
        return
    end

    self.min_date = {
        year = iYear,
        month = iMonth,
        day = iDay,
        hour = (type(iHour) == "number") and math.floor(iHour) or 0,
        min = (type(iMin) == "number") and math.floor(iMin) or 0
    }

    local iDateTimestamp = TLib2.DateToTimestamp(self:GetDate())
    local iMinTimestamp = TLib2.DateToTimestamp(self:GetMinDate())
    local iMaxTimestamp = TLib2.DateToTimestamp(self:GetMaxDate())

    if iMaxTimestamp and (iMaxTimestamp < iMinTimestamp) then
        self:SetMaxDate(iYear, iMonth, iDay, iHour, iMin)
    end
    if iDateTimestamp and (iDateTimestamp < iMinTimestamp) then
        self:SetDate(iYear, iMonth, iDay, iHour, iMin)
    end
end

---`🔸 Client`<br>
---Returns the date picker's maximum date
---@return integer @The date picker's maximum year
---@return integer @The date picker's maximum month
---@return integer @The date picker's maximum day
function PANEL:GetMaxDate()
    local tMax = self.max_date
    if not tMax then return end

    return tMax.year, tMax.month, tMax.day, tMax.hour, tMax.min
end

---`🔸 Client`<br>
---Sets the date picker's maximum date
---@param iYear integer @The date picker's maximum year (Set to nil to disable the maximum date)
---@param iMonth integer @The date picker's maximum month
---@param iDay integer @The date picker's maximum day
---@param iHour integer? @The date picker's maximum hour
---@param iMin integer? @The date picker's maximum minute
function PANEL:SetMaxDate(iYear, iMonth, iDay, iHour, iMin)
    if not TLib2.IsDateValid(iYear, iMonth, iDay) then
        self.max_date = nil
        return
    end

    self.max_date = {
        year = iYear,
        month = iMonth,
        day = iDay,
        hour = (type(iHour) == "number") and math.floor(iHour) or 23,
        min = (type(iMin) == "number") and math.floor(iMin) or 59
    }

    local iDateTimestamp = TLib2.DateToTimestamp(self:GetDate())
    local iMinTimestamp = TLib2.DateToTimestamp(self:GetMinDate())
    local iMaxTimestamp = TLib2.DateToTimestamp(self:GetMaxDate())

    if iMinTimestamp and (iMinTimestamp > iMaxTimestamp) then
        self:SetMinDate(iYear, iMonth, iDay, iHour, iMin)
    end
    if iDateTimestamp and (iDateTimestamp > iMaxTimestamp) then
        self:SetDate(iYear, iMonth, iDay, iHour, iMin)
    end
end

---`🔸 Client`<br>
---Returns the date picker's date
---@return integer @The date picker's year
---@return integer @The date picker's month
---@return integer @The date picker's day
---@return integer @The date picker's hour
---@return integer @The date picker's minute
function PANEL:GetDate()
    local tDate = self.date
    if not tDate then return end

    return tDate.year, tDate.month, tDate.day, tDate.hour, tDate.min
end

---`🔸 Client`<br>
---Sets the date picker's date
---@param iYear integer @The date picker's year
---@param iMonth integer @The date picker's month
---@param iDay integer @The date picker's day
---@param iHour integer @The date picker's hour
---@param iMin integer @The date picker's minute
function PANEL:SetDate(iYear, iMonth, iDay, iHour, iMin)
    if not TLib2.IsDateValid(iYear, iMonth, iDay) then
        self.date = nil
        self:__RebuildCalendar()
        return
    end

    local tDate = self.date
    iHour = math.floor(math.Clamp((type(iHour) == "number") and iHour or (tDate and tDate.hour or 0), 0, 23))
    iMin = math.floor(math.Clamp((type(iMin) == "number") and iMin or (tDate and tDate.min or 0), 0, 59))

    local iNewDateUnix = TLib2.DateToTimestamp(iYear, iMonth, iDay, iHour, iMin)
    if tDate and (iNewDateUnix == TLib2.DateToTimestamp(tDate.year, tDate.month, tDate.day, tDate.hour, tDate.min)) then return end

    local iMinTimestamp = TLib2.DateToTimestamp(self:GetMinDate())
    if iMinTimestamp and (iNewDateUnix < iMinTimestamp) then
        self:SetDateFromTimestamp(iMinTimestamp)
        return
    end

    local iMaxTimestamp = TLib2.DateToTimestamp(self:GetMaxDate())
    if iMaxTimestamp and (iNewDateUnix > iMaxTimestamp) then
        self:SetDateFromTimestamp(iMaxTimestamp)
        return
    end

    self.date = {year = iYear, month = iMonth, day = iDay, hour = iHour, min = iMin}
    self:__RebuildCalendar()
end

---`🔸 Client`<br>
---Util method to set the date picker's date from a unix timestamp
---@param iUnix number @The timestamp
function PANEL:SetDateFromTimestamp(iUnix)
    local iYear, iMonth, iDay, iHour, iMin = TLib2.TimestampToDate(iUnix)
    self:SetDate(iYear, iMonth, iDay, iHour, iMin)
end

---`🔸 Client`<br>
---Util method to get the date picker's date as a unix timestamp
---@return number? @The date picker's unix timestamp, or nil if no date is set
function PANEL:GetDateTimestamp()
    return TLib2.DateToTimestamp(self:GetDate())
end

---`🔸 Client`<br>
---Returns whether the date picker menu is visible
---@return boolean @Whether the date picker menu is visible
function PANEL:IsTimePickerVisible()
    return self.time_picker
end

---`🔸 Client`<br>
---Sets whether the date picker menu is visible
---@param bVisible boolean @Whether the date picker menu is visible
function PANEL:SetTimePickerVisible(bVisible)
    bVisible = tobool(bVisible)

    if (self:IsTimePickerVisible() == bVisible) then return end

    self.time_picker = bVisible
    self:__RebuildCalendar()
end

---`🔸 Client`<br>
---Returns the date picker's button overrided text when there is no date set
---@return string @The button text
function PANEL:GetNoDateText()
    return self.no_date_text
end

---`🔸 Client`<br>
---Overrides the date picker's button text when there is no date set
---@param sText string @The button text
function PANEL:SetNoDateText(sText)
    self.no_date_text = (type(sText) == "string") and sText or nil
    self:__RebuildCalendar()
end

---`🔸 Client`<br>
---Called when the date picker menu is closed
function PANEL:OnCloseMenu()
end

---`🔸 Client`<br>
---Called when the date picker menu is opened
---@param dMenu EditablePanel @The date picker menu
function PANEL:OnOpenMenu(dMenu)
end

---`🔸 Client`<br>
---Closes the date picker menu
function PANEL:CloseMenu()
    if not self.menu or not self.menu:IsValid() then return end

    hook.Remove("GUIMousePressed", "TLib2.DatePicker")
    hook.Remove("VGUIMousePressed", "TLib2.DatePicker")

    self.menu:Remove()
    self.menu = nil

    if (type(self.OnCloseMenu) == "function") then
        self:OnCloseMenu()
    end
end

---`🔸 Client`<br>
---Opens the date picker menu
function PANEL:OpenMenu()
    if self.menu and self.menu:IsValid() then return end

    self.menu = vgui.Create("EditablePanel")
    self.menu:DockPadding(TLib2.Padding3, TLib2.Padding3, TLib2.Padding3, TLib2.Padding3)
    self.menu:MakePopup()
    self.menu:SetWide(ScrH() * 0.28)
    self.menu.Paint = function(_, iW, iH)
        draw.RoundedBox(TLib2.BorderRadius, 0, 0, iW, iH, TLib2.Colors.Base2)
        draw.RoundedBox(TLib2.BorderRadius - 2, 1, 1, iW - 2, iH - 2, TLib2.Colors.Base0)
    end

    self.menu.PerformLayout = function(_, iW, iH)
        self.menu:SizeToChildren(false, true)
    end

    local dMonthHeader = self.menu:Add("DPanel")
    dMonthHeader:Dock(TOP)
    dMonthHeader:SetTall(TLib2.VGUIControlH2)
    dMonthHeader.Paint = nil

    local dPrevMonth = dMonthHeader:Add("TLib2:Button")
    dPrevMonth:Dock(LEFT)
    dPrevMonth:SetFont("TLib2.6")
    dPrevMonth:SetFAIcon("f104", "TLib2.FA.6", true)
    dPrevMonth.DoClick = function()
        local iCalYear, iCalMonth = self:GetCalendarPage()
        if (iCalMonth == 1) then
            self:SetCalendarPage(iCalYear - 1, 12)
        else
            self:SetCalendarPage(iCalYear, iCalMonth - 1)
        end
    end

    self.menu.month_year_label = dMonthHeader:Add("TLib2:ComboBox")
    self.menu.month_year_label:Dock(FILL)
    self.menu.month_year_label:SetTall(TLib2.VGUIControlH1)
    self.menu.month_year_label:SetTextColor(TLib2.Colors.Base4)
    self.menu.month_year_label:SetContentAlignment(5)
    self.menu.month_year_label:SetFAIcon(nil)
    self.menu.month_year_label.Paint = nil
    self.menu.month_year_label.OnSelect = function(_, iIndex, sLabel, xData)
        local tSplit = xData:Split(".")
        self:SetCalendarPage(tonumber(tSplit[1]), tonumber(tSplit[2]))
    end

    local dNextMonth = dMonthHeader:Add("TLib2:Button")
    dNextMonth:Dock(RIGHT)
    dNextMonth:SetFont("TLib2.6")
    dNextMonth:SetFAIcon("f105", "TLib2.FA.6", true)
    dNextMonth.DoClick = function()
        local iCalYear, iCalMonth = self:GetCalendarPage()
        if (iCalMonth == 12) then
            self:SetCalendarPage(iCalYear + 1, 1)
        else
            self:SetCalendarPage(iCalYear, iCalMonth + 1)
        end
    end

    -- Calendar
    ------------------------------------------------------------------
    local dCalendar = self.menu:Add("DPanel")
    dCalendar:Dock(TOP)
    dCalendar:SetTall(ScrH() * 0.25)
    dCalendar.Paint = nil

    local dDaysLabels = dCalendar:Add("DPanel")
    dDaysLabels:Dock(TOP)
    dDaysLabels:DockMargin(0, TLib2.Padding3, 0, 0)
    dDaysLabels.Paint = nil
    dDaysLabels.PerformLayout = function(_, iW, iH)
        local iDayW = (iW / 7)
        local tChilds = dDaysLabels:GetChildren()
        for i = 1, #tChilds do
            if (tChilds[i]:GetWide() == iDayW) then continue end
            tChilds[i]:SetWide(iDayW)
        end
    end

    for i = 1, #tDaysLabels do
        local dDayLabel = dDaysLabels:Add("DButton")
        dDayLabel:Dock(LEFT)
        dDayLabel:SetText(tDaysLabels[i].abbr)
        dDayLabel:SetFont("TLib2.6")
        dDayLabel:SetContentAlignment(5)
        dDayLabel:SetTextColor(TLib2.Colors.Base3)
        dDayLabel:SizeToContents()
        dDayLabel.Paint = nil
        dDayLabel.OnCursorEntered = function()
            self.menu.hovered_day = i
        end
        dDayLabel.OnCursorExited = function()
            self.menu.hovered_day = nil
        end
    end

    dDaysLabels:SizeToChildren(false, true)

    local dSep = dCalendar:Add("TLib2:Separator")
    dSep:Dock(TOP)
    dSep:SetBackgroundColor(TLib2.Colors.Base2)

    self.menu.days_container = dCalendar:Add("DIconLayout")

    local dDays = self.menu.days_container
    dDays:Dock(FILL)
    dDays.Paint = nil
    dDays.__old_performlayout = dDays.PerformLayout
    dDays.PerformLayout = function(_, iW, iH)
        local iDayW, iDayH = (iW / 7), (iH / 6)
        local tChilds = dDays:GetChildren()
        for i = 1, #tChilds do
            local dDate = tChilds[i]
            if (dDate:GetWide() ~= iDayW) or (dDate:GetTall() ~= iDayH) then
                dDate:SetSize(iDayW, iDayH)
            end
        end
        dDays.__old_performlayout(dDays, iW, iH)
    end

    -- Clock
    ------------------------------------------------------------------
    self.menu.clock_container = self.menu:Add("DPanel")
    self.menu.clock_container:Dock(TOP)
    self.menu.clock_container.Paint = nil
    self.menu.clock_container.PerformLayout = function(_, iW, iH)
        local iChildsH = 0
        for _, dChild in ipairs(self.menu.clock_container:GetChildren()) do
            local iML, iMT, iMR, iMB = dChild:GetDockMargin()
            iChildsH = iChildsH + dChild:GetTall() + iMT + iMB
        end

        if (iChildsH ~= iH) then
            self.menu.clock_container:SetTall(iChildsH)
        end
    end

    dSep = self.menu.clock_container:Add("TLib2:Separator")
    dSep:Dock(TOP)
    dSep:SetBackgroundColor(TLib2.Colors.Base2)

    local dClockLower = self.menu.clock_container:Add("DPanel")
    dClockLower:Dock(TOP)
    dClockLower:SetTall(TLib2.VGUIControlH2)
    dClockLower.Paint = nil
    dClockLower.PerformLayout = function(_, iW, iH)
        local iChildsW = 0
        for _, dChild in ipairs(dClockLower:GetChildren()) do
            local iML, iMT, iMR, iMB = dChild:GetDockMargin()
            iChildsW = iChildsW + dChild:GetWide() + iML + iMR
        end

        local iPL, iPT, iPR, iPB = dClockLower:GetDockPadding()
        if (iPL ~= (iW - iChildsW)) then
            dClockLower:DockPadding(iW - iChildsW, 0, 0, 0)
        end
    end

    self.menu.clock_hours = dClockLower:Add("TLib2:NumWang")
    self.menu.clock_hours:Dock(LEFT)
    self.menu.clock_hours:SetWide(ScrH() * 0.05)
    self.menu.clock_hours:SetDecimals(0)
    self.menu.clock_hours:SetMin(0)
    self.menu.clock_hours:SetMax(23)
    self.menu.clock_hours.__old_setvalue = self.menu.clock_hours.SetValue
    self.menu.clock_hours.SetValue = function(_, iNewVal)
        self.menu.clock_hours.__old_setvalue(self.menu.clock_hours, iNewVal)
        self.menu.clock_hours:SetText(string.format("%02d", self.menu.clock_hours:GetValue()))
    end
    self.menu.clock_hours.OnValueChanged = function(_, iNewVal)
        local iYear, iMonth, iDay, _, iMin = self:GetDate()
        self:SetDate(iYear, iMonth, iDay, iNewVal, iMin)
    end

    local dLbl = dClockLower:Add("DLabel")
    dLbl:Dock(LEFT)
    dLbl:SetText(":")
    dLbl:SetFont("TLib2.6")
    dLbl:SetContentAlignment(5)
    dLbl:SetTextColor(TLib2.Colors.Base3)
    dLbl:SizeToContentsX()
    dLbl:SetWide(dLbl:GetWide() + (TLib2.Padding4 * 2))
    dLbl.Paint = nil

    self.menu.clock_minutes = dClockLower:Add("TLib2:NumWang")
    self.menu.clock_minutes:Dock(LEFT)
    self.menu.clock_minutes:SetWide(ScrH() * 0.05)
    self.menu.clock_minutes:SetDecimals(0)
    self.menu.clock_minutes:SetMin(0)
    self.menu.clock_minutes:SetMax(59)
    self.menu.clock_minutes.__old_setvalue = self.menu.clock_minutes.SetValue
    self.menu.clock_minutes.SetValue = function(_, iNewVal)
        self.menu.clock_minutes.__old_setvalue(self.menu.clock_minutes, iNewVal)
        self.menu.clock_minutes:SetText(string.format("%02d", self.menu.clock_minutes:GetValue()))
    end
    self.menu.clock_minutes.OnValueChanged = function(_, iNewVal)
        local iYear, iMonth, iDay, iHour = self:GetDate()
        self:SetDate(iYear, iMonth, iDay, iHour, iNewVal)
    end

    self:__RebuildCalendar()

    if (type(self.OnOpenMenu) == "function") then
        self:OnOpenMenu(self.menu)
    end

    hook.Add("GUIMousePressed", "TLib2.DatePicker", function(iMouseCode)
        if (iMouseCode ~= MOUSE_LEFT) then return end
        self:CloseMenu()
    end)

    hook.Add("VGUIMousePressed", "TLib2.DatePicker", function(dPanel, iMouseCode)
        if (iMouseCode ~= MOUSE_LEFT) or (dPanel == self.menu) then return end
        if self.menu:IsChildHovered(false) then return end

        if self.menu.month_year_label.menu and self.menu.month_year_label.menu:IsValid() then
            if self.menu.month_year_label.menu:IsChildHovered(false) then return end
        end

        self:CloseMenu()
    end)
end

---`🔸 Client`<br>
---Internally used to rebuild the date picker's calendar and buttons
function PANEL:__RebuildCalendar()
    local bTimeVisible = self:IsTimePickerVisible()
    local iYear, iMonth, iDay, iHour, iMin = self:GetDate()
    if iYear then
        local sDayLabel = tDaysLabels[(TLib2.GetDayOfWeek(iYear, iMonth, iDay))].full

        if bTimeVisible then
            self:SetText(("%s %02d/%02d/%d %02d:%02d"):format(sDayLabel, iDay, iMonth, iYear, iHour, iMin))
        else
            self:SetText(("%s %02d/%02d/%d"):format(sDayLabel, iDay, iMonth, iYear))
        end
    else
        local sNoDateText = self:GetNoDateText()
        if sNoDateText then
            self:SetText(sNoDateText)
        else
            self:SetText(bTimeVisible and (".. / .. / .... %02d:%02d"):format(iHour or 0, iMin or 0) or ".. / .. / ....")
        end
    end

    if not self.menu or not self.menu:IsValid() then return end

    local dDaysContainer = self.menu.days_container
    if not dDaysContainer or not dDaysContainer:IsValid() then return end

    local iCalYear, iCalMonth = self:GetCalendarPage()
    local iMinTimestamp = TLib2.DateToTimestamp(self:GetMinDate())
    local iMaxTimestamp = TLib2.DateToTimestamp(self:GetMaxDate())
    local iFirstDayInMonth = TLib2.GetFirstDayOfMonth(iCalYear, iCalMonth)
    
    local iLastMonth, iLastYear = (iCalMonth - 1), iCalYear
    if (iLastMonth == 0) then
        iLastMonth, iLastYear = 12, (iCalYear - 1)
    end

    local iDaysInMonth = TLib2.GetDaysInMonth(iCalYear, iCalMonth)
    local iDaysInLastMonth = TLib2.GetDaysInMonth(iLastYear, iLastMonth)
    
    self.menu.clock_container:SetVisible(self:IsTimePickerVisible())

    self.menu.month_year_label:SetText(tMonthLabels[iCalMonth].." "..iCalYear)
    self.menu.month_year_label:ClearOptions()
    for i = -12, 12 do
        local iOtherYear = iCalYear
        local iOtherMonth = iCalMonth
        local bCurrentYM = false

        if (i == 0) then
            bCurrentYM = true
        else
            iOtherMonth = (iCalMonth + (1 * i))

            if (iOtherMonth < 1) then
                iOtherYear, iOtherMonth = (iCalYear - 1),  12
            elseif (iOtherMonth > 12) then
                iOtherYear, iOtherMonth = (iCalYear + 1), iOtherMonth - 12
            end
        end

        self.menu.month_year_label:AddOption(tMonthLabels[iOtherMonth].." "..iOtherYear, iOtherYear.."."..iOtherMonth, bCurrentYM)
    end
    

    dDaysContainer:Clear()
    for iGridWeek = 1, 6 do
        for iGridDay = 1, 7 do
            local iGridPos = (iGridWeek - 1) * 7 + (iGridDay + 1)
            local iCurDay = (iGridPos - iFirstDayInMonth)

            local iBtnYear, iBtnMonth, iBtnDay
            if (iCurDay < 1) then
                iBtnYear = (iCalMonth == 1) and (iCalYear - 1) or iCalYear
                iBtnMonth = (iCalMonth == 1) and 12 or (iCalMonth - 1)
                iBtnDay = (iDaysInLastMonth + iCurDay)

            elseif (iCurDay > iDaysInMonth) then
                iBtnYear = (iCalMonth == 12) and (iCalYear + 1) or iCalYear
                iBtnMonth = (iCalMonth == 12) and 1 or (iCalMonth + 1)
                iBtnDay = (iCurDay - iDaysInMonth)

            else
                iBtnYear = iCalYear
                iBtnMonth = iCalMonth
                iBtnDay = iCurDay
            end

            local iWeekDay = TLib2.GetDayOfWeek(iBtnYear, iBtnMonth, iBtnDay)
            local bDateSelected = ((iBtnYear == iYear) and (iBtnMonth == iMonth) and (iBtnDay == iDay))

            local dDate = dDaysContainer:Add("TLib2:Button")
            dDate:SetText(iBtnDay)
            dDate:SetFont("TLib2.6")
            dDate:SetContentAlignment(5)
            dDate:SetTextColor(TLib2.Colors.Base4)

            dDate.DoClick = function()
                self:SetCalendarPage(iBtnYear, iBtnMonth)

                if (iBtnMonth ~= iCalMonth) or (iBtnYear ~= iCalYear) then return end

                if bDateSelected and self:GetDate() then
                    self:SetDate(nil)
                else
                    self:SetDate(iBtnYear, iBtnMonth, iBtnDay)
                end
            end

            dDate.Paint = function(_, iW, iH)
                if self.menu.hovered_day and (self.menu.hovered_day == iWeekDay) then
                    surface.SetDrawColor(TLib2.Colors.Base1)
                    surface.DrawRect(0, 0, iW, iH)
                end

                local bHovered = dDate:IsHovered()
                if not (bDateSelected or bHovered) then return end

                local iBtnW, iBtnH = iH - (TLib2.Padding4), iH - (TLib2.Padding4 * 2)
                local iBtnX, iBtnY = (iW - iBtnW) * 0.5, (iH - iBtnH) * 0.5

                draw.RoundedBox(TLib2.BorderRadius, iBtnX, iBtnY, iBtnW, iBtnH, bDateSelected and TLib2.Colors.Accent or TLib2.Colors.Base2)

                if bDateSelected then
                    draw.RoundedBox((TLib2.BorderRadius - 2), (iBtnX + 1), (iBtnY + 1), (iBtnW - 2), (iBtnH - 2), oSelectedDateCol)
                end
            end

            if (iCurDay < 1) or (iCurDay > iDaysInMonth) then
                dDate:SetTextColor(TLib2.Colors.Base3)
                dDate:SetAlpha(50)
                continue
            end

            if iMinTimestamp or iMaxTimestamp then
                local iBtnTimestamp = TLib2.DateToTimestamp(iBtnYear, iBtnMonth, iBtnDay, 23, 59)
                if (iMinTimestamp and (iBtnTimestamp < iMinTimestamp)) or (iMaxTimestamp and (iBtnTimestamp > iMaxTimestamp)) then
                    dDate:SetTextColor(TLib2.Colors.Base3)
                    dDate:SetCursor("no")
                end
            end
        end
    end

    if self.menu.clock_hours and self.menu.clock_hours:IsValid() then
        if (self.menu.clock_hours:GetValue() ~= iHour) then
            self.menu.clock_hours:SetValue(iHour)
        end
        if (self.menu.clock_minutes:GetValue() ~= iMin) then
            self.menu.clock_minutes:SetValue(iMin)
        end
    end
end

function PANEL:Think()
    if not self.menu or not self.menu:IsValid() then return end

    local iW, iH = self:GetSize()
    local iX, iY = self:LocalToScreen(0, 0)
    local iMenuW, iMenuH = self.menu:GetSize()

    local iNewX = math.Clamp(
        iX + (iW * 0.5) - (iMenuW * 0.5),
        TLib2.Padding4,
        (ScrW() - iMenuW - TLib2.Padding4)
    )

    local iNewY = math.Clamp(
        iY + iH + TLib2.Padding4,
        TLib2.Padding4,
        (ScrH() - iMenuH - TLib2.Padding4)
    )

    if (self.menu:GetX() ~= iNewX) or (self.menu:GetY() ~= iNewY) then
        self.menu:SetPos(iNewX, iNewY)
    end
end

function PANEL:DoClickInternal()
    TLib2.PlayUISound("tlib2/click.ogg")

    self:OpenMenu()
end

function PANEL:OnRemove()
    self:CloseMenu()
end

vgui.Register("TLib2:DatePicker", PANEL, "TLib2:Button")