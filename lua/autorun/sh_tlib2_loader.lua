-- TODO: Put this in workshop and remove from here
resource.AddFile("resource/fonts/fa5/fa-regular-400.ttf")
resource.AddFile("resource/fonts/fa5/fa-brands-400.ttf")
resource.AddFile("resource/fonts/fa5/fa-solid-900.ttf")
resource.AddFile("resource/fonts/rajdhani-bold.ttf")
resource.AddFile("resource/fonts/rajdhani-regular.ttf")
-- TODO end

TLib2 = TLib2 or {}

local function requireSH(sPath)
    if SERVER then
        AddCSLuaFile(sPath)
    end
    return include(sPath)
end

local function requireSV(sPath)
    if not SERVER then return end
    return include(sPath)
end

local function requireCL(sPath)
    if SERVER then
        AddCSLuaFile(sPath)
    end
    if CLIENT then
        return include(sPath)
    end
end

hook.Add("OnGamemodeLoaded", "TLib2:OnGamemodeLoaded", function()
    -- Shared
    ------------------------------------------------------------------
    requireSH("tlib2/shared/utils.lua")

    -- Client
    ------------------------------------------------------------------
    requireCL("tlib2/client/fonts.lua")
    requireCL("tlib2/client/color.lua")
    requireCL("tlib2/client/utils.lua")

    requireCL("tlib2/client/vgui_controls/button.lua")
    requireCL("tlib2/client/vgui_controls/checkbox.lua")
    requireCL("tlib2/client/vgui_controls/combobox.lua")
    requireCL("tlib2/client/vgui_controls/scroll.lua")
    requireCL("tlib2/client/vgui_controls/text_entry.lua")
    requireCL("tlib2/client/vgui_controls/data_table_drag_anchor.lua")
    requireCL("tlib2/client/vgui_controls/data_table.lua")
    requireCL("tlib2/client/vgui_controls/modal.lua")
    requireCL("tlib2/client/vgui_controls/list.lua")
    requireCL("tlib2/client/vgui_controls/slider.lua")
    requireCL("tlib2/client/vgui_controls/num_scratch.lua")
    requireCL("tlib2/client/vgui_controls/num_slider.lua")
    requireCL("tlib2/client/vgui_controls/color_input.lua")
    requireCL("tlib2/client/vgui_controls/tooltip.lua")
    requireCL("tlib2/client/vgui_controls/sidebar.lua")
    requireCL("tlib2/client/vgui_controls/navbar.lua")
    requireCL("tlib2/client/vgui_controls/frame.lua")
    requireCL("tlib2/client/vgui_controls/title.lua")
    requireCL("tlib2/client/vgui_controls/subtitle.lua")
    requireCL("tlib2/client/vgui_controls/separator.lua")
end)