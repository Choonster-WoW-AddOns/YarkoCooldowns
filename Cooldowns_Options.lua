---------------------------------------------------
-- Global vars
---------------------------------------------------

YarkoCooldowns_SavedVars = {}


---------------------------------------------------
-- Local vars
---------------------------------------------------

local InGameFonts = {
	"2002.ttf",
	"2002B.ttf",
	"ARHei.ttf",
	"ARIALN.TTF",
	"ARKai_C.ttf",
	"ARKai_T.ttf",
	"bHEI00M.ttf",
	"bHEI01B.ttf",
	"bKAI00M.ttf",
	"bLEI00D.ttf",
	"FRIZQT__.TTF",
	"FRIZQT___CYR.TTF",
	"K_Damage.TTF",
	"K_Pagetext.TTF",
	"MORPHEUS.TTF",
	"MORPHEUS_CYR.TTF",
	"NIM_____.ttf",
	"SKURRI.TTF",
	"SKURRI_CYR.TTF",
}

local IsDropdownCounting = false
local DropdownTimer = 0
local MenuResized = false


---------------------------------------------------
-- YarkoCooldowns.OptionsSetup
---------------------------------------------------
function YarkoCooldowns.OptionsSetup()
	if not YarkoCooldowns_SavedVars.Tenths then
		YarkoCooldowns.OptionsDefault()
	end

	if not YarkoCooldowns_SavedVars.Flash then
		YarkoCooldowns_SavedVars.Flash = YarkoCooldowns.DefaultFlash
	end

	if not YarkoCooldowns_SavedVars.FlashSeconds then
		YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns.DefaultFlashSeconds
	end

	if not YarkoCooldowns_SavedVars.Alternate then
		YarkoCooldowns_SavedVars.Alternate = YarkoCooldowns.DefaultAlternate
	end

	if not YarkoCooldowns_SavedVars.Minimum then
		YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum
	end

	if not YarkoCooldowns_SavedVars.Size then
		YarkoCooldowns_SavedVars.Size = YarkoCooldowns.DefaultSize
	end

	if not YarkoCooldowns_SavedVars.FontHeightX then
		YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns.DefaultFontHeight
		YarkoCooldowns_SavedVars.FontHeight = nil
	end

	if not YarkoCooldowns_SavedVars.ParentFrames then
		YarkoCooldowns_SavedVars.ParentFrames = {}
	end

	local category = Settings.RegisterCanvasLayoutCategory(YarkoCooldowns_OptionsPanel, YARKOCOOLDOWNS_TITLE)
	Settings.RegisterAddOnCategory(category)

	-- Set scroll frame so that it resets the dropdown hide counter
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar:SetScript("OnEnter", YarkoCooldowns.StopCounting)
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar:SetScript("OnLeave", YarkoCooldowns.StartCounting)
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollUpButton:SetScript("OnEnter", YarkoCooldowns.StopCounting)
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollUpButton:SetScript("OnLeave", YarkoCooldowns.StartCounting)
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollDownButton:SetScript("OnEnter", YarkoCooldowns.StopCounting)
	YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollDownButton:SetScript("OnLeave", YarkoCooldowns.StartCounting)

	-- Create invis buttons for scrollbar to hide dropdown
	CreateFrame(
		"Button",
		"YarkoCooldowns_UpButton",
		YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollUpButton,
		"YarkoCooldowns_InvisibleButtonTemplate"
	)

	YarkoCooldowns_UpButton:SetAllPoints(YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollUpButton)

	CreateFrame(
		"Button",
		"YarkoCooldowns_DownButton",
		YarkoCooldowns_FontDropDown.ScrollFrame.ScrollBar.ScrollDownButton,
		"YarkoCooldowns_InvisibleButtonTemplate"
	)

	YarkoCooldowns_DownButton:SetAllPoints(YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollDownButton)

	-- Adjust dropdown field widths
	UIDropDownMenu_SetWidth(YarkoCooldowns_OptionsPanel.GeneralSettings.Alternate, 67)
	UIDropDownMenu_SetWidth(YarkoCooldowns_OptionsPanel.GeneralSettings.Outline, 60)
