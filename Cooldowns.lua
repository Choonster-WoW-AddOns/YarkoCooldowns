YarkoCooldowns = {}

--- @class LuaDurationObject : ScriptObject
--- @field SetTimeFromStart fun(self: LuaDurationObject, startTime: number, duration: number, modRate?: number)
--- @field GetRemainingDuration fun(self: LuaDurationObject, modifier?: Enum.DurationTimeModifier): number
--- @field Reset fun(self: LuaDurationObject)

--- @class YarkoCooldownsCounter : Frame
--- @field duration LuaDurationObject?
--- @field cooldown Cooldown
--- @field bt4Frame Frame?
--- @field filtername string
--- @field flag boolean
--- @field oldflag boolean
--- @field textMain FontString
--- @field textAlternate FontString

--- @class Cooldown
--- @field GetParent fun(): Frame -- Assume that Cooldown objects always have a parent
--- @field noCooldownCount boolean?

--- @class ActionButton : CheckButton
--- @field action number?
--- @field spellID number?

YarkoCooldowns.DefaultMainColor = NORMAL_FONT_COLOR
YarkoCooldowns.DefaultFlash = "Y"
YarkoCooldowns.DefaultFlashSeconds = 3
YarkoCooldowns.DefaultAlternate = 1
YarkoCooldowns.DefaultFlashColor = { r = 1.0, g = 0, b = 0 }
YarkoCooldowns.DefaultFontLocation = "Fonts"
YarkoCooldowns.DefaultFontFile = "FRIZQT__.TTF"
YarkoCooldowns.DefaultFontHeight = 26
YarkoCooldowns.DefaultShadow = "N"
YarkoCooldowns.DefaultOutline = 3
YarkoCooldowns.DefaultTenths = "N"
YarkoCooldowns.DefaultBelowTwo = "N"
YarkoCooldowns.DefaultSeconds = 60
YarkoCooldowns.DefaultMinimum = 1.5
YarkoCooldowns.DefaultSize = 27

--- @type table<Cooldown, YarkoCooldownsCounter>
YarkoCooldowns.CooldownFrames = {}

--- @type table<Cooldown, YarkoCooldownsCounter>
local ActiveCounters = {}

local TimeSinceLastUpdate = 1
local UpdateInterval = .1

local TimeSinceLastFlash = 0
local FlashInterval = .3
local FlashFlag = false

local UseAlternateColorBelowThreshold = false
local FlashBelowThreshold = false

--- @type ColorRGBData, ColorRGBData
local MainColor, AlternateColor

local Scales = {
	[1] = 1,
	[2] = .85,
	[3] = .65,
	[4] = .5
}

local SpecialAddon

local OutlineList = { nil, "OUTLINE", "THICKOUTLINE" }

---@type NumberAbbrevOptions
local CooldownAbbreviateOptions = {
	-- CreateAbbreviateConfig only seems to support breakpoints that are powers of 10 (despite the error message saying multiples of 10), so use a plain table instead
	breakpointData = {}
}

local MainTextAlphaCurve = C_CurveUtil.CreateCurve()
MainTextAlphaCurve:SetType(Enum.LuaCurveType.Step)

local AlternateTextAlphaCurve = C_CurveUtil.CreateCurve()
AlternateTextAlphaCurve:SetType(Enum.LuaCurveType.Step)

function YarkoCooldowns.Test()
	for k, v in pairs(ActiveCounters) do
		print(k, v, v:GetName())
	end
end

function YarkoCooldowns.OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
end

