local type = type
local math = math
local render = render
local surface = surface
local matBlur = Material("pp/blurscreen", "noclamp smooth")

local pLP

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

function TLib2.DrawOutlinedBox(iX, iY, iW, iH, iThickness, oColor)
    surface.SetDrawColor(oColor)

    surface.DrawRect(0, 0, iThickness, iH)
    surface.DrawRect(iThickness, 0, iW - (iThickness * 2), iThickness)
    surface.DrawRect(iW - iThickness, 0, iThickness, iH)
    surface.DrawRect(iThickness, (iH - iThickness), iW - (iThickness * 2), iThickness)
end


---`🔸 Client`<br>
---Plays a UI sound
---@param sSound string @The sound
---@param fVolume? number @The volume, defaults to 1
---@param iPitch? number @The pitch, defaults to 100
function TLib2.PlayUISound(sSound, fVolume, iPitch)
    pLP = pLP or LocalPlayer()
    if not pLP or not pLP:IsValid() then return end

    pLP:EmitSound(sSound, 100, (iPitch or 100), (fVolume or 1))
end

---`🔸 Client`<br>
---Blurs a panel
---@param dPanel Panel @The panel
---@param fAmount number @The amount
function TLib2.Blur(dPanel, fAmount)
    local iX, iY = dPanel:LocalToScreen(0, 0)
    local iScrW, iScrH = ScrW(), ScrH()

    fAmount = (fAmount or 2)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(matBlur)
    
    for i = 1, 3 do
        matBlur:SetFloat("$blur", (i / 3) * fAmount)
        matBlur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect((iX * -1), (iY * -1), iScrW, iScrH)
    end
end