end

---------------------------------------------------
-- YarkoCooldowns.OptionsDefault
---------------------------------------------------
function YarkoCooldowns.OptionsDefault()
	YarkoCooldowns_SavedVars.MainColor = YarkoCooldowns.CopyColors(YarkoCooldowns.DefaultMainColor)
	YarkoCooldowns_SavedVars.Flash = YarkoCooldowns.DefaultFlash
	YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns.DefaultFlashSeconds
	YarkoCooldowns_SavedVars.Alternate = YarkoCooldowns.DefaultAlternate
	YarkoCooldowns_SavedVars.FlashColor = YarkoCooldowns.CopyColors(YarkoCooldowns.DefaultFlashColor)
	YarkoCooldowns_SavedVars.FontLocation = YarkoCooldowns.DefaultFontLocation
	YarkoCooldowns_SavedVars.FontFile = YarkoCooldowns.DefaultFontFile
	YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns.DefaultFontHeight
	YarkoCooldowns_SavedVars.Shadow = YarkoCooldowns.DefaultShadow
	YarkoCooldowns_SavedVars.Outline = YarkoCooldowns.DefaultOutline
	YarkoCooldowns_SavedVars.Tenths = YarkoCooldowns.DefaultTenths
	YarkoCooldowns_SavedVars.BelowTwo = YarkoCooldowns.DefaultBelowTwo
	YarkoCooldowns_SavedVars.Seconds = YarkoCooldowns.DefaultSeconds
	YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum
	YarkoCooldowns_SavedVars.Size = YarkoCooldowns.DefaultSize

	if YarkoCooldowns_SavedVars.ParentFrames then
		for k, v in pairs(YarkoCooldowns_SavedVars.ParentFrames) do
			YarkoCooldowns_SavedVars.ParentFrames[k] = "Y"
		end
	end

	YarkoCooldowns.UpdateCooldowns()
end

local TempCopy = {}

---------------------------------------------------
-- YarkoCooldowns.OptionsRefresh
---------------------------------------------------
function YarkoCooldowns.OptionsRefresh()
	YarkoCooldowns_OptionsPanel.GeneralSettings.MainColor.ColorSwatch.NormalTexture:SetVertexColor(
		YarkoCooldowns_SavedVars.MainColor.r,
		YarkoCooldowns_SavedVars.MainColor.g,
		YarkoCooldowns_SavedVars.MainColor.b
	)

	YarkoCooldowns_OptionsPanel.GeneralSettings.Flash:SetChecked(YarkoCooldowns_SavedVars.Flash == "Y")
	YarkoCooldowns_OptionsPanel.GeneralSettings.FlashSeconds:SetText(YarkoCooldowns_SavedVars.FlashSeconds)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FlashSeconds:SetCursorPosition(0)

	UIDropDownMenu_Initialize(YarkoCooldowns_OptionsPanel.GeneralSettings.Alternate, YarkoCooldowns.AlternateDropDownInit)

	UIDropDownMenu_SetSelectedValue(
		YarkoCooldowns_OptionsPanel.GeneralSettings.Alternate,
		YarkoCooldowns_SavedVars.Alternate
	)

	YarkoCooldowns_OptionsPanel.GeneralSettings.FlashColor.ColorSwatch.NormalTexture:SetVertexColor(
		YarkoCooldowns_SavedVars.FlashColor.r,
		YarkoCooldowns_SavedVars.FlashColor.g,
		YarkoCooldowns_SavedVars.FlashColor.b
	)

	YarkoCooldowns_OptionsPanel.GeneralSettings.FontLocation:SetText(YarkoCooldowns_SavedVars.FontLocation)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontLocation:SetCursorPosition(0)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontFile:SetText(YarkoCooldowns_SavedVars.FontFile)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontFile:SetCursorPosition(0)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontHeight:SetNumber(YarkoCooldowns_SavedVars.FontHeightX)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontHeight:SetCursorPosition(0)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Shadow:SetChecked(YarkoCooldowns_SavedVars.Shadow == "Y")

	UIDropDownMenu_Initialize(YarkoCooldowns_OptionsPanel.GeneralSettings.Outline, YarkoCooldowns.OutlineDropDownInit)
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanel.GeneralSettings.Outline, YarkoCooldowns_SavedVars.Outline)

	YarkoCooldowns_OptionsPanel.GeneralSettings.Tenths:SetChecked(YarkoCooldowns_SavedVars.Tenths == "Y")
	YarkoCooldowns_OptionsPanel.GeneralSettings.BelowTwo:SetChecked(YarkoCooldowns_SavedVars.BelowTwo == "Y")
	YarkoCooldowns_OptionsPanel.GeneralSettings.Seconds:SetText(YarkoCooldowns_SavedVars.Seconds)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Seconds:SetCursorPosition(0)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Minimum:SetText(YarkoCooldowns_SavedVars.Minimum)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Minimum:SetCursorPosition(0)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Size:SetText(YarkoCooldowns_SavedVars.Size)
	YarkoCooldowns_OptionsPanel.GeneralSettings.Size:SetCursorPosition(0)

	-- Copy the real table to working table
	wipe(TempCopy)

	for k, v in pairs(YarkoCooldowns_SavedVars.ParentFrames) do
		TempCopy[k] = v
	end

	YarkoCooldowns.FilteringScrollUpdate()
