local PANEL = {}

local surface = surface
local draw = draw
local math = math

local matGradU = Material("vgui/gradient-u")

function PANEL:DrawNotches(level, x, y, w, h, range, value, min, max)
	local size = level * self:GetZoom()
	if (size < 5) then return end
	if (size > w * 2) then return end

	local alpha = 255

	if (size < 150) then alpha = alpha * ((size - 2) / 140) end
	if (size > (w * 2) - 100) then alpha = alpha * (1 - ((size - (w - 50)) / 50)) end

	local halfw = w * 0.5
	local span = math.ceil(w / size)
	local realmid = x + w * 0.5 - (value * self:GetZoom())
	local mid = x + w * 0.5 - math.fmod(value * self:GetZoom(), size)
	local top = h * 0.4
	local nh = h - top

	local frame_min = math.floor(realmid + min * self:GetZoom())
	local frame_width = math.ceil(range * self:GetZoom())
	local targetW = math.min(w - math.max(0, frame_min - x), frame_width - math.max(0, x - frame_min))

	surface.SetDrawColor(ColorAlpha(TLib2.Colors.Base4, alpha))
	surface.DrawRect(math.max(x, frame_min), y + top, targetW, 2)
	surface.SetFont("TLib2.7")

	for n = -span, span, 1 do
		local nx = mid + n * size
		if (nx > x + w or nx < x) then continue end

		local dist = 1 - (math.abs(halfw - nx + x) / w)
		local val = (nx - realmid) / self:GetZoom()

		if (val <= min + 0.001) then continue end
		if (val >= max - 0.001) then continue end

		surface.SetDrawColor(ColorAlpha(TLib2.Colors.Base4, alpha * dist))
		surface.SetTextColor(ColorAlpha(TLib2.Colors.Base4, alpha * dist))
		surface.DrawRect(nx, y + top, 2, nh)

		local tw, th = surface.GetTextSize(val)
		surface.SetTextPos(nx - (tw * 0.5), y + top - th)
		surface.DrawText(val)
	end

	surface.SetDrawColor(ColorAlpha(TLib2.Colors.Base4, alpha))
	surface.SetTextColor(ColorAlpha(TLib2.Colors.Base3, alpha))

	-- Draw the last one.
	local nx = realmid + max * self:GetZoom()
	if (nx < x + w) then
		surface.DrawRect(nx, y + top, 2, nh)

		local val = max
		local tw, th = surface.GetTextSize(val)

		surface.SetTextPos(nx - (tw * 0.5), y + top - th)
		surface.DrawText(val)
	end

	-- Draw the first
	local nx = realmid + min * self:GetZoom()
	if (nx > x) then
		surface.DrawRect(nx, y + top, 2, nh)

		local val = min
		local tw, th = surface.GetTextSize(val)

		surface.SetTextPos(nx - (tw * 0.5), y + top - th)
		surface.DrawText(val)
	end
end

function PANEL:DrawScreen(x, y, w, h)
	if not self:GetShouldDrawScreen() then return end

	local wasEnabled = DisableClipping(true)
	local min = self:GetMin()
	local max = self:GetMax()
	local range = self:GetMax() - self:GetMin()
	local value = self:GetFloatValue()

	-- Background
	surface.SetDrawColor(TLib2.Colors.Base0)
    surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(TLib2.Colors.Base1)
	surface.SetMaterial(matGradU)
	surface.DrawTexturedRect(x, y, w, h )

	-- Background colour block
	surface.SetDrawColor(TLib2.Colors.Base1)
	local targetX = x + w * 0.5 - ((value - min) * self:GetZoom())
	local targetW = range * self:GetZoom()
	targetW = targetW - math.max(0, x - targetX)
	targetW = math.min(targetW, w - math.max(0, targetX - x))
	surface.DrawRect(math.max(targetX, x) + 3, y + h * 0.4, targetW - 6, h * 0.6)

	for i = 1, 4 do
		self:DrawNotches(10 ^ i, x, y, w, h, range, value, min, max)
	end

	for i = 0, self:GetDecimals() do
		self:DrawNotches(1 / 10 ^ i, x, y, w, h, range, value, min, max)
	end

	surface.SetDrawColor(TLib2.Colors.Accent)
	surface.DrawLine(x + (w * 0.5), y, x + (w * 0.5), y + h)

	-- Text Value
	surface.SetFont("TLib2.6")
	local str = string.Comma(self:GetTextValue())
	local tw, th = surface.GetTextSize(str)

	draw.RoundedBoxEx(TLib2.BorderRadius, x + ((w - tw) * 0.5) - (TLib2.Padding2 * 0.5), y + h - th, tw + TLib2.Padding2, th, TLib2.Colors.Accent, true, true, false, false)

	surface.SetTextColor(TLib2.Colors.Base4)
	surface.SetTextPos(x + ((w - tw) * 0.5), y + h - th)
	surface.DrawText(str)
	
	surface.SetDrawColor(TLib2.Colors.Base2)
	surface.DrawOutlinedRect(x, y, w, h)

	DisableClipping(wasEnabled)
end

vgui.Register("TLib2:NumScratch", PANEL, "DNumberScratch")