function YarkoCooldowns.OnEvent(_, event, ...)
	if event == "ADDON_LOADED" then
		YarkoCooldowns.DisableCooldownsForDefaultUIAndAddOns()

		return
	end

	if event == "PLAYER_LOGIN" then
		SpecialAddon = Bartender4

		YarkoCooldowns.OptionsSetup()

		-- Does not work with addons that call SetCooldown() directly
		--hooksecurefunc("CooldownFrame_SetTimer", YarkoCooldowns.CooldownSetTimer)

		-- So hook directly to the cooldown widget function
		hooksecurefunc(getmetatable(ActionButton1.cooldown).__index, "SetCooldown", YarkoCooldowns.SetCooldown)
		hooksecurefunc(getmetatable(ActionButton1.cooldown).__index, "Clear", YarkoCooldowns.ClearCooldown)

		YarkoCooldowns.DisableCooldownsForDefaultUIAndAddOns()

		YarkoCooldowns.UpdateCooldownAbbreviateOptions()
		YarkoCooldowns.CacheOptions()

		return
	end

	-- TODO: Is this needed? default UI should apply its own cooldowns
	-- if event == "ACTIONBAR_UPDATE_COOLDOWN" then
	-- 	for _, button in ipairs(ActionBarButtonEventsFrame.frames) do
	-- 		if button.cooldown:IsVisible() then
	-- 			local start, duration
	-- 			local cooldownInfo

	-- 			if button.spellID then
	-- 				cooldownInfo = C_Spell.GetSpellCooldown(button.spellID)
	-- 			else
	-- 				cooldownInfo = C_ActionBar.GetActionCooldown(button.action)
	-- 			end

	-- 			if start > 0 then
	-- 				YarkoCooldowns.StartCooldown(button.cooldown, start, duration,
	-- 					(duration > 0 and duration < 1 and 0) or 1)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function YarkoCooldowns.UpdateCooldownAbbreviateOptions()
	---@type NumberAbbreviationBreakpoint
	local hourConfig = YarkoCooldowns_SavedVars.Tenths == "Y" and {
		breakpoint = 3600,
		abbreviation = "h",
		significandDivisor = 360,
		fractionDivisor = 10,
		abbreviationIsGlobal = false,
	} or {
		breakpoint = 3600,
		abbreviation = "h",
		significandDivisor = 3600,
		fractionDivisor = 1,
		abbreviationIsGlobal = false,
	}

	---@type NumberAbbreviationBreakpoint
	local minuteConfig = YarkoCooldowns_SavedVars.Tenths == "Y" and {
		breakpoint = 60,
		abbreviation = "m",
		significandDivisor = 6,
		fractionDivisor = 10,
		abbreviationIsGlobal = false,
	} or {
		breakpoint = 60,
		abbreviation = "m",
		significandDivisor = 60,
		fractionDivisor = 1,
		abbreviationIsGlobal = false,
	}

	---@type NumberAbbreviationBreakpoint
	local secondConfig = {
		breakpoint = 2,
		abbreviation = "",
		significandDivisor = 1,
		fractionDivisor = 1,
		abbreviationIsGlobal = false,
	}

	---@type NumberAbbreviationBreakpoint
	local belowTwoConfig = YarkoCooldowns_SavedVars.BelowTwo == "Y" and {
		breakpoint = 0,
		abbreviation = "",
		significandDivisor = 0.1,
		fractionDivisor = 10,
		abbreviationIsGlobal = false,
	} or {
		breakpoint = 0,
		abbreviation = "",
		significandDivisor = 1,
		fractionDivisor = 1,
		abbreviationIsGlobal = false,
	}

	local breakpointData = CooldownAbbreviateOptions.breakpointData
	breakpointData[1] = hourConfig
	breakpointData[2] = minuteConfig
	breakpointData[3] = secondConfig
	breakpointData[4] = belowTwoConfig
end

function YarkoCooldowns.CacheOptions()
	UseAlternateColorBelowThreshold = YarkoCooldowns_SavedVars.Flash == "Y"
	FlashBelowThreshold = UseAlternateColorBelowThreshold and YarkoCooldowns_SavedVars.Alternate == 1

	MainColor = YarkoCooldowns_SavedVars.MainColor
	AlternateColor = YarkoCooldowns_SavedVars.FlashColor

	if UseAlternateColorBelowThreshold then
		-- When the remaining duration is <= FlashSeconds, hide the main text and show the alternate text
		MainTextAlphaCurve:SetPoints({
			{ x = 0,                                              y = 0 },
			{ x = YarkoCooldowns_SavedVars.FlashSeconds + 0.0001, y = 1 }
		})

		AlternateTextAlphaCurve:SetPoints({
			{ x = 0,                                              y = 1 },
			{ x = YarkoCooldowns_SavedVars.FlashSeconds + 0.0001, y = 0 }
		})
	else
		MainTextAlphaCurve:ClearPoints()
		AlternateTextAlphaCurve:ClearPoints()
	end
end

