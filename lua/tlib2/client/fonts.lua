local math = math
local surface = surface

local iBorderRadius = 0
local tPadding = {}
local tFAChars = {}

-- Absolute size fonts
surface.CreateFont("TLib2.Abs.1", {font = "Rajdhani Bold", size = 60, weight = 600, antialias = true})
surface.CreateFont("TLib2.Abs.2", {font = "Rajdhani Bold", size = 42, weight = 600, antialias = true})
surface.CreateFont("TLib2.Abs.3", {font = "Rajdhani Bold", size = 36, weight = 600, antialias = true})
surface.CreateFont("TLib2.Abs.4", {font = "Rajdhani Bold", size = 30, weight = 600, antialias = true})
surface.CreateFont("TLib2.Abs.5", {font = "Rajdhani Bold", size = 22, weight = 550, antialias = true})
surface.CreateFont("TLib2.Abs.6", {font = "Rajdhani Regular", size = 21, weight = 550, antialias = true})
surface.CreateFont("TLib2.Abs.7", {font = "Rajdhani Regular", size = 19, weight = 550, antialias = true})

-- Absolute size icons
surface.CreateFont("TLib2.Abs.FA.1", {font = "Font Awesome 5 Free Solid", size = 80, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.2", {font = "Font Awesome 5 Free Solid", size = 48, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.3", {font = "Font Awesome 5 Free Solid", size = 32, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.4", {font = "Font Awesome 5 Free Solid", size = 24, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.5", {font = "Font Awesome 5 Free Solid", size = 18, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.6", {font = "Font Awesome 5 Free Solid", size = 16, antialias = true, extended = true})
surface.CreateFont("TLib2.Abs.FA.7", {font = "Font Awesome 5 Free Solid", size = 14, antialias = true, extended = true})

local function handleScreenSizeChange()
    local iH = ScrH()

    -- Responsive fonts
    surface.CreateFont("TLib2.1", {font = "Rajdhani Bold", size = math.Round(iH * (60 * 0.001)), weight = 600, antialias = true})
    surface.CreateFont("TLib2.2", {font = "Rajdhani Bold", size = math.Round(iH * (42 * 0.001)), weight = 600, antialias = true})
    surface.CreateFont("TLib2.3", {font = "Rajdhani Bold", size = math.Round(iH * (36 * 0.001)), weight = 600, antialias = true})
    surface.CreateFont("TLib2.4", {font = "Rajdhani Bold", size = math.Round(iH * (30 * 0.001)), weight = 600, antialias = true})
    surface.CreateFont("TLib2.5", {font = "Rajdhani Bold", size = math.Round(iH * (22 * 0.001)), weight = 550, antialias = true})
    surface.CreateFont("TLib2.6", {font = "Rajdhani Regular", size = math.Round(iH * (21 * 0.001)), weight = 550, antialias = true})
    surface.CreateFont("TLib2.7", {font = "Rajdhani Regular", size = math.Round(iH * (19 * 0.001)), weight = 550, antialias = true})

    -- Font Awesome (responsive/solid)
    surface.CreateFont("TLib2.FA.1", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (80 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.2", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (48 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.3", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (32 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.4", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (24 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.5", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (18 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.6", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (16 * 0.001)), antialias = true, extended = true})
    surface.CreateFont("TLib2.FA.7", {font = "Font Awesome 5 Free Solid", size = math.Round(iH * (14 * 0.001)), antialias = true, extended = true})

    TLib2.BorderRadius = math.Round(iH * 0.006)

    TLib2.Padding1 = math.Round(iH * 0.06)
    TLib2.Padding2 = math.Round(iH * 0.025)
    TLib2.Padding3 = math.Round(iH * 0.01)
    TLib2.Padding4 = math.Round(iH * 0.005)
end

handleScreenSizeChange()

hook.Add("OnScreenSizeChanged", "TLib2:Fonts:OnScreenSizeChanged", handleScreenSizeChange)

---`🔸 Client`<br>
---Returns a character from a character unicode, used for Font Awesome icons
---@param sUnicode string @The character unicode
---@return string @The character
function TLib2.GetFAIcon(sUnicode)
    if tFAChars[sUnicode] then
        return tFAChars[sUnicode]
    end

    tFAChars[sUnicode] = utf8.char(tonumber("0x"..sUnicode))
    return tFAChars[sUnicode]
end

---`🔸 Client`<br>
---Returns a character from a character unicode, used for Font Awesome icons in Paint hooks
---@param sUnicode string @The character unicode
---@param sFont string @The font
---@param iX number @The X position
---@param iY number @The Y position
---@param tColor table @The color
---@param iAlignX number @The X alignment
---@param iAlignY number @The Y alignment
---@return number @The text width
---@return number @The text height
function TLib2.DrawFAIcon(sUnicode, sFont, iX, iY, tColor, iAlignX, iAlignY)
    local sFA = tFAChars[sUnicode] or TLib2.GetFAIcon(sUnicode)
    return draw.SimpleText(sFA, sFont, iX, iY, tColor, iAlignX, iAlignY)
end