end

---------------------------------------------------
-- YarkoCooldowns.OptionsOkay
---------------------------------------------------
function YarkoCooldowns.OptionsOkay()
	YarkoCooldowns_SavedVars.MainColor.r,
		YarkoCooldowns_SavedVars.MainColor.g,
		YarkoCooldowns_SavedVars.MainColor.b =
	YarkoCooldowns_OptionsPanel.GeneralSettings.MainColor.ColorSwatch.NormalTexture:GetVertexColor()

	YarkoCooldowns_SavedVars.Flash = YarkoCooldowns_OptionsPanel.GeneralSettings.Flash:GetChecked() and "Y" or "N"
	YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns_OptionsPanel.GeneralSettings.FlashSeconds:GetNumber()
	YarkoCooldowns_SavedVars.Alternate = UIDropDownMenu_GetSelectedValue(YarkoCooldowns_OptionsPanel.GeneralSettings.Alternate)

	YarkoCooldowns_SavedVars.FlashColor.r,
		YarkoCooldowns_SavedVars.FlashColor.g,
		YarkoCooldowns_SavedVars.FlashColor.b =
	YarkoCooldowns_OptionsPanel.GeneralSettings.FlashColor.ColorSwatch.NormalTexture:GetVertexColor()

	YarkoCooldowns_SavedVars.FontLocation = YarkoCooldowns_OptionsPanel.GeneralSettings.FontLocation:GetText()
	YarkoCooldowns_SavedVars.FontFile = YarkoCooldowns_OptionsPanel.GeneralSettings.FontFile:GetText()
	YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns_OptionsPanel.GeneralSettings.FontHeight:GetNumber()
	YarkoCooldowns_SavedVars.Shadow = YarkoCooldowns_OptionsPanel.GeneralSettings.Shadow:GetChecked() and "Y" or "N"
	YarkoCooldowns_SavedVars.Outline = UIDropDownMenu_GetSelectedValue(YarkoCooldowns_OptionsPanel.GeneralSettings.Outline)
	YarkoCooldowns_SavedVars.Tenths = YarkoCooldowns_OptionsPanel.GeneralSettings.Tenths:GetChecked() and "Y" or "N"
	YarkoCooldowns_SavedVars.BelowTwo = YarkoCooldowns_OptionsPanel.GeneralSettings.BelowTwo:GetChecked() and "Y" or "N"

	YarkoCooldowns_SavedVars.Seconds = YarkoCooldowns_OptionsPanel.GeneralSettings.Seconds:GetNumber()
	YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns_OptionsPanel.GeneralSettings.Minimum:GetNumber()
	YarkoCooldowns_SavedVars.Size = YarkoCooldowns_OptionsPanel.GeneralSettings.Size:GetNumber()

	if YarkoCooldowns_SavedVars.FlashSeconds < 0 then
		YarkoCooldowns_SavedVars.FlashSeconds = 0
	end

	if YarkoCooldowns_SavedVars.FontHeightX < 4 then
		YarkoCooldowns_SavedVars.FontHeightX = 4
	end

	if YarkoCooldowns_SavedVars.FontHeightX > 72 then
		YarkoCooldowns_SavedVars.FontHeightX = 72
	end

	if YarkoCooldowns_SavedVars.Seconds < 10 then
		YarkoCooldowns_SavedVars.Seconds = 10
	end

	if YarkoCooldowns_SavedVars.Minimum < YarkoCooldowns.DefaultMinimum then
		YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum
	end

	if YarkoCooldowns_SavedVars.Size < 0 then
		YarkoCooldowns_SavedVars.Size = 0
	end

	-- Copy the working table to real table
	wipe(YarkoCooldowns_SavedVars.ParentFrames)

	for k, v in pairs(TempCopy) do
		YarkoCooldowns_SavedVars.ParentFrames[k] = v
	end

	YarkoCooldowns.UpdateCooldowns()
