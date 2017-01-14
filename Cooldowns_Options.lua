
---------------------------------------------------
-- Global vars
---------------------------------------------------

YarkoCooldowns_SavedVars = {};


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
	"SKURRI_CYR.TTF"
};

local IsDropdownCounting = false;
local DropdownTimer = 0;
local MenuResized = false;


---------------------------------------------------
-- YarkoCooldowns.OptionsSetup
---------------------------------------------------
function YarkoCooldowns.OptionsSetup()
	if (not YarkoCooldowns_SavedVars.Tenths) then
		YarkoCooldowns.OptionsDefault();
	end
	if (not YarkoCooldowns_SavedVars.Flash) then
		YarkoCooldowns_SavedVars.Flash = YarkoCooldowns.DefaultFlash;
	end
	if (not YarkoCooldowns_SavedVars.FlashSeconds) then
		YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns.DefaultFlashSeconds;
	end
	if (not YarkoCooldowns_SavedVars.Alternate) then
		YarkoCooldowns_SavedVars.Alternate = YarkoCooldowns.DefaultAlternate;
	end
	if (not YarkoCooldowns_SavedVars.Minimum) then
		YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum;
	end
	if (not YarkoCooldowns_SavedVars.Size) then
		YarkoCooldowns_SavedVars.Size = YarkoCooldowns.DefaultSize;
	end
	if (not YarkoCooldowns_SavedVars.FontHeightX) then
		YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns.DefaultFontHeight;
		YarkoCooldowns_SavedVars.FontHeight = nil;
	end
	if (not YarkoCooldowns_SavedVars.ParentFrames) then
		YarkoCooldowns_SavedVars.ParentFrames = {};
	end
	
	InterfaceOptions_AddCategory(YarkoCooldowns_OptionsPanel);
	
	-- Set scroll frame so that it resets the dropdown hide counter
	YarkoCooldowns_FontDropDownScrollFrameScrollBar:SetScript("OnEnter", YarkoCooldowns.StopCounting);
	YarkoCooldowns_FontDropDownScrollFrameScrollBar:SetScript("OnLeave", YarkoCooldowns.StartCounting);
	YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollUpButton:SetScript("OnEnter", YarkoCooldowns.StopCounting);
	YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollUpButton:SetScript("OnLeave", YarkoCooldowns.StartCounting);
	YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollDownButton:SetScript("OnEnter", YarkoCooldowns.StopCounting);
	YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollDownButton:SetScript("OnLeave", YarkoCooldowns.StartCounting);
	
	-- Create invis buttons for scrollbar to hide dropdown
	CreateFrame("Button", "YarkoCooldowns_UpButton", YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollUpButton,
		"YarkoCooldowns_InvisibleButtonTemplate");
	YarkoCooldowns_UpButton:SetAllPoints(YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollUpButton);
	CreateFrame("Button", "YarkoCooldowns_DownButton", YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollDownButton,
		"YarkoCooldowns_InvisibleButtonTemplate");
	YarkoCooldowns_DownButton:SetAllPoints(YarkoCooldowns_FontDropDownScrollFrameScrollBarScrollDownButton);
		
	-- Adjust dropdown field widths
	UIDropDownMenu_SetWidth(YarkoCooldowns_OptionsPanelGeneralSettingsAlternate, 67)
	UIDropDownMenu_SetWidth(YarkoCooldowns_OptionsPanelGeneralSettingsOutline, 60)
	
	-- Set first tab as selected by default
	YarkoCooldowns.ConfigTabClick(1)
end