--- Get the cooldown for an action button as a Duration object, or nil if it's on GCD. Based on ActionButton_UpdateCooldown.
--- @param self ActionButton
--- @return LuaDurationObject?
function YarkoCooldowns.GetCooldownDuration(self)
	local actionType, actionID

	if self.action then
		actionType, actionID = GetActionInfo(self.action)
	end

	local auraData
	local passiveCooldownSpellID
	local onEquipPassiveSpellID

	if actionID then
		onEquipPassiveSpellID = C_ActionBar.GetItemActionOnEquipSpellID(self.action)
	end

	if onEquipPassiveSpellID then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(onEquipPassiveSpellID)
	elseif actionType == "spell" and actionID then
		---@cast actionID number
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(actionID)
	elseif self.spellID then
		passiveCooldownSpellID = C_UnitAuras.GetCooldownAuraBySpellID(self.spellID)
	end

	if passiveCooldownSpellID and passiveCooldownSpellID ~= 0 then
		auraData = C_UnitAuras.GetPlayerAuraBySpellID(passiveCooldownSpellID);
	end

	if auraData then
		local duration = C_UnitAuras.GetAuraDuration("player", auraData.auraInstanceID)
		return duration
	elseif self.spellID then
		local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID)
		if cooldownInfo.isOnGCD then
			return nil
		end

		local duration = C_Spell.GetSpellCooldownDuration(self.spellID)
		return duration
	else
		local cooldownInfo = C_ActionBar.GetActionCooldown(self.action)
		if cooldownInfo.isOnGCD then
			return nil
		end

		local duration = C_ActionBar.GetActionCooldownDuration(self.action)
		return duration
	end
end

---
---@param self Cooldown
---@param start number
---@param duration number
---@param modRate number?
function YarkoCooldowns.SetCooldown(self, start, duration, modRate)
	-- print("YarkoCooldowns.SetCooldown", self:GetName(), start, duration, modRate)
	if not self.noCooldownCount --[[and start > 0]] then
		YarkoCooldowns.StartCooldown(self, start, duration, modRate --[[, (duration > 0 and duration < 1 and 0) or 1]])
	end
end

---
---@param self Cooldown
---@param start number
---@param duration number
---@param modRate number?
function YarkoCooldowns.StartCooldown(self, start, duration, modRate --[[, enable ]])
	-- print("YarkoCooldowns.StartCooldown", self:GetName(), start, duration, modRate)

	local parent = self:GetParent() --[[@as Frame | ActionButton]]

	if parent.action or parent.spellID
	-- (
	-- 		start > 0 and enable > 0 and duration > 1.5 -- TODO: Can't compare secrets
	-- 		and
	-- 		(start + duration - GetTime() - .01 > YarkoCooldowns_SavedVars.Minimum or
	-- 			ActiveCounters[self]
	-- 		)
	-- 	)
	then
		---@cast parent ActionButton

		local frame = YarkoCooldowns.CooldownFrames[self]

		if not frame then
			local parentName = parent:GetName()
			local name, bt4Frame

			if parentName then
				name = "YarkoCooldowns" .. parentName
				bt4Frame = SpecialAddon and parentName:sub(1, 3) == "BT4"
			end

			-- For Bartender, don't parent counter to cooldown so that button can be made transparent and cooldown still visible
			frame = CreateFrame("Frame", name, not bt4Frame and self or nil, "YarkoCooldowns_CounterTemplate") --[[@as YarkoCooldownsCounter]]
			frame:SetPoint("CENTER", parent, "CENTER")

			print("Created frame", name or "<no name>", "for", parentName or parent)

			if bt4Frame then
				frame:SetFrameStrata(parent:GetFrameStrata())
			end

			frame:SetFrameLevel(self:GetFrameLevel() + 5)

			self:HookScript("OnShow", function(self) YarkoCooldowns.CooldownFrames[self]:Show() end)
			self:HookScript("OnHide", function(self) YarkoCooldowns.CooldownFrames[self]:Hide() end)

			YarkoCooldowns.UpdateFont(frame)
			frame:Show()

			frame.cooldown = self
			frame.bt4Frame = bt4Frame
			frame.filtername = YarkoCooldowns.GetParentFrame(parent --[[ :GetParent() ]])

			YarkoCooldowns.CooldownFrames[self] = frame
		end

		frame.duration = YarkoCooldowns.GetCooldownDuration(parent)
		-- frame.start = start
		-- frame.duration = duration
		-- frame.enable = enable
		frame.flag = false

		ActiveCounters[self] = frame
	else

	end
end

