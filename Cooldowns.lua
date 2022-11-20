YarkoCooldowns = {}

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

YarkoCooldowns.CooldownFrames = {}


local ActiveCounters = {}

local TimeSinceLastUpdate = 1
local UpdateInterval = .1

local TimeSinceLastFlash = 0
local FlashInterval = .3
local FlashFlag = false

local Scales = {
	[1] = 1,
	[2] = .85,
	[3] = .65,
	[4] = .5
}

local SpecialAddon

local OutlineList = { nil, "OUTLINE", "THICKOUTLINE" }

local ProcessedDefaultUIAddOns = {
	Blizzard_GarrisonUI = false,
	Blizzard_MajorFactions = false,
	Blizzard_Professions = false,
	Blizzard_PVPUI = false,
	Blizzard_UIWidgets = false,
}

local function CheckDefaultUIAddOn(addOnName)
	if IsAddOnLoaded(addOnName) and not ProcessedDefaultUIAddOns[addOnName] then
		ProcessedDefaultUIAddOns[addOnName] = true
		return true
	end

	return false
end

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
		local addOnName = ...

		if ProcessedDefaultUIAddOns[addOnName] ~= nil then
			YarkoCooldowns.DisableCooldownsForDefaultUIElements()
		end

		return
	end

	if event == "PLAYER_LOGIN" then
		SpecialAddon = Bartender4

		YarkoCooldowns.OptionsSetup()

		-- Does not work with addons that call SetCooldown() directly
		--hooksecurefunc("CooldownFrame_SetTimer", YarkoCooldowns.CooldownSetTimer)

		-- So hook directly to the cooldown widget function
		hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", YarkoCooldowns.SetCooldown)

		YarkoCooldowns.DisableCooldownsForDefaultUIElements()

		return
	end

	if event == "ACTIONBAR_UPDATE_COOLDOWN" then
		for _, button in ipairs(ActionBarButtonEventsFrame.frames) do
			if button.cooldown:IsVisible() then
				local start, duration

				if button.spellID then
					start, duration = GetSpellCooldown(button.spellID)
				else
					start, duration = GetActionCooldown(button.action)
				end

				if start > 0 then
					YarkoCooldowns.StartCooldown(button.cooldown, start, duration, (duration > 0 and duration < 1 and 0) or 1)
				end
			end
		end
	end
end

function YarkoCooldowns.DisableCooldownsForDefaultUIElements()
	if CheckDefaultUIAddOn("Blizzard_GarrisonUI") then
		-- Ignore the follower experience bar for Covenant Mission rewards.
		-- The follower frames are created on-demand from a frame pool, so we hook the mixin functions before the frames are created.

		local function AdventuresRewardsFollowerMixin_DisableCooldownCount(self)
			self.noCooldownCount = true
		end

		hooksecurefunc(AdventuresRewardsFollowerMixin, "SetFollowerInfo", AdventuresRewardsFollowerMixin_DisableCooldownCount)
		hooksecurefunc(AdventuresRewardsFollowerMixin, "UpdateExperience", AdventuresRewardsFollowerMixin_DisableCooldownCount)
	end

	if CheckDefaultUIAddOn("Blizzard_MajorFactions") then
		-- Ignore the Renown progress bars.
		-- MajorFactionRenownFrame is created statically, so we apply the changes directly to the RenownProgressBar frame.
		-- MajorFactionButtonTemplate buttons are created on-demand, so we hook the mixin function before the frames are created.

		MajorFactionRenownFrame.HeaderFrame.RenownProgressBar.noCooldownCount = true

		local function MajorFactionButtonMixin_Init(self)
			self.UnlockedState.RenownProgressBar.noCooldownCount = true
		end

		hooksecurefunc(MajorFactionButtonMixin, "Init", MajorFactionButtonMixin_Init)
	end

	if CheckDefaultUIAddOn("Blizzard_Professions") then
		-- Ignore the Professions Specialization progress bars.
		-- ProfessionsFrame is created statically, so we apply the changes directly to the Path ProgressBar frame.
		-- Profession Trait Buttons are created on-demand, so we listen to the TalentButtonAcquired callback.

		ProfessionsFrame.SpecPage.DetailedView.Path.ProgressBar.noCooldownCount = true

		ProfessionsFrame.SpecPage:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonAcquired, function(talentButton)
			print('YarkoCooldowns', 'Disabling for new Profession Spec Talent Button', talentButton:GetName() or talentButton)
			talentButton.ProgressBar.noCooldownCount = true
		end)

		ProfessionsFrame.SpecPage:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonReleased, function(talentButton)
			talentButton.ProgressBar.noCooldownCount = nil
		end)

		for talentButton in ProfessionsFrame.SpecPage:EnumerateAllTalentButtons() do
			print('YarkoCooldowns', 'Disabling for existing Profession Spec Talent Button', talentButton:GetName() or talentButton)
			talentButton.ProgressBar.noCooldownCount = true
		end
	end

	if CheckDefaultUIAddOn("Blizzard_PVPUI") then
		-- Ignore the Honor Level display.
		-- PVPUIFrame is created statically, so we apply the changes directly to the HonorLevelDisplay frame.

		PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.noCooldownCount = true
	end

	if not ProcessedDefaultUIAddOns.Blizzard_UIWidgets then
		-- Ignore the UIWidgetBaseCircularStatusBarTemplate used by UIWidgetTemplateDiscreteProgressSteps for The Eye of the Jailer in the Maw.
		-- Ignore the UIWidgetBaseControlZoneTemplate used by UIWidgetTemplateCaptureZone/UIWidgetTemplateZoneControl for what seems to be an event in the Sophia's Overture subzone of Bastion.
		-- UIWidgets are created on-demand from frame pools, so we hook the mixin functions before the frames are created.

		ProcessedDefaultUIAddOns.Blizzard_UIWidgets = true

		local function UIWidgetBaseCircularStatusBar_DisableCooldownCount(self)
			self.noCooldownCount = true
		end

		local function UIWidgetBaseControlZone_DisableCooldownCount(self)
			self.UncapturedSection.noCooldownCount = true
			self.Progress.noCooldownCount = true
		end

		hooksecurefunc(UIWidgetBaseCircularStatusBarTemplateMixin, "Setup", UIWidgetBaseCircularStatusBar_DisableCooldownCount)
		hooksecurefunc(UIWidgetBaseControlZoneTemplateMixin, "Setup", UIWidgetBaseControlZone_DisableCooldownCount)
	end