---------------------------------------------------
-- YarkoCooldowns.OptionsDefault
---------------------------------------------------
function YarkoCooldowns.OptionsDefault()
	YarkoCooldowns_SavedVars.MainColor = YarkoCooldowns.CopyColors(YarkoCooldowns.DefaultMainColor);
	YarkoCooldowns_SavedVars.Flash = YarkoCooldowns.DefaultFlash;
	YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns.DefaultFlashSeconds;
	YarkoCooldowns_SavedVars.Alternate = YarkoCooldowns.DefaultAlternate;
	YarkoCooldowns_SavedVars.FlashColor = YarkoCooldowns.CopyColors(YarkoCooldowns.DefaultFlashColor);
	YarkoCooldowns_SavedVars.FontLocation = YarkoCooldowns.DefaultFontLocation;
	YarkoCooldowns_SavedVars.FontFile = YarkoCooldowns.DefaultFontFile;
	YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns.DefaultFontHeight;
	YarkoCooldowns_SavedVars.Shadow = YarkoCooldowns.DefaultShadow;
	YarkoCooldowns_SavedVars.Outline = YarkoCooldowns.DefaultOutline;
	YarkoCooldowns_SavedVars.Tenths = YarkoCooldowns.DefaultTenths;
	YarkoCooldowns_SavedVars.BelowTwo = YarkoCooldowns.DefaultBelowTwo;
	YarkoCooldowns_SavedVars.Seconds = YarkoCooldowns.DefaultSeconds;
	YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum;
	YarkoCooldowns_SavedVars.Size = YarkoCooldowns.DefaultSize;
	
	if (YarkoCooldowns_SavedVars.ParentFrames) then
		for k, v in pairs(YarkoCooldowns_SavedVars.ParentFrames) do
			YarkoCooldowns_SavedVars.ParentFrames[k] = "Y";
		end
	end
	
	YarkoCooldowns.UpdateCooldowns();
end


local TempCopy = {};

---------------------------------------------------
-- YarkoCooldowns.OptionsRefresh
---------------------------------------------------
function YarkoCooldowns.OptionsRefresh()
	YarkoCooldowns_OptionsPanelGeneralSettingsMainColorColorSwatchNormalTexture:SetVertexColor(YarkoCooldowns_SavedVars.MainColor.r, 
		YarkoCooldowns_SavedVars.MainColor.g, YarkoCooldowns_SavedVars.MainColor.b);
	YarkoCooldowns_OptionsPanelGeneralSettingsFlash:SetChecked(YarkoCooldowns_SavedVars.Flash == "Y");
	YarkoCooldowns_OptionsPanelGeneralSettingsFlashSeconds:SetText(YarkoCooldowns_SavedVars.FlashSeconds);
	YarkoCooldowns_OptionsPanelGeneralSettingsFlashSeconds:SetCursorPosition(0);
    UIDropDownMenu_Initialize(YarkoCooldowns_OptionsPanelGeneralSettingsAlternate, YarkoCooldowns.AlternateDropDownInit);
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsAlternate, YarkoCooldowns_SavedVars.Alternate);
	YarkoCooldowns_OptionsPanelGeneralSettingsFlashColorColorSwatchNormalTexture:SetVertexColor(YarkoCooldowns_SavedVars.FlashColor.r, 
		YarkoCooldowns_SavedVars.FlashColor.g, YarkoCooldowns_SavedVars.FlashColor.b);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontLocation:SetText(YarkoCooldowns_SavedVars.FontLocation);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontLocation:SetCursorPosition(0);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontFile:SetText(YarkoCooldowns_SavedVars.FontFile);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontFile:SetCursorPosition(0);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontHeight:SetNumber(YarkoCooldowns_SavedVars.FontHeightX);
	YarkoCooldowns_OptionsPanelGeneralSettingsFontHeight:SetCursorPosition(0);
	YarkoCooldowns_OptionsPanelGeneralSettingsShadow:SetChecked(YarkoCooldowns_SavedVars.Shadow == "Y");
    UIDropDownMenu_Initialize(YarkoCooldowns_OptionsPanelGeneralSettingsOutline, YarkoCooldowns.OutlineDropDownInit);
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsOutline, YarkoCooldowns_SavedVars.Outline);
	YarkoCooldowns_OptionsPanelGeneralSettingsTenths:SetChecked(YarkoCooldowns_SavedVars.Tenths == "Y");
	YarkoCooldowns_OptionsPanelGeneralSettingsBelowTwo:SetChecked(YarkoCooldowns_SavedVars.BelowTwo == "Y");
	YarkoCooldowns_OptionsPanelGeneralSettingsSeconds:SetText(YarkoCooldowns_SavedVars.Seconds);
	YarkoCooldowns_OptionsPanelGeneralSettingsSeconds:SetCursorPosition(0);
	YarkoCooldowns_OptionsPanelGeneralSettingsMinimum:SetText(YarkoCooldowns_SavedVars.Minimum);
	YarkoCooldowns_OptionsPanelGeneralSettingsMinimum:SetCursorPosition(0);
	YarkoCooldowns_OptionsPanelGeneralSettingsSize:SetText(YarkoCooldowns_SavedVars.Size);
	YarkoCooldowns_OptionsPanelGeneralSettingsSize:SetCursorPosition(0);
	
	-- Copy the real table to working table
	wipe(TempCopy);
	
	for k, v in pairs(YarkoCooldowns_SavedVars.ParentFrames) do
		TempCopy[k] = v;
	end
	
	YarkoCooldowns.FilteringScrollUpdate();