---
---@param self Cooldown
function YarkoCooldowns.ClearCooldown(self)
	-- print("YarkoCooldowns.ClearCooldown", self:GetName(), ActiveCounters[self])
	if ActiveCounters[self] then
		ActiveCounters[self].duration = nil
		ActiveCounters[self].textMain:SetText("")
		ActiveCounters[self].textAlternate:SetText("")
		ActiveCounters[self] = nil
	end
end

function YarkoCooldowns.OnUpdate(_, elapsed)
	TimeSinceLastFlash = TimeSinceLastFlash + elapsed

	if TimeSinceLastFlash > FlashInterval then
		FlashFlag = not FlashFlag
		TimeSinceLastFlash = 0
	end

	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed

	if TimeSinceLastUpdate > UpdateInterval then
		for cooldown, frame in pairs(ActiveCounters) do
			if frame.duration then
				-- May be secret
				local timeLeft = frame.duration:GetRemainingDuration()

				local counterTextMain = frame.textMain
				local counterTextAlternate = frame.textAlternate

				if --[[ timeLeft > 0 and frame.enable > 0]] true then
					local parent = cooldown:GetParent()
					local parentframe = frame.filtername

					if parentframe and not YarkoCooldowns_SavedVars.ParentFrames[parentframe] then
						YarkoCooldowns_SavedVars.ParentFrames[parentframe] = "Y"
					end

					if YarkoCooldowns.Round(parent:GetWidth()) * parent:GetEffectiveScale() / UIParent:GetScale() >=
						YarkoCooldowns_SavedVars.Size
						and not cooldown.noCooldownCount
						and cooldown:IsVisible() and parent:GetEffectiveAlpha() > 0
						and (not parentframe or YarkoCooldowns_SavedVars.ParentFrames[parentframe] ~= "N")
					then
						-- May be secret
						local text = AbbreviateNumbers(timeLeft, CooldownAbbreviateOptions)

						-- if timeLeft > 3600 then
						-- 	line1 = YarkoCooldowns_SavedVars.Tenths == "Y"
						-- 		and YarkoCooldowns.TrimZeros(("%.1f"):format((timeLeft + 180) / 3600))
						-- 		or ("%d"):format(ceil(timeLeft / 3600))
						-- 	line2 = "h"
						-- elseif timeLeft > YarkoCooldowns_SavedVars.Seconds then
						-- 	line1 = ((YarkoCooldowns_SavedVars.Tenths == "Y"
						-- 			and YarkoCooldowns.TrimZeros(("%.1f"):format((timeLeft + 3) / 60)))
						-- 		or ("%d"):format(ceil(timeLeft / 60)))
						-- 	line2 = "m"
						-- else
						-- 	line1 = ((timeLeft <= 2 and YarkoCooldowns_SavedVars.BelowTwo == "Y"
						-- 			and ("%.1f"):format(timeLeft + 0.05))
						-- 		or ("%d"):format(ceil(timeLeft)))
						-- 	line2 = ""
						-- end

						-- length = #line1

						-- if #line2 > 0 and length == 1 then
						-- 	line1 = line1 .. line2
						-- 	line2 = ""
						-- 	length = length + 1
						-- end

						if --[[ line1 ~= counterText1:GetText() or line2 ~= counterText2:GetText() ]] true then
							-- if length > 4 then
							-- 	length = 4
							-- end

							-- frame:SetScale(
							-- 	Scales[length] * parent:GetWidth() / ActionButton1:GetWidth()
							-- 	* (frame.bt4Frame and parent:GetEffectiveScale() or 1)
							-- 	* (#line2 > 0 and length == 2 and 0.8 or 1)
							-- 	* (timeLeft <= 2 and YarkoCooldowns_SavedVars.BelowTwo == "Y" and 0.95 or 1)
							-- )

							-- counterText1:ClearAllPoints()

							-- local x = length == 4 and 4 or 2

							if --[[ #line2 < 1 ]] true then
								counterTextMain:SetPoint("CENTER", frame, "CENTER", --[[ x ]] 2, -3)
								counterTextAlternate:SetPoint("CENTER", frame, "CENTER", --[[ x ]] 2, -3)
							else
								-- counterText1:SetPoint("BOTTOM", frame, "TOP", x, -23)
							end

							counterTextMain:SetText(text)
							counterTextAlternate:SetText(text)
							-- counterText2:SetText(line2)
						end

						-- if timeLeft <= YarkoCooldowns_SavedVars.FlashSeconds and YarkoCooldowns_SavedVars.Flash == "Y" then
						-- 	if YarkoCooldowns_SavedVars.Alternate == 1 then
						-- 		frame.flag = FlashFlag
						-- 	else
						-- 		if not frame.flag then
						-- 			frame.flag = true
						-- 			frame.oldflag = false
						-- 		end
						-- 	end
						-- else
						-- 	if frame.flag then
						-- 		frame.flag = false
						-- 		frame.oldflag = true
						-- 	end
						-- end

						-- if frame.flag ~= frame.oldflag then
						-- 	YarkoCooldowns.SetCounterColor(counterText1, frame.flag)
						-- 	YarkoCooldowns.SetCounterColor(counterText2, frame.flag)
						-- 	frame.oldflag = frame.flag
						-- end

						if UseAlternateColorBelowThreshold then
							local mainAlpha = frame.duration:EvaluateRemainingDuration(MainTextAlphaCurve)
							local alternateAlpha = frame.duration:EvaluateRemainingDuration(AlternateTextAlphaCurve)

							counterTextMain:SetAlpha(mainAlpha)
							counterTextAlternate:SetAlpha(alternateAlpha)

							if FlashBelowThreshold then
								YarkoCooldowns.SetCounterColor(counterTextAlternate, FlashFlag)
							else
								YarkoCooldowns.SetCounterColor(counterTextAlternate, true)
							end
						else
							counterTextMain:SetAlpha(1)
							counterTextAlternate:SetAlpha(0)
						end
					else
						counterTextMain:SetText("")
						counterTextAlternate:SetText("")
					end
				else
					counterTextMain:SetText("")
					counterTextAlternate:SetText("")
					ActiveCounters[cooldown] = nil
				end
			end
		end

		TimeSinceLastUpdate = 0
	end
end

-- function YarkoCooldowns.TrimZeros(inStr)
-- 	local outStr = ""
-- 	local str = ""

-- 	for i = 1, #inStr do
-- 		if inStr:sub(i, i) ~= "0" then
-- 			str = inStr:sub(i)
-- 			break
-- 		end
-- 	end

-- 	for i = #str, 1, -1 do
-- 		if str:sub(i, i) == "." then
-- 			outStr = str:sub(1, i - 1)
-- 			break
-- 		end

-- 		if str:sub(i, i) ~= "0" then
-- 			outStr = str:sub(1, i)
-- 			break
-- 		end
-- 	end

-- 	return outStr
-- end

---
--- @param cooldownFrame YarkoCooldownsCounter
function YarkoCooldowns.UpdateFont(cooldownFrame)
	local counterTextMain = cooldownFrame.textMain
	local counterTextAlternate = cooldownFrame.textAlternate

	if YarkoCooldowns_SavedVars.Shadow == "Y" then
		counterTextMain:SetShadowOffset(1, -1)
		counterTextAlternate:SetShadowOffset(1, -1)
	else
		counterTextMain:SetShadowOffset(0, 0)
		counterTextAlternate:SetShadowOffset(0, 0)
	end

	counterTextMain:SetFont(
		YarkoCooldowns_SavedVars.FontLocation .. "\\" .. YarkoCooldowns_SavedVars.FontFile,
		YarkoCooldowns_SavedVars.FontHeightX,
		OutlineList[YarkoCooldowns_SavedVars.Outline]
	)

	counterTextAlternate:SetFont(
		YarkoCooldowns_SavedVars.FontLocation .. "\\" .. YarkoCooldowns_SavedVars.FontFile,
		YarkoCooldowns_SavedVars.FontHeightX,
		OutlineList[YarkoCooldowns_SavedVars.Outline]
	)

	YarkoCooldowns.SetCounterColor(counterTextMain, false)
	YarkoCooldowns.SetCounterColor(counterTextAlternate, false)
end

function YarkoCooldowns.SetCounterColor(counterText, useAlternate)
	if not useAlternate then
		counterText:SetTextColor(
			MainColor.r,
			MainColor.g,
			MainColor.b
		)
	else
		counterText:SetTextColor(
			AlternateColor.r,
			AlternateColor.g,
			AlternateColor.b
		)
	end
end

function YarkoCooldowns.GetParentFrame(frame)
	local name

	repeat
		name = frame:GetName()
		frame = frame:GetParent()
	until name or not frame

	return name == "UIParent" and nil or name
end

function YarkoCooldowns.Round(num)
	return math.floor(num + 0.5)
end
