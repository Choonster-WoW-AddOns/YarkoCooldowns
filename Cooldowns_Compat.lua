local ProcessedAddOns = {
	Blizzard_GarrisonUI = false,
	Blizzard_MajorFactions = false,
	Blizzard_Professions = false,
	Blizzard_PVPUI = false,
	Blizzard_UIWidgets = false,
	WeakAuras = false,
}

local function CheckAddOn(addOnName)
	if C_AddOns.IsAddOnLoaded(addOnName) and not ProcessedAddOns[addOnName] then
		ProcessedAddOns[addOnName] = true
		return true
	end

	return false
end

function YarkoCooldowns.DisableCooldownsForDefaultUIAndAddOns()
	if CheckAddOn("Blizzard_GarrisonUI") then
		-- Ignore the follower experience bar for Covenant Mission rewards.
		-- The follower frames are created on-demand from a frame pool, so we hook the mixin functions before the frames are created.

		local function AdventuresRewardsFollowerMixin_DisableCooldownCount(self)
			self.noCooldownCount = true
		end

		hooksecurefunc(AdventuresRewardsFollowerMixin, "SetFollowerInfo", AdventuresRewardsFollowerMixin_DisableCooldownCount)
		hooksecurefunc(AdventuresRewardsFollowerMixin, "UpdateExperience", AdventuresRewardsFollowerMixin_DisableCooldownCount)
	end

	if CheckAddOn("Blizzard_MajorFactions") then
		-- Ignore the Renown progress bars.
		-- -- MajorFactionRenownFrame is created statically, so we apply the changes directly to the RenownProgressBar frame.
		-- MajorFactionButtonTemplate buttons are created on-demand, so we hook the mixin function before the frames are created.

		-- MajorFactionRenownFrame.HeaderFrame.RenownProgressBar.noCooldownCount = true

		local function MajorFactionButtonMixin_Init(self)
			self.UnlockedState.RenownProgressBar.noCooldownCount = true
		end

		hooksecurefunc(MajorFactionButtonMixin, "Init", MajorFactionButtonMixin_Init)
	end

	if CheckAddOn("Blizzard_Professions") then
		-- Ignore the Professions Specialization progress bars.
		-- ProfessionsFrame is created statically, so we apply the changes directly to the Path ProgressBar frame.
		-- Profession Trait Buttons are created on-demand, so we listen to the TalentButtonAcquired callback.

		ProfessionsFrame.SpecPage.DetailedView.Path.ProgressBar.noCooldownCount = true

		ProfessionsFrame.SpecPage:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonAcquired,
			function(_, talentButton)
				talentButton.ProgressBar.noCooldownCount = true
			end)

		ProfessionsFrame.SpecPage:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonReleased,
			function(_, talentButton)
				talentButton.ProgressBar.noCooldownCount = nil
			end)

		for talentButton in ProfessionsFrame.SpecPage:EnumerateAllTalentButtons() do
			talentButton.ProgressBar.noCooldownCount = true
		end
	end

	if CheckAddOn("Blizzard_PVPUI") then
		-- Ignore the Honor Level display.
		-- PVPUIFrame is created statically, so we apply the changes directly to the HonorLevelDisplay frame.

		PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.noCooldownCount = true
	end

	if not ProcessedAddOns.Blizzard_UIWidgets then
		-- Ignore the UIWidgetBaseCircularStatusBarTemplate used by UIWidgetTemplateDiscreteProgressSteps for The Eye of the Jailer in the Maw.
		-- Ignore the UIWidgetBaseControlZoneTemplate used by UIWidgetTemplateCaptureZone/UIWidgetTemplateZoneControl for what seems to be an event in the Sophia's Overture subzone of Bastion.
		-- UIWidgets are created on-demand from frame pools, so we hook the mixin functions before the frames are created.

		ProcessedAddOns.Blizzard_UIWidgets = true

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

	if CheckAddOn("WeakAuras") then
		-- Provide function to ignore WeakAuras icon cooldowns
		function YarkoCooldowns.WeakAurasIcon_DisableCooldownCount(region)
			local cooldown = region.cooldown
			if cooldown then
				cooldown.noCooldownCount = true
			end
		end
	end
end
