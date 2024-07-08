---`🔸 Client`<br>
---Manipulates the color's lightness and saturation
---@param tCol Color @The color
---@param fLightnessFactor? number @The lightness factor, defaults to 1
---@param fSaturationMul? number @The saturation factor, defaults to 1
---@return Color
function TLib2.ColorManip(tCol, fSaturationMul, fLightnessFactor)
    local fH, fS, fL = tCol:ToHSL()
    return HSLToColor(fH, fS * (fSaturationMul or 1), fL * (fLightnessFactor or 1))
end

---`🔸 Client`<br>
---Draws a stencil mask
---@param fnMask function @The mask function
---@param fnContent function @The content function
function TLib2.QuickMask(fnMask, fnContent)
    render.SetStencilEnable(true)
        render.ClearStencil()
        render.SetStencilTestMask(255)
        render.SetStencilWriteMask(255)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
        render.SetStencilReferenceValue(9)
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)

        if (type(fnMask) == "function") then
            fnMask()
        end

        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

        if (type(fnContent) == "function") then
            fnContent()
        end
    render.SetStencilEnable(false)
end