end

---------------------------------------------------
-- YarkoCooldowns.UpdateCooldowns
---------------------------------------------------
function YarkoCooldowns.UpdateCooldowns()
	for _, value in pairs(YarkoCooldowns.CooldownFrames) do
		YarkoCooldowns.UpdateFont(value)
	end

	YarkoCooldowns.UpdateCooldownAbbreviateOptions()
end

---------------------------------------------------
-- YarkoCooldowns.OutlineDropDownInit
---------------------------------------------------
function YarkoCooldowns.OutlineDropDownInit()
	local info = UIDropDownMenu_CreateInfo()

	info.text = YARKOCOOLDOWNS_CONFIG_NONE
	info.value = 1
	info.func = YarkoCooldowns.OutlineDropDownOnClick
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = YARKOCOOLDOWNS_CONFIG_NORMAL
	info.value = 2
	info.func = YarkoCooldowns.OutlineDropDownOnClick
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = YARKOCOOLDOWNS_CONFIG_THICK
	info.value = 3
	info.func = YarkoCooldowns.OutlineDropDownOnClick
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

---------------------------------------------------
-- YarkoCooldowns.OutlineDropDownOnClick
---------------------------------------------------
function YarkoCooldowns.OutlineDropDownOnClick(self)
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanel.GeneralSettings.Outline, self.value)
end

---------------------------------------------------
-- YarkoCooldowns.AlternateDropDownInit
---------------------------------------------------
function YarkoCooldowns.AlternateDropDownInit(self)
	local info = UIDropDownMenu_CreateInfo()

	info.text = YARKOCOOLDOWNS_CONFIG_ALTFLASH
	info.value = 1
	info.func = YarkoCooldowns.AlternateDropDownOnClick
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = YARKOCOOLDOWNS_CONFIG_ALTSOLID
	info.value = 2
	info.func = YarkoCooldowns.AlternateDropDownOnClick
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

---------------------------------------------------
-- YarkoCooldowns.AlternateDropDownOnClick
---------------------------------------------------
function YarkoCooldowns.AlternateDropDownOnClick(self)
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanel.GeneralSettings.Alternate, self.value)
end

---------------------------------------------------
-- YarkoCooldowns.ToggleFontDropDown()
---------------------------------------------------
function YarkoCooldowns.ToggleFontDropDown()
	if YarkoCooldowns_FontDropDown:IsShown() then
		YarkoCooldowns_FontDropDown:Hide()
	else
		YarkoCooldowns_FontDropDown:Show()
		FauxScrollFrame_SetOffset(YarkoCooldowns_FontDropDown.ScrollFrame, 0)
		YarkoCooldowns_FontDropDown.ScrollFrame:SetVerticalScroll(0)
	end
end

---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnShow
---------------------------------------------------
function YarkoCooldowns.FontDropDownOnShow(self)
	YarkoCooldowns.FontDropDownUpdate()
end

