local type = type
local math = math
local render = render
local surface = surface

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

---`🔸 Client`<br>
---Draws a dashed box
---@param iX number @The x position
---@param iY number @The y position
---@param iW number @The width
---@param iH number @The height
---@param iSegLen number @The length of each segment
---@param iSpacing number @The spacing between each segment
---@param iThickness number @The thickness of the box
---@param oColor Color @The color
function TLib2.DrawDashedBox(iX, iY, iW, iH, iSegLen, iSpacing, iThickness, oColor)
    surface.SetDrawColor(oColor)

    for i = 0, math.floor(iW / (iSegLen + iSpacing)) do
        local iSegX = iX + ((iSegLen + iSpacing) * i)
        local iLen = iSegLen
        if ((iSegX + iSegLen) > (iX + iW)) then
            iLen = (iX + iW - iSegX)
        end

        surface.DrawRect(iSegX, iY, iLen, iThickness)
        surface.DrawRect(iSegX, iY + iH - iThickness, iLen, iThickness)
    end

    for i = 0, math.floor(iH / (iSegLen + iSpacing)) do
        local iSegY = iY + ((iSegLen + iSpacing) * i)
        local iLen = iSegLen
        if ((iSegY + iSegLen) > (iY + iH)) then
            iLen = (iY + iH - iSegY)
        end

        surface.DrawRect(iX, iSegY, iThickness, iLen)
        surface.DrawRect(iX + iW - iThickness, iSegY, iThickness, iLen)
    end
end