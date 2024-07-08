local PANEL = {}
local sFADrag = TLib2.GetFAIcon("f58e")

local function findParentRowHoverRecursive(dVGUI)
    if not dVGUI or not dVGUI:IsValid() then return end

    if dVGUI.is_data_table_row then
        return dVGUI
    end

    return findParentRowHoverRecursive(dVGUI:GetParent())
end

function PANEL:Init()
    self:Dock(LEFT)
    self:SetCursor("hand")
    self.dragging = false
    self.drag_over = nil
end

function PANEL:__SetDragOver(dOver)
    if self.drag_over and (self.drag_over ~= dOver) then
        self:__ClearDragOver()
    end

    if self.drag_over then return end

    self.drag_over = dOver
    if dOver.separator and dOver.separator:IsValid() then
        dOver.separator:SetBackgroundColor(ZoneCreator.Cfg.Colors.Accent)
        dOver.separator:SetTall(ZoneCreator.Padding3)
    end
end

function PANEL:__ClearDragOver()
    if not self.drag_over then return end

    if self.drag_over:IsValid() and self.drag_over.separator and self.drag_over.separator:IsValid() then
        self.drag_over.separator:SetBackgroundColor(ZoneCreator.Cfg.Colors.Base1)
        self.drag_over.separator:SetTall(0)
    end

    self.drag_over = nil
end

function PANEL:OnRemove()
    self:__ClearDragOver()
end


function PANEL:Paint(iW, iH)
    if self.dragging then
        draw.SimpleText(sFADrag, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), ZoneCreator.Cfg.Colors.Accent, 1, 1)
        return
    end

    if not self:GetParent():IsHovered() then return end

    draw.SimpleText(sFADrag, "TLib2.FA.6", (iW * 0.5), (iH * 0.5), self:IsHovered() and ZoneCreator.Cfg.Colors.Base4 or ZoneCreator.Cfg.Colors.Base3, 1, 1)
end

function PANEL:StopDrag(bShouldDrop)
    hook.Remove("PlayerButtonUp", "ZoneCreator:DataTable:PlayerButtonUp")
    hook.Remove("DrawOverlay", "ZoneCreator:DataTable:DrawOverlay")

    if bShouldDrop then
        local dHovered = findParentRowHoverRecursive(vgui.GetHoveredPanel())
        if dHovered then
            if self.drop_data and IsValid(self.drop_data.parent) and self.drop_data.parent.OnDropRow then
                self.drop_data.parent:OnDropRow(self.drop_data.row, dHovered, self.drop_data.row.data, dHovered.data)
            end
        end
    end

    self:__ClearDragOver()
    self.dragging = false
    self.drag_over = nil
end

function PANEL:OnMousePressed(iButton)
    if (iButton ~= MOUSE_LEFT) then return end

    self.dragging = true

    hook.Add("PlayerButtonUp", "ZoneCreator:DataTable:PlayerButtonUp", function(_, iButton)
        if not IsFirstTimePredicted() then return end
        if (iButton ~= MOUSE_LEFT) then return end
        if not self:IsValid() then return end

        self:StopDrag(true)
    end)

    hook.Add("DrawOverlay", "ZoneCreator:DataTable:DrawOverlay", function()
        if not self:IsValid() then
            hook.Remove("PlayerButtonUp", "ZoneCreator:DataTable:PlayerButtonUp")
            hook.Remove("DrawOverlay", "ZoneCreator:DataTable:DrawOverlay")
            return
        end

        if not self.dragging then
            stopDrag(false)
            return
        end

        local _, iMouseY = input.GetCursorPos()
        local iX = self:LocalToScreen(0, 0)

        self:PaintAt(iX, iMouseY)

        local dHovered = findParentRowHoverRecursive(vgui.GetHoveredPanel())
        if dHovered then
            self:__SetDragOver(dHovered)
        else
            self:__ClearDragOver()
        end
    end)
end

vgui.Register("ZoneCreator:DataTableDragAnchor", PANEL, "DPanel")
