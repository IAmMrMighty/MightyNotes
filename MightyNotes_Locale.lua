---------------------------------
--     MightyNotes Locale
---------------------------------

local LANG = GetLocale()
local void, MightyNotes = ...
local function localeFunc(L, key) return key end
local L = setmetatable({}, {__index = localeFunc})
MightyNotes.L = L

if LANG == "deDE" then
    L["Save"] = "Speichern";
    L["Delete"] = "Löschen";
    L["Place notes here"] = "Hier ist Platz für deine Notizen.";
    L["New note added!"] = "Neue Notiz hinzugefügt.";
    L["Note deleted!"] = "Notiz gelöscht.";
    L['Update'] = "Aktualisieren";
    L["First note added!"] = "Erste Notiz hinzugefügt.";
    L["Note "] = "Notiz ";
    L[" saved!"] = " gespeichert!";
    L["Create a new note or open one."] = "Erstelle eine Notiz oder öffne eine.";
    L["New name of the note"] = "Neuer Name der Notiz";
    L["Rename"] = "Umbenennen";
end