end


---------------------------------------------------
-- YarkoCooldowns.OptionsOkay
---------------------------------------------------
function YarkoCooldowns.OptionsOkay()
	YarkoCooldowns_SavedVars.MainColor.r, YarkoCooldowns_SavedVars.MainColor.g, 
		YarkoCooldowns_SavedVars.MainColor.b 
		= YarkoCooldowns_OptionsPanelGeneralSettingsMainColorColorSwatchNormalTexture:GetVertexColor();
	YarkoCooldowns_SavedVars.Flash = ((YarkoCooldowns_OptionsPanelGeneralSettingsFlash:GetChecked() and "Y") or "N");
	YarkoCooldowns_SavedVars.FlashSeconds = YarkoCooldowns_OptionsPanelGeneralSettingsFlashSeconds:GetNumber();
	YarkoCooldowns_SavedVars.Alternate = UIDropDownMenu_GetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsAlternate);
	YarkoCooldowns_SavedVars.FlashColor.r, YarkoCooldowns_SavedVars.FlashColor.g, 
		YarkoCooldowns_SavedVars.FlashColor.b 
		= YarkoCooldowns_OptionsPanelGeneralSettingsFlashColorColorSwatchNormalTexture:GetVertexColor();
	YarkoCooldowns_SavedVars.FontLocation = YarkoCooldowns_OptionsPanelGeneralSettingsFontLocation:GetText();
	YarkoCooldowns_SavedVars.FontFile = YarkoCooldowns_OptionsPanelGeneralSettingsFontFile:GetText();
	YarkoCooldowns_SavedVars.FontHeightX = YarkoCooldowns_OptionsPanelGeneralSettingsFontHeight:GetNumber();
	YarkoCooldowns_SavedVars.Shadow = ((YarkoCooldowns_OptionsPanelGeneralSettingsShadow:GetChecked() and "Y") or "N");
	YarkoCooldowns_SavedVars.Outline = UIDropDownMenu_GetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsOutline);
	YarkoCooldowns_SavedVars.Tenths = ((YarkoCooldowns_OptionsPanelGeneralSettingsTenths:GetChecked() and "Y") or "N");
	YarkoCooldowns_SavedVars.BelowTwo = ((YarkoCooldowns_OptionsPanelGeneralSettingsBelowTwo:GetChecked() and "Y") or "N");
	YarkoCooldowns_SavedVars.Seconds = YarkoCooldowns_OptionsPanelGeneralSettingsSeconds:GetNumber();
	YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns_OptionsPanelGeneralSettingsMinimum:GetNumber();
	YarkoCooldowns_SavedVars.Size = YarkoCooldowns_OptionsPanelGeneralSettingsSize:GetNumber();
		
	if (YarkoCooldowns_SavedVars.FlashSeconds < 0) then
		YarkoCooldowns_SavedVars.FlashSeconds = 0;
	end

	if (YarkoCooldowns_SavedVars.FontHeightX < 4) then
		YarkoCooldowns_SavedVars.FontHeightX = 4;
	end
	
	if (YarkoCooldowns_SavedVars.FontHeightX > 72) then
		YarkoCooldowns_SavedVars.FontHeightX = 72;
	end
	
	--if (YarkoCooldowns_SavedVars.Seconds > 120) then
	--	YarkoCooldowns_SavedVars.Seconds = 120;
	--end

	if (YarkoCooldowns_SavedVars.Seconds < 10) then
		YarkoCooldowns_SavedVars.Seconds = 10;
	end
	
	if (YarkoCooldowns_SavedVars.Minimum < YarkoCooldowns.DefaultMinimum) then
		YarkoCooldowns_SavedVars.Minimum = YarkoCooldowns.DefaultMinimum;
	end
	
	if (YarkoCooldowns_SavedVars.Size < 0) then
		YarkoCooldowns_SavedVars.Size = 0;
	end
	
	-- Copy the working table to real table
	wipe(YarkoCooldowns_SavedVars.ParentFrames);
	
	for k, v in pairs(TempCopy) do
		YarkoCooldowns_SavedVars.ParentFrames[k] = v;
	end

	YarkoCooldowns.UpdateCooldowns();
