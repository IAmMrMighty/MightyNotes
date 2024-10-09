	------- DECLARATIONS -------
    MightyNotesList = MightyNotesList or {}
	latestSelectedNoteIndex = latestSelectedNoteIndex or {}
    local selectedNoteIndex = selectedNoteIndex or 1
    local void, MightyNotes_Locale = ...
    local L = MightyNotes_Locale.L	
	
    ------- DEBUGGING -------	
	local DEBUG = false
	local function print_d(text) 
		if DEBUG then
			print("Debug: " .. text)
		end
	end
	
    ------- ALLOW ARROW KEYS -------
    
    for i = 1, NUM_CHAT_WINDOWS do
        _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
    end

    ------- SCROLL WITH MOUSEWHEEL -------

    local function ScrollFrame_OnMouseWheel(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20);
        newValue = math.max(newValue, 0);
        newValue = math.min(newValue, self:GetVerticalScrollRange());
        self:SetVerticalScroll(newValue);
    end

    ------- CREATE PARENT UI -------

    local UIConfig = CreateFrame("Frame", "MightyNotes_Frame", UIParent, "BasicFrameTemplateWithInset");
	local addonName = "MightyNotes"
	firstLoad = 1
    UIConfig:SetSize(600, 360);
    UIConfig:SetPoint("CENTER", UIParent, "CENTER");
    UIConfig:SetMovable(true);
    UIConfig:EnableMouse(true);
    UIConfig:RegisterForDrag("LeftButton");
    UIConfig:SetScript("OnDragStart", UIConfig.StartMoving);
    UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing);
    UIConfig:SetClampedToScreen(true);

    ------- CHILDREN AND REGIONS -------

        ------- MENU TITLE -------
        UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0);
        UIConfig.title:SetText(addonName);

        ------- SAVE BUTTON -------
        UIConfig.saveButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
        UIConfig.saveButton:SetPoint("RIGHT", UIConfig, "BOTTOMRIGHT", -10, 20);
        UIConfig.saveButton:SetSize(90, 20);
        UIConfig.saveButton:SetText(L['Save']);
        UIConfig.saveButton:SetNormalFontObject("GameFontNormal");
        UIConfig.saveButton:SetHighlightFontObject("GameFontHighlight");

        ------- UPDATE BUTTON -------
        UIConfig.updateButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
        UIConfig.updateButton:SetPoint("RIGHT", UIConfig, "BOTTOMRIGHT", -100, 20);
        UIConfig.updateButton:SetSize(120, 20);
        UIConfig.updateButton:SetText(L['Update']);
        UIConfig.updateButton:SetNormalFontObject("GameFontNormal");
        UIConfig.updateButton:SetHighlightFontObject("GameFontHighlight");

        ------- ADD BUTTON -------
        UIConfig.addButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
        UIConfig.addButton:SetPoint("LEFT", UIConfig, "BOTTOMLEFT", 10, 20);
        UIConfig.addButton:SetSize(20, 20);
        UIConfig.addButton:SetText(" + ");
        UIConfig.addButton:SetNormalFontObject("GameFontNormal");
        UIConfig.addButton:SetHighlightFontObject("GameFontHighlight");

        ------- DELETE BUTTON -------
        UIConfig.deleteButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate");
        UIConfig.deleteButton:SetPoint("LEFT", UIConfig, "BOTTOMLEFT", 30, 20);
        UIConfig.deleteButton:SetSize(20, 20);
        UIConfig.deleteButton:SetText(" - ");
        UIConfig.deleteButton:SetNormalFontObject("GameFontNormal");
        UIConfig.deleteButton:SetHighlightFontObject("GameFontHighlight");

        ------- NAVBAR SECTION -------

        UIConfig.navbar = CreateFrame("Frame", "MightyNotes_Navbar", UIConfig);
        UIConfig.navbar:SetSize(150, 350);
        UIConfig.navbar:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 10, -40);
        UIConfig.navbar:SetClipsChildren(true);

        ------- NAVBAR SCROLLFRAME -------

        UIConfig.navScrollFrame = CreateFrame("ScrollFrame", "MightyNotes_ScrollFrame", UIConfig, "UIPanelScrollFrameTemplate");
        UIConfig.navScrollFrame:SetSize(145, 280);
        UIConfig.navScrollFrame:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 0, -40);
        UIConfig.navScrollFrame:SetScrollChild(UIConfig.navbar);
        UIConfig.navScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

        ------- Misc. Notes -------

        local function RefreshNoteList()
			print_d("RefNoteList...");
            -- Ensure we have a table to store the buttons
            UIConfig.navbar.noteButtons = UIConfig.navbar.noteButtons or {}
			 
            -- Loop through each note and either reuse or create buttons
            for i, note in ipairs(MightyNotesList) do
                local button = UIConfig.navbar.noteButtons[i]
				selectedNoteIndex = i
								
				-- Create a new button if it doesn't exist yet
				if not button then
					button = CreateFrame("Button", nil, UIConfig.navbar, "GameMenuButtonTemplate")
					button:SetSize(135, 20)
					button:SetNormalFontObject("GameFontNormal")
					button:SetHighlightFontObject("GameFontHighlight")
					-- Store the button in the list
					UIConfig.navbar.noteButtons[i] = button
				end
		
				-- Set the button position and properties
				button:SetPoint("TOP", UIConfig.navbar, "TOP", 5, -((i - 1) * 25))
				button:SetText(MightyNotesList[selectedNoteIndex][1])

				-- Ensure the button is shown (in case it was hidden before)
				button:Show()
		
				-- Set the click behavior to load the correct note
				button:SetScript("OnClick", function(self, button)
					if button == "LeftButton" then		
						-- Update the FrameTitle onClick [with selectedNoteIndex]
						UIConfig.title:SetText(addonName .. " | " .. MightyNotesList[selectedNoteIndex][1]);
						UIConfig:Show();			
						selectedNoteIndex = i  
						latestSelectedNoteIndex['id'] = selectedNoteIndex
						UIConfig.editBox:SetText(MightyNotesList[selectedNoteIndex][2])
						AdjustEditBoxHeight();		
						
					elseif button == "RightButton" then																   
						local dialog = StaticPopup_Show("RENAME")						
						if (dialog) then
							dialog.data  = selectedNoteIndex 
							dialog.data2 = UIConfig.navbar.noteButtons[i]:GetText()
						end
					end
				end)
				button:RegisterForClicks("AnyDown", "AnyUp");
			
            end
        
            -- Hide any unused buttons (in case there are more buttons than notes)
            for i = #MightyNotesList + 1, #UIConfig.navbar.noteButtons do
                UIConfig.navbar.noteButtons[i]:Hide();
            end			
			
			if firstLoad > 0 then
				print_d("Firstload: " .. firstLoad);
				-- Set lastSelected as first onShow
				if latestSelectedNoteIndex['id'] then
					selectedNoteIndex = latestSelectedNoteIndex["id"]
					print_d("   > #LSID: " .. selectedNoteIndex);
				else 
					print_d("   x #LSID: ");
				end	
				print_d("       SN: " .. selectedNoteIndex);
				-- Update the FrameTitle onShow [with lastSelectedIndex] and setText to editBox
				if MightyNotesList[selectedNoteIndex] then
					if MightyNotesList[selectedNoteIndex][1] then
						UIConfig.title:SetText(addonName .. " | " .. MightyNotesList[selectedNoteIndex][1]);
						UIConfig.editBox:SetText(MightyNotesList[selectedNoteIndex][2]);
						UIConfig:Show();
					end
				else
					UIConfig.title:SetText(addonName)
				end
				firstLoad = 0
			end
						
        end

        ------- editable text area -------

        UIConfig.scrollFrame = CreateFrame("ScrollFrame", "MightyNotes_ScrollFrame", UIConfig, "UIPanelScrollFrameTemplate");
        UIConfig.scrollFrame:SetSize(400, 275);
        UIConfig.scrollFrame:SetPoint("TOPRIGHT", UIConfig, "TOPRIGHT", -30, -40);
        --UIConfig.scrollFrame:SetClipsChildren(true);

        ------- EDITBOX -------

        UIConfig.editBox = CreateFrame("EditBox", "MightyNotes_EditBox", UIConfig.scrollFrame);
        UIConfig.editBox:SetMultiLine(true);
        UIConfig.editBox:SetFontObject("ChatFontNormal");
        UIConfig.editBox:SetSize(390, 500);
        UIConfig.editBox:SetAutoFocus(false);
		if MightyNotesList[selectedNoteIndex] then
			if MightyNotesList[selectedNoteIndex][2] then
				UIConfig.editBox:SetText(MightyNotesList[selectedNoteIndex][2]);
			else
				UIConfig.editBox:SetText("");
			end
		else
			UIConfig.editBox:SetText("");
		end
			
        UIConfig.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end);

        local function AdjustEditBoxHeight()
            local contentHeight = UIConfig.editBox:GetTextHeight() + 20;
            UIConfig.editBox:SetHeight(math.max(contentHeight, 200));
        end

        UIConfig.editBox:SetScript("OnTextChanged", function(self)
            AdjustEditBoxHeight();
        end)

        UIConfig.scrollFrame:SetScrollChild(UIConfig.editBox);
        UIConfig.scrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

        UIConfig:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and UIConfig.editBox:HasFocus() then
                -- Clear focus from the EditBox when clicking outside it
                UIConfig.editBox:ClearFocus();
            end
        end)

        ------- SAVE BUTTON FUNCTIONALITY -------
        UIConfig.saveButton:SetScript("OnClick", function()
			MightyNotesList[selectedNoteIndex][1] = MightyNotesList[selectedNoteIndex][1]
			MightyNotesList[selectedNoteIndex][2] = UIConfig.editBox:GetText();	
            print(L["Note " .. selectedNoteIndex .. " saved!"]);
        end)

        ------- ADD BUTTON FUNCTIONALITY -------
        UIConfig.addButton:SetScript("OnClick", function()
            table.insert(MightyNotesList, {L["Note "] .. #MightyNotesList + 1, L["Place notes here"]});
            selectedNoteIndex = #MightyNotesList;
            UIConfig.editBox:SetText(L["Place notes here"]);
            RefreshNoteList();
            MightyNotesList[selectedNoteIndex][2] = UIConfig.editBox:GetText();
            print(L["New note added!"]);
        end)

        ------- DELETE BUTTON FUNCTIONALITY -------
        UIConfig.deleteButton:SetScript("OnClick", function()
			print_d("Del-MNL: " .. #MightyNotesList);
			latestSelectedNoteIndex["id"] = 0
            if #MightyNotesList > 0 then
                table.remove(MightyNotesList, selectedNoteIndex);
                selectedNoteIndex_tmp = math.max(selectedNoteIndex - 1, 1);
				if selectedNoteIndex_tmp > 0 then
					latestSelectedNoteIndex["id"] = selectedNoteIndex_tmp
					UIConfig.editBox:SetText(MightyNotesList[selectedNoteIndex_tmp][2] or "");
				else 
					UIConfig.editBox:SetText(L["Create a new note or open one."]);
				end
				print(L["Note deleted!"]);
			else
				UIConfig.editBox:SetText(L["Create a new note or open one."]);
			end
			RefreshNoteList();                
        end)

        ------- UPDATE BUTTON FUNCTIONALITY -------
        UIConfig.updateButton:SetScript("OnClick", function()
            RefreshNoteList();
        end)
		
	------- RENAME BUTTON FUNCTIONALITY -------
	StaticPopupDialogs["RENAME"] = {
		text = L["New name of the note"],
        button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxLetters = 15,
		OnAccept = function(self, data)
			local editBox = self.editBox
			local text = editBox:GetText()
            local btnToChange = UIConfig.navbar.noteButtons[data]
            btnToChange:SetText(text);
			print_d("data= " .. data);
			MightyNotesList[data][1] = text
		end,
		EditBoxOnEnterPressed = function(self, data)	--<-- /!\ same like the button OnAccept
			local editBox = self:GetParent().editBox
			local text = editBox:GetText()
					--------------------------
					local btnToChange = UIConfig.navbar.noteButtons[data]
					btnToChange:SetText(text);
					print_d("data= " .. data);
					MightyNotesList[data][1] = text
					--------------------------
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide()
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}

    ------- INITIAL NOTE CREATION -------
    local function InitializeNotes()
        if #MightyNotesList == 0 then
			table.insert(MightyNotesList, {L["Note 1"], L["Place notes here"]});
            selectedNoteIndex = #MightyNotesList;
            --print(L["First note added!"]);
            print_d(L["Note count: " .. selectedNoteIndex]);
        else	
            selectedNoteIndex = math.min(selectedNoteIndex, #MightyNotesList);
            RefreshNoteList();
			print_d("Note count: " .. #MightyNotesList);
        end
    end

    ------- LOAD EXISTING NOTES ON SHOW -------
    UIConfig:SetScript("OnShow", function()
		RefreshNoteList();			
		if latestSelectedNoteIndex["id"] then
			UIConfig.editBox:SetText(MightyNotesList[latestSelectedNoteIndex["id"]][2]);
			UIConfig.title:SetText(addonName .. " | " .. MightyNotesList[latestSelectedNoteIndex["id"]][1]);
			UIConfig.Show();
			AdjustEditBoxHeight();
		else
			if MightyNotesList[selectedNoteIndex] then
				UIConfig.editBox:SetText(MightyNotesList[selectedNoteIndex][2]);
				AdjustEditBoxHeight();
			else
				print_d("NoteList empty");
				UIConfig.editBox:SetText(L["Create a new note or open one."]);
			end		
		end
    end)
	
    UIConfig:Hide();

    ------- Initial setup -------
    RefreshNoteList();
    InitializeNotes();

    ------- COMMANDS -------

    SLASH_MIGHTYNOTES1 = "/mightynotes"
    SlashCmdList.MIGHTYNOTES = function()
		if not UIConfig:IsShown() then
			UIConfig:Show()
		else 
			UIConfig:Hide()
		end
    end