---------------------------------------------------
-- YarkoCooldowns.FontDropDownUpdate
---------------------------------------------------
function YarkoCooldowns.FontDropDownUpdate()
	local numButtons = #InGameFonts
	local maxwidth = 0

	if numButtons > 15 then
		numButtons = 15
	end

	local offset = FauxScrollFrame_GetOffset(YarkoCooldowns_FontDropDown.ScrollFrame)

	for i = 1, 15 do
		local index = i + offset
		local button = YarkoCooldowns_FontDropDown["Button" .. i]

		if index <= #InGameFonts then
			local buttonText = button.NormalText
			button:SetText(InGameFonts[index])
			local width = buttonText:GetWidth() + 10

			if width > maxwidth then
				maxwidth = width
			end

			button:Show()
		else
			button:Hide()
		end
	end

	-- Adjust menu width
	if not MenuResized then
		for i = 1, 15 do
			local button = YarkoCooldowns_FontDropDown["Button" .. i]
			button:SetWidth(maxwidth)
		end

		if #InGameFonts > 15 then
			maxwidth = maxwidth + 15
		end

		YarkoCooldowns_FontDropDown:SetWidth(maxwidth + 25)

		MenuResized = true

		-- Adjust menu height
		YarkoCooldowns_FontDropDown:SetHeight((numButtons * 16) + 27)
	end

	if #InGameFonts > 15 then
		-- Show or hide scrollbar invis buttons
		if offset == 0 then
			YarkoCooldowns_UpButton:Show()
		else
			YarkoCooldowns_UpButton:Hide()
		end

		if offset == #InGameFonts - 15 then
			YarkoCooldowns_DownButton:Show()
		else
			YarkoCooldowns_DownButton:Hide()
		end
	end

	-- ScrollFrame stuff
	FauxScrollFrame_Update(YarkoCooldowns_FontDropDown.ScrollFrame, #InGameFonts, 15, 16)
end

---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnUpdate
---------------------------------------------------
function YarkoCooldowns.FontDropDownButtonOnClick(self, _)
	YarkoCooldowns_OptionsPanel.GeneralSettings.FontFile:SetText(self.NormalText:GetText())
	YarkoCooldowns_FontDropDown:Hide()
end

---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnUpdate
-- Handle dropdown counting
---------------------------------------------------
function YarkoCooldowns.FontDropDownOnUpdate(_, elapsed)
	-- Hide dropdown after 2 seconds
	if IsDropdownCounting then
		DropdownTimer = DropdownTimer - elapsed

		if DropdownTimer < 0 then
			YarkoCooldowns_FontDropDown:Hide()
			IsDropdownCounting = false
		end
	end
end

---------------------------------------------------
-- YarkoCooldowns.StartCounting
-- Start the dropdown hide countdown
---------------------------------------------------
function YarkoCooldowns.StartCounting()
	DropdownTimer = UIDROPDOWNMENU_SHOW_TIME
	IsDropdownCounting = true
end

---------------------------------------------------
-- YarkoCooldowns.StopCounting
-- Stop the dropdown hide countdown
---------------------------------------------------
function YarkoCooldowns.StopCounting()
	IsDropdownCounting = false
end

---------------------------------------------------
-- YarkoCooldowns.SwatchOnLoad
---------------------------------------------------
function YarkoCooldowns.SwatchOnLoad(self)
	self.Text = _G[self:GetName() .. "Text"]

	local swatch = _G[self:GetName() .. "ColorSwatch"]
	self.ColorSwatch = swatch

	self.ColorSwatch.SwatchBg = _G[self.ColorSwatch:GetName() .. "SwatchBg"]
	self.ColorSwatch.NormalTexture = _G[self.ColorSwatch:GetName() .. "NormalTexture"]

	swatch:SetScript("OnClick", function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		YarkoCooldowns.SwatchOnClick(self)
	end)

	swatch:SetScript("OnEnter", function(self)
		self.SwatchBg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end)

	swatch:SetScript("OnLeave", function(self)
		self.SwatchBg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end)

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0.5)
end