end


---------------------------------------------------
-- YarkoCooldowns.UpdateCooldowns
---------------------------------------------------
function YarkoCooldowns.UpdateCooldowns()
	local index, value;
	
	for index, value in pairs(YarkoCooldowns.CooldownFrames) do
		YarkoCooldowns.UpdateFont(value);
	end
end


---------------------------------------------------
-- YarkoCooldowns.OutlineDropDownInit
---------------------------------------------------
function YarkoCooldowns.OutlineDropDownInit(self)
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = YARKOCOOLDOWNS_CONFIG_NONE;
	info.value = 1;
	info.func = YarkoCooldowns.OutlineDropDownOnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
	
	info.text = YARKOCOOLDOWNS_CONFIG_NORMAL;
	info.value = 2;
	info.func = YarkoCooldowns.OutlineDropDownOnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
	
	info.text = YARKOCOOLDOWNS_CONFIG_THICK;
	info.value = 3;
	info.func = YarkoCooldowns.OutlineDropDownOnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
end


---------------------------------------------------
-- YarkoCooldowns.OutlineDropDownOnClick
---------------------------------------------------
function YarkoCooldowns.OutlineDropDownOnClick(self)
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsOutline, self.value);
end


---------------------------------------------------
-- YarkoCooldowns.AlternateDropDownInit
---------------------------------------------------
function YarkoCooldowns.AlternateDropDownInit(self)
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = YARKOCOOLDOWNS_CONFIG_ALTFLASH;
	info.value = 1;
	info.func = YarkoCooldowns.AlternateDropDownOnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
	
	info.text = YARKOCOOLDOWNS_CONFIG_ALTSOLID;
	info.value = 2;
	info.func = YarkoCooldowns.AlternateDropDownOnClick;
	info.checked = nil;
	UIDropDownMenu_AddButton(info);
end


---------------------------------------------------
-- YarkoCooldowns.AlternateDropDownOnClick
---------------------------------------------------
function YarkoCooldowns.AlternateDropDownOnClick(self)
	UIDropDownMenu_SetSelectedValue(YarkoCooldowns_OptionsPanelGeneralSettingsAlternate, self.value);
end


---------------------------------------------------
-- YarkoCooldowns.ToggleFontDropDown()
---------------------------------------------------
function YarkoCooldowns.ToggleFontDropDown()
	if (YarkoCooldowns_FontDropDown:IsShown()) then
		YarkoCooldowns_FontDropDown:Hide();
	else
		YarkoCooldowns_FontDropDown:Show();
		FauxScrollFrame_SetOffset(YarkoCooldowns_FontDropDownScrollFrame, 0);
		YarkoCooldowns_FontDropDownScrollFrame:SetVerticalScroll(0);
	end
end


---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnShow
---------------------------------------------------
function YarkoCooldowns.FontDropDownOnShow(self)
	YarkoCooldowns.FontDropDownUpdate();
	--YarkoCooldowns.StartCounting();
end


