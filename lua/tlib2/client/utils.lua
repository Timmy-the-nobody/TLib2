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