---------------------------------------------------
-- YarkoCooldowns.SwatchOnClick
---------------------------------------------------
function YarkoCooldowns.SwatchOnClick(self)
	local info = {}
	info.extraInfo = self.NormalTexture
	info.r, info.g, info.b = info.extraInfo:GetVertexColor()
	info.swatchFunc = YarkoCooldowns.SetColor
	OpenColorPicker(info)
end

---------------------------------------------------
-- YarkoCooldowns.SetColor
---------------------------------------------------
function YarkoCooldowns.SetColor()
	if not ColorPickerFrame:IsVisible() then
		ColorPickerFrame.extraInfo:SetVertexColor(ColorPickerFrame:GetColorRGB())
	end
end

---------------------------------------------------
-- YarkoCooldowns.CopyColors
---------------------------------------------------
function YarkoCooldowns.CopyColors(object)
	local tbl = {
		r = object.r,
		g = object.g,
		b = object.b,
	}

	return tbl
end

---------------------------------------------------
-- YarkoCooldowns.ClickTab
---------------------------------------------------
function YarkoCooldowns.ClickTab(tab)
	YarkoCooldowns.SetTab(tab:GetID())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function YarkoCooldowns.SetTab(tabID)
	PanelTemplates_SetTab(YarkoCooldowns_OptionsPanel, tabID)

	for i, frame in ipairs(YarkoCooldowns_OptionsPanel.ContentFrames) do
		if i == tabID then
			frame:Show()
		else
			frame:Hide()
		end
	end
end

---------------------------------------------------
-- YarkoCooldowns.FilteringScrollOnLoad
---------------------------------------------------
function YarkoCooldowns.FilteringScrollOnLoad(self)
	HybridScrollFrame_OnLoad(self)
	self.update = YarkoCooldowns.FilteringScrollUpdate
	HybridScrollFrame_CreateButtons(self, "YarkoCooldowns_FilteringScrollButtonTemplate")
end

local SortedParentList = {}
local SelectedParent = 1

---------------------------------------------------
-- YarkoCooldowns.FilteringScrollUpdate
---------------------------------------------------
function YarkoCooldowns.FilteringScrollUpdate()
	wipe(SortedParentList)

	for k, _ in pairs(TempCopy) do
		tinsert(SortedParentList, k)
	end

	sort(SortedParentList)

	local numEntries = #SortedParentList

	if SelectedParent > numEntries then
		SelectedParent = numEntries
	end

	local buttons = YarkoCooldowns_OptionsPanel.Filtering.ScrollFrame.buttons
	local numButtons = #buttons
	local scrollOffset = HybridScrollFrame_GetOffset(YarkoCooldowns_OptionsPanel.Filtering.ScrollFrame)
	local buttonHeight = buttons[1]:GetHeight()
	local displayedHeight = 0

	for i = 1, numButtons do
		local button = buttons[i]
		local index = i + scrollOffset
		button:SetID(index)

		if index <= numEntries then
			local parentName = SortedParentList[index]
			button:SetText(parentName)
			button.Check:SetChecked(TempCopy[parentName] == "Y")

			button:Show()
		else
			button:Hide()
		end

		displayedHeight = displayedHeight + buttonHeight
	end

	HybridScrollFrame_Update(YarkoCooldowns_OptionsPanel.Filtering.ScrollFrame, numEntries * buttonHeight, displayedHeight)
end

---------------------------------------------------
-- YarkoCooldowns.FilteringButtonOnClick
---------------------------------------------------
function YarkoCooldowns.FilteringButtonOnClick(self)
	local id = self:GetID()
	local curval = TempCopy[SortedParentList[id]]

	TempCopy[SortedParentList[id]] = curval == "Y" and "N" or "Y"
	YarkoCooldowns.FilteringScrollUpdate()
end

---------------------------------------------------
-- YarkoCooldowns.RemoveOnClick
---------------------------------------------------
function YarkoCooldowns.RemoveOnClick(val)
	if val == 1 then
		wipe(TempCopy)
	else
		for k, v in pairs(TempCopy) do
			if v == "N" then
				TempCopy[k] = nil
			end
		end
	end

	YarkoCooldowns.FilteringScrollUpdate()
end