---------------------------------------------------
-- YarkoCooldowns.FontDropDownUpdate
---------------------------------------------------
function YarkoCooldowns.FontDropDownUpdate()
	local t, index;
	local numButtons = #InGameFonts;
	local button, buttonText;
	local maxwidth = 0;
	
	if (numButtons > 15) then
		numButtons = 15;
	end
	
	local offset = FauxScrollFrame_GetOffset(YarkoCooldowns_FontDropDownScrollFrame);
	
	for t = 1, 15 do
		index = t + offset;
		button = _G["YarkoCooldowns_FontDropDownButton"..t];
		
		if (index <= #InGameFonts) then
			buttonText = _G["YarkoCooldowns_FontDropDownButton"..t.."NormalText"];
			button:SetText(InGameFonts[index]);
			width = buttonText:GetWidth() + 10;
			
			if (width > maxwidth) then
				maxwidth = width;
			end
			
			button:Show();
		else
			button:Hide();
		end
	end
	
	-- Adjust menu width
	if (not MenuResized) then
		for t = 1,  15 do
			button = _G["YarkoCooldowns_FontDropDownButton"..t];
			button:SetWidth(maxwidth);
		end
		
		if (#InGameFonts > 15) then
			maxwidth = maxwidth + 15;
		end
		
		YarkoCooldowns_FontDropDown:SetWidth(maxwidth + 25);
		
		MenuResized = true;
	
		-- Adjust menu height
		YarkoCooldowns_FontDropDown:SetHeight((numButtons * 16) + 27);
	end
	
	if (#InGameFonts > 15) then
		-- Show or hide scrollbar invis buttons
		if (offset == 0) then
			YarkoCooldowns_UpButton:Show();
		else
			YarkoCooldowns_UpButton:Hide();
		end

		if (offset == #InGameFonts - 15) then
			YarkoCooldowns_DownButton:Show();
		else
			YarkoCooldowns_DownButton:Hide();
		end
	end

	-- ScrollFrame stuff
	FauxScrollFrame_Update(YarkoCooldowns_FontDropDownScrollFrame, #InGameFonts, 15, 16);
end


---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnUpdate
---------------------------------------------------
function YarkoCooldowns.FontDropDownButtonOnClick(self, button)
	YarkoCooldowns_OptionsPanelGeneralSettingsFontFile:SetText(_G[self:GetName().."NormalText"]:GetText());
	YarkoCooldowns_FontDropDown:Hide();
end


---------------------------------------------------
-- YarkoCooldowns.FontDropDownOnUpdate
-- Handle dropdown counting
---------------------------------------------------
function YarkoCooldowns.FontDropDownOnUpdate(self, elapsed)
	-- Hide dropdown after 2 seconds
	if (IsDropdownCounting) then
		DropdownTimer = DropdownTimer - elapsed;
		
		if (DropdownTimer < 0) then
			YarkoCooldowns_FontDropDown:Hide();
			IsDropdownCounting = false;
		end
	end
end

---------------------------------------------------
-- YarkoCooldowns.StartCounting
-- Start the dropdown hide countdown 
---------------------------------------------------
function YarkoCooldowns.StartCounting()
	DropdownTimer = UIDROPDOWNMENU_SHOW_TIME;
	IsDropdownCounting = true;
end


---------------------------------------------------
-- YarkoCooldowns.StopCounting
-- Stop the dropdown hide countdown 
---------------------------------------------------
function YarkoCooldowns.StopCounting()
	IsDropdownCounting = false;
end


---------------------------------------------------
-- YarkoCooldowns.SwatchOnLoad
---------------------------------------------------
function YarkoCooldowns.SwatchOnLoad(self)
	local swatch = _G[self:GetName().."ColorSwatch"];
	
	swatch:SetScript("OnClick", function (self)
		PlaySound("igMainMenuOptionCheckBoxOn");
		YarkoCooldowns.SwatchOnClick(self);
	end);
	swatch:SetScript("OnEnter", function (self)
		_G[self:GetName().."SwatchBg"]:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end);
	swatch:SetScript("OnLeave", function (self)
		_G[self:GetName().."SwatchBg"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end);
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0.5);
end


---------------------------------------------------
-- YarkoCooldowns.SwatchOnClick
---------------------------------------------------
function YarkoCooldowns.SwatchOnClick(self)
	local info = {};
	info.extraInfo = _G[self:GetName().."NormalTexture"];
	info.r, info.g, info.b = info.extraInfo:GetVertexColor();
	info.swatchFunc = YarkoCooldowns.SetColor;
	OpenColorPicker(info);
end


---------------------------------------------------
-- YarkoCooldowns.SetColor
---------------------------------------------------
function YarkoCooldowns.SetColor()
	if (not ColorPickerFrame:IsVisible()) then
		ColorPickerFrame.extraInfo:SetVertexColor(ColorPickerFrame:GetColorRGB());
	end
end


---------------------------------------------------
-- YarkoCooldowns.CopyColors
---------------------------------------------------
function YarkoCooldowns.CopyColors(object)
	local tbl = {};
	
	tbl.r = object.r;
	tbl.g = object.g;
	tbl.b = object.b;
	
	return tbl;
end


local ConfigTabs = {
	"YarkoCooldowns_OptionsPanelGeneralSettings",
	"YarkoCooldowns_OptionsPanelFiltering"
};

---------------------------------------------------
-- YarkoCooldowns.ConfigTabClick
---------------------------------------------------
function YarkoCooldowns.ConfigTabClick(tabID)
	for i, frame in ipairs(ConfigTabs) do
		local name = "YarkoCooldowns_OptionsPanelTab"..i
		local tab = _G[name];
		if (i == tabID) then
			_G[name.."Left"]:SetAlpha(1.0);
			_G[name.."Middle"]:SetAlpha(1.0);
			_G[name.."Right"]:SetAlpha(1.0);
			tab.text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			_G[frame]:Show();
		else
			_G[name.."Left"]:SetAlpha(0.75);
			_G[name.."Middle"]:SetAlpha(0.75);
			_G[name.."Right"]:SetAlpha(0.75);
			tab.text:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			_G[frame]:Hide();
		end
	end
end


---------------------------------------------------
-- YarkoCooldowns.FilteringScrollOnLoad
---------------------------------------------------
function YarkoCooldowns.FilteringScrollOnLoad(self)
	HybridScrollFrame_OnLoad(self);
	self.update = YarkoCooldowns.FilteringScrollUpdate;
	HybridScrollFrame_CreateButtons(self, "YarkoCooldowns_FilteringScrollButtonTemplate");
end


local SortedParentList = {};
local SelectedParent = 1;

---------------------------------------------------
-- YarkoCooldowns.FilteringScrollUpdate
---------------------------------------------------
function YarkoCooldowns.FilteringScrollUpdate()
	wipe(SortedParentList);
	
	for k, v in pairs(TempCopy) do
		tinsert(SortedParentList, k);
	end
	
	sort(SortedParentList);
	
	local numEntries = #SortedParentList;
	
	if (SelectedParent > numEntries) then
		SelectedParent = numEntries;
	end

	local buttons = YarkoCooldowns_OptionsPanelFilteringScrollFrame.buttons;
	local numButtons = #buttons;
	local scrollOffset = HybridScrollFrame_GetOffset(YarkoCooldowns_OptionsPanelFilteringScrollFrame);
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = 0;

	local button, index, parentName;

	for i=1, numButtons do
		button = buttons[i];
		index = i + scrollOffset;
		button:SetID(index);

		if (index <= numEntries) then
			parentName = SortedParentList[index];
			button:SetText(parentName);
			button.check:SetChecked(TempCopy[parentName] == "Y");
			
			button:Show();
		else
			button:Hide();
		end
		
		displayedHeight = displayedHeight + buttonHeight;
	end
	
	HybridScrollFrame_Update(YarkoCooldowns_OptionsPanelFilteringScrollFrame, numEntries * buttonHeight, displayedHeight);
end


---------------------------------------------------
-- YarkoCooldowns.FilteringButtonOnClick
---------------------------------------------------
function YarkoCooldowns.FilteringButtonOnClick(self)
	local id = self:GetID();
	local curval = TempCopy[SortedParentList[id]];
	
	TempCopy[SortedParentList[id]] = ((curval == "Y" and "N") or "Y");
	YarkoCooldowns.FilteringScrollUpdate();
end


---------------------------------------------------
-- YarkoCooldowns.RemoveOnClick
---------------------------------------------------
function YarkoCooldowns.RemoveOnClick(val)
	if (val == 1) then
		wipe(TempCopy);
	else
		for k, v in pairs(TempCopy) do
			if (v == "N") then
				TempCopy[k] = nil;
			end
		end
	end
	
	YarkoCooldowns.FilteringScrollUpdate();
end
