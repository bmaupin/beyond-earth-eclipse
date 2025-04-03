include( "IconSupport" );

-------------------------------------------------
-- Victory Progress Popup
-------------------------------------------------

local m_PopupInfo = nil;

-- TODO: is this needed? remove it and see if it breaks anything
-- Since this is an enum, it just has to be a unique number; I just generated a random 6-digit number 🤷‍♂️
ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS = 823485;

-- DELETEME
local function printTable(t, indent)
    indent = indent or ""
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. k .. " = {")
            printTable(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. k .. " = " .. tostring(v))
        end
    end
end

local function GetQuestByID(questID)
    for quest in GameInfo.Quests() do
        if quest.ID == questID then
            return quest
        end
    end
    return nil  -- Return nil if no quest is found
end

function OnPopup( popupInfo )
	if( popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS ) then
		return;
	end

	-- TODO: do we need this?
	Controls.AlphaAnim:SetToBeginning();
	Controls.AlphaAnim:Play();

	local victoryProgressTitle = 'VICTORY PROGRESS';
	local questIndex = popupInfo.Data1;
	local questInfo = GetQuestByID(questIndex);

	-- DELETEME
	if questInfo then
		print("(Eclipse) questInfo = {")
		printTable(questInfo, "  ")
		print("}")
	else
		print("(Eclipse) No quest found with ID=" .. questIndex)
	end

	if questInfo then
		print("(Eclipse) victoryProgressTitle = " .. victoryProgressTitle)
		print("(Eclipse) questInfo.Description = " .. questInfo.Description)
		print("(Eclipse) Locale.ConvertTextKey(questInfo.Description) = " .. Locale.ConvertTextKey(questInfo.Description))
		print("(Eclipse) Locale.ToUpper(Locale.ConvertTextKey(questInfo.Description)) = " .. Locale.ToUpper(Locale.ConvertTextKey(questInfo.Description)))
		Controls.TitleLabel:SetText(victoryProgressTitle .. ': ' .. Locale.ToUpper(Locale.ConvertTextKey(questInfo.Description)));
	else
		Controls.TitleLabel:SetText(victoryProgressTitle);
	end

	-- TODO: image isn't working
	-- Set the image based on the victory type
	if questInfo and questInfo.IconAtlas and questInfo.PortraitIndex then

		-- doesn't work
		-- IconHookup(questInfo.PortraitIndex, 128, questInfo.IconAtlas, Controls.Image);

		-- doesn't work
		-- textureOffset, textureSheet = IconLookup( portraitOffset, 45, portraitAtlas );
		-- local textureOffset;
		-- local textureSheet;
		-- textureOffset, textureSheet = IconHookup(questInfo.PortraitIndex, 91, questInfo.IconAtlas);
		-- if textureSheet ~= nil and textureOffset ~= nil then
		-- 	Controls.Image:SetTexture(textureSheet);
		-- 	Controls.Image:SetTextureOffset(textureOffset);

		-- worked but showed part of next image due to size
		-- IconHookup(questInfo.PortraitIndex, 91, questInfo.IconAtlas, Controls.Image);

		-- Does not work!!
		-- IconHookup(questInfo.PortraitIndex, 128, questInfo.IconAtlas, Controls.Image);
		-- end

		-- <Grid Anchor="C,B" Size="parent,96" Offset="0,0" Padding="0,0" Texture="VictoryButton.dds" SliceStart="0,0" SliceCorner="48,2" SliceTextureSize="96,96"/>

		-- textureOffset, textureSheet = IconHookup(questInfo.PortraitIndex, 91, questInfo.IconAtlas);
		if (questInfo.Type == "QUEST_VICTORY_TRANSCENDENCE") then
			Controls.Banner:SetTexture("Victory_Transcend.dds");
			-- Controls.Banner:SetTextureOffsetVal(184, 203);
			-- image is 953x531
			-- banner size is 585x125
			-- 184,203 -> 769,328
		end
	end

	-- Set the description text
	Controls.DetailsLabel:LocalizeAndSetText(popupInfo.Text);

	-- TODO: uncomment or delete
	-- local textSizeY = Controls.DetailsLabel:GetSizeY();
	-- Controls.Content:SetSizeY(textSizeY + 275);

	-- Controls.Content:ReprocessAnchoring();

	UIManager:QueuePopup(ContextPtr, PopupPriority.InGameUtmost);
end
Events.SerialEventGameMessagePopup.Add( OnPopup );


----------------------------------------------------------------
-- Input processing
----------------------------------------------------------------
function OnCloseButtonClicked ()
	Controls.Banner:UnloadTexture();
    UIManager:DequeuePopup( ContextPtr );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseButtonClicked );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnCloseButtonClicked();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )

    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate( ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS, 0 );
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

-- NOTE: The popups in the game source don't have this but it seems necessary for mods,
--       otherwise the popup will show right away when a game is loaded or started and
--       can't be dismissed.
function OnLoadScreenClose()
	UIManager:QueuePopup(ContextPtr, PopupPriority.TextPopup)
	UIManager:DequeuePopup(ContextPtr)
	-- 'Active' (local human) player has changed
	Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked)
end
Events.LoadScreenClose.Add(OnLoadScreenClose)
