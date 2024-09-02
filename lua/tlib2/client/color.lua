---`🔸 Client`<br>
---@enum TLib2.Color @The color enum
TLib2.Colors = {
    Base0 = Color(13, 17, 23, 255),
    Base1 = Color(22, 27, 34, 255),
    Base2 = Color(33, 38, 45, 255),
    Base3 = Color(137, 146, 155, 255),
    Base4 = Color(236, 242, 248, 255),
    Accent = Color(68, 147, 248),
    Action = Color(41,144,59),
    Warn = Color(200, 70, 60),
}

---`🔸 Client`<br>
---Manipulates the color's lightness and saturation
---@param oColor Color @The color
---@param fLightnessFactor? number @The lightness factor, defaults to 1
---@param fSaturationMul? number @The saturation factor, defaults to 1
---@return Color
function TLib2.ColorManip(oColor, fSaturationMul, fLightnessFactor)
    local fH, fS, fL = oColor:ToHSL()
    return HSLToColor(fH, fS * (fSaturationMul or 1), fL * (fLightnessFactor or 1))
end