end

function YarkoCooldowns.SetCooldown(self, start, duration, modRate)
	if not self.noCooldownCount and start > 0 then
		YarkoCooldowns.StartCooldown(self, start, duration, (duration > 0 and duration < 1 and 0) or 1)
	end
end

function YarkoCooldowns.StartCooldown(self, start, duration, enable)
	if (start > 0 and enable > 0 and duration > 1.5
		and (start + duration - GetTime() - .01 > YarkoCooldowns_SavedVars.Minimum or ActiveCounters[self])) then
		local frame = YarkoCooldowns.CooldownFrames[self]

		if not frame then
			local parent = self:GetParent()
			local parentName = parent:GetName()
			local name, bt4Frame

			if parentName then
				name = "YarkoCooldowns" .. parentName
				bt4Frame = SpecialAddon and parentName:sub(1, 3) == "BT4"
			end

			-- For Bartender, don't parent counter to cooldown so that button can be made trasparent and cooldown still visible
			frame = CreateFrame("Frame", name, not bt4Frame and self or nil, "YarkoCooldowns_CounterTemplate")
			frame:SetPoint("CENTER", parent, "CENTER")

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
			frame.filtername = YarkoCooldowns.GetParentFrame(parent:GetParent())

			YarkoCooldowns.CooldownFrames[self] = frame
		end

		frame.start = start
		frame.duration = duration
		frame.enable = enable
		frame.flag = false

		ActiveCounters[self] = frame
	else
		if ActiveCounters[self] then
			ActiveCounters[self].text1:SetText("")
			ActiveCounters[self].text2:SetText("")
			ActiveCounters[self] = nil
		end
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
			local timeLeft = GetTime() > frame.start and frame.start + frame.duration - GetTime() or 0
			local counterText1 = frame.text1
			local counterText2 = frame.text2

			if timeLeft > 0 and frame.enable > 0 then
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
					local line1, line2, length

					if timeLeft > 3600 then
						line1 = YarkoCooldowns_SavedVars.Tenths == "Y"
							and YarkoCooldowns.TrimZeros(("%.1f"):format((timeLeft + 180) / 3600))
							or ("%d"):format(ceil(timeLeft / 3600))
						line2 = "h"
					elseif timeLeft > YarkoCooldowns_SavedVars.Seconds then
						line1 = ((YarkoCooldowns_SavedVars.Tenths == "Y"
							and YarkoCooldowns.TrimZeros(("%.1f"):format((timeLeft + 3) / 60)))
							or ("%d"):format(ceil(timeLeft / 60)))
						line2 = "m"
					else
						line1 = ((timeLeft <= 2 and YarkoCooldowns_SavedVars.BelowTwo == "Y"
							and ("%.1f"):format(timeLeft + 0.05))
							or ("%d"):format(ceil(timeLeft)))
						line2 = ""
					end

					length = #line1

					if #line2 > 0 and length == 1 then
						line1 = line1 .. line2
						line2 = ""
						length = length + 1
					end

					if line1 ~= counterText1:GetText() or line2 ~= counterText2:GetText() then
						if length > 4 then
							length = 4
						end

						frame:SetScale(
							Scales[length] * parent:GetWidth() / ActionButton1:GetWidth()
							* (frame.bt4Frame and parent:GetEffectiveScale() or 1)
							* (#line2 > 0 and length == 2 and 0.8 or 1)
							* (timeLeft <= 2 and YarkoCooldowns_SavedVars.BelowTwo == "Y" and 0.95 or 1)
						)

						counterText1:ClearAllPoints()

						local x = length == 4 and 4 or 2

						if #line2 < 1 then
							counterText1:SetPoint("CENTER", frame, "CENTER", x, -3)
						else
							counterText1:SetPoint("BOTTOM", frame, "TOP", x, -23)
						end

						counterText1:SetText(line1)
						counterText2:SetText(line2)
					end

					if timeLeft <= YarkoCooldowns_SavedVars.FlashSeconds and YarkoCooldowns_SavedVars.Flash == "Y" then
						if YarkoCooldowns_SavedVars.Alternate == 1 then
							frame.flag = FlashFlag
						else
							if not frame.flag then
								frame.flag = true
								frame.oldflag = false
							end
						end
					else
						if frame.flag then
							frame.flag = false
							frame.oldflag = true
						end
					end

					if frame.flag ~= frame.oldflag then
						YarkoCooldowns.SetCounterColor(counterText1, frame.flag)
						YarkoCooldowns.SetCounterColor(counterText2, frame.flag)
						frame.oldflag = frame.flag
					end
				else
					counterText1:SetText("")
					counterText2:SetText("")
				end
			else
				counterText1:SetText("")
				counterText2:SetText("")
				ActiveCounters[cooldown] = nil
			end
		end

		TimeSinceLastUpdate = 0
	end
end

function YarkoCooldowns.TrimZeros(inStr)
	local outStr = ""
	local str = ""

	for i = 1, #inStr do
		if inStr:sub(i, i) ~= "0" then
			str = inStr:sub(i)
			break
		end
	end

	for i = #str, 1, -1 do
		if str:sub(i, i) == "." then
			outStr = str:sub(1, i - 1)
			break
		end

		if str:sub(i, i) ~= "0" then
			outStr = str:sub(1, i)
			break
		end
	end

	return outStr
end

function YarkoCooldowns.UpdateFont(cooldownFrame)
	local counterText1 = cooldownFrame.text1
	local counterText2 = cooldownFrame.text2

	if YarkoCooldowns_SavedVars.Shadow == "Y" then
		counterText1:SetShadowOffset(1, -1)
		counterText2:SetShadowOffset(1, -1)
	else
		counterText1:SetShadowOffset(0, 0)
		counterText2:SetShadowOffset(0, 0)
	end

	counterText1:SetFont(
		YarkoCooldowns_SavedVars.FontLocation .. "\\" .. YarkoCooldowns_SavedVars.FontFile,
		YarkoCooldowns_SavedVars.FontHeightX,
		OutlineList[YarkoCooldowns_SavedVars.Outline]
	)

	counterText2:SetFont(
		YarkoCooldowns_SavedVars.FontLocation .. "\\" .. YarkoCooldowns_SavedVars.FontFile,
		YarkoCooldowns_SavedVars.FontHeightX,
		OutlineList[YarkoCooldowns_SavedVars.Outline]
	)

	YarkoCooldowns.SetCounterColor(counterText1, cooldownFrame.flag or false)
	YarkoCooldowns.SetCounterColor(counterText2, cooldownFrame.flag or false)
end

function YarkoCooldowns.SetCounterColor(counterText, flag)
	if not flag then
		counterText:SetTextColor(
			YarkoCooldowns_SavedVars.MainColor.r,
			YarkoCooldowns_SavedVars.MainColor.g,
			YarkoCooldowns_SavedVars.MainColor.b
		)
	else
		counterText:SetTextColor(
			YarkoCooldowns_SavedVars.FlashColor.r,
			YarkoCooldowns_SavedVars.FlashColor.g,
			YarkoCooldowns_SavedVars.FlashColor.b
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
