-- Thanks to zreptil and Darkwing151 on Curse

-- German
if GetLocale() == "deDE" then
	YARKOCOOLDOWNS_CONFIG_MAINCOLOR = "Cooldown Zahlen Farbe"
	YARKOCOOLDOWNS_CONFIG_FLASH = "Benutze alternative Cooldownfarbe ab"
	YARKOCOOLDOWNS_CONFIG_FLASH2 = "Sekunden"
	YARKOCOOLDOWNS_CONFIG_ALTERNATE = "Zeige alternative Farbe als"
	YARKOCOOLDOWNS_CONFIG_ALTFLASH = "blinkend"
	YARKOCOOLDOWNS_CONFIG_ALTSOLID = "solide"
	YARKOCOOLDOWNS_CONFIG_FLASHCOLOR = "Cooldown blinkende Farbe"
	YARKOCOOLDOWNS_CONFIG_FONTLOCATION = "Font Verzeichnis"
	YARKOCOOLDOWNS_CONFIG_FONTFILE = "Font Dateiname"
	YARKOCOOLDOWNS_CONFIG_FONTHEIGHT = "Font H\195\182he"
	YARKOCOOLDOWNS_CONFIG_SHADOW = "Text Schatten"
	YARKOCOOLDOWNS_CONFIG_OUTLINE = "Text Umriss"
	YARKOCOOLDOWNS_CONFIG_NONE = "Keiner"
	YARKOCOOLDOWNS_CONFIG_NORMAL = "D\195\188nn"
	YARKOCOOLDOWNS_CONFIG_THICK = "Dick"
	YARKOCOOLDOWNS_CONFIG_TENTHS = "Zeige Zehntel bei Minuten und Stunden"
	YARKOCOOLDOWNS_CONFIG_BELOWTWO = "Zeige Zehntel unter zwei Sekunden"
	YARKOCOOLDOWNS_CONFIG_SECONDS = "Zeige Sekunden bei"
	YARKOCOOLDOWNS_CONFIG_SECONDS2 = "Sekunden"
	YARKOCOOLDOWNS_CONFIG_MINIMUM = "Zeige Cooldowntext nur wenn der Cooldown l\195\164nger als"
	YARKOCOOLDOWNS_CONFIG_MINIMUM2 = "Sekunden ist"
	YARKOCOOLDOWNS_CONFIG_SIZE = "Zeige Cooldowntext nur wenn das Icon"
	YARKOCOOLDOWNS_CONFIG_SIZE2 = "Pixel oder gr\195\182\195\159er ist"
	YARKOCOOLDOWNS_CONFIG_TAB1 = "Allgemeine Einstellungen"
	YARKOCOOLDOWNS_CONFIG_TAB2 = "Filter"
	YARKOCOOLDOWNS_CONFIG_LIST = "Erkannte Cooldown Frames"
	YARKOCOOLDOWNS_CONFIG_REMOVE = "Entfernen: Alle"
	YARKOCOOLDOWNS_CONFIG_UNSELECTED = "Entfernen: Unmarkiert"

	YARKOCOOLDOWNS_CONFIG_FONTLOCATION_INFO = "Ordner  innerhalb des WoW Dateisystems, wo die Fonts plaziert sind. Benutze \"Fonts\" "
		..
		"f\195\188r Standard In-Game Fonts wie FRIZQT__.TTF. Um eine Datei in einem Addon Unterordner auszuw\195\164hlen, gib an: "
		..
		"\"Interface\\Addons\\<Name des Addons>\\<Unterordner>\"."

	YARKOCOOLDOWNS_CONFIG_FONTFILE_INFO = "Name der Font Datei, wie \"FRIZQT__.TTF\" oder \"ARIALN.TTF\""

	YARKOCOOLDOWNS_CONFIG_LIST_INFO = "Diese Liste zeigt erkannte Cooldown Frames auf denen ein Cooldowntext platziert wird, durch "
		..
		"demarkieren wird der Cooldowntext bei diesem Frame versteckt. Diese Liste erweitert sich automatisch.\n\nBenutzen der unteren "
		..
		"Schaltfl\195\164chen entfernt Eintr\195\164ge aus dieser Liste, dies ist zum Beispiel sinnvoll um alte nichtmehr benutzte Frames zu entfernen. "
		..
		"Entfernte Eintr\195\164ge werden wieder mit Cooldowntext dargestellt."

	YARKOCOOLDOWNS_CONFIG_SIZE_INFO = "Standard action button: 36\nStandard player buff: 30\nStandard target frame debuff: 17"
end
