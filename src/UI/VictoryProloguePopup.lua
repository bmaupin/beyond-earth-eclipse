-------------------------------------------------
-- Victory Prologue Popup
-------------------------------------------------

local m_PopupInfo = nil;

-- NOTE: This is needed, do not remove it
-- Since this is an enum, it just has to be a unique number; I just generated a random 6-digit number 🤷‍♂️
ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE = 823485;

local function getQuestByID(questID)
    for quest in GameInfo.Quests() do
        if quest.ID == questID then
            return quest
        end
    end
    return nil
end

function OnPopup( popupInfo )
	if (popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE) then
		return;
	end

	Controls.AlphaAnim:SetToBeginning();
	Controls.AlphaAnim:Play();

	local prologueTitle = 'PROLOGUE';
	local questIndex = popupInfo.Data1;
	local questInfo = getQuestByID(questIndex);

	if questInfo then
		Controls.TitleLabel:SetText(prologueTitle .. ': ' .. Locale.ToUpper(Locale.ConvertTextKey(questInfo.Description)));
	else
		Controls.TitleLabel:SetText(prologueTitle);
	end

	if questInfo and questInfo.Type then
		if (questInfo.Type == "QUEST_VICTORY_CONTACT") then
			Controls.Banner:SetTexture("Victory_Contact.dds");
			-- We're creating a banner from a larger image, so offset it a bit to pick
			-- the part we want
			Controls.Banner:SetTextureOffsetVal(0, 90);
		elseif (questInfo.Type == "QUEST_VICTORY_DOMINATION") then
			Controls.Banner:SetTexture("Victory_Military_P.dds");
			Controls.Banner:SetTextureOffsetVal(0, 104);
		elseif (questInfo.Type == "QUEST_VICTORY_EMANCIPATION") then
			Controls.Banner:SetTexture("Victory_Emancipation.dds");
			Controls.Banner:SetTextureOffsetVal(0, 54);
		elseif (questInfo.Type == "QUEST_VICTORY_PROMISED_LAND") then
			Controls.Banner:SetTexture("Victory_Promised.dds");
			Controls.Banner:SetTextureOffsetVal(0, 66);
		elseif (questInfo.Type == "QUEST_VICTORY_TRANSCENDENCE") then
			Controls.Banner:SetTexture("Victory_Transcend.dds");
		end
	end

	Controls.BodyText:LocalizeAndSetText(popupInfo.Text);

	-- Get the size of the content in the stack so we can resize popup to hold everything
	local contentSize = Controls.ContentStack:GetSizeY();
	-- Add the height of the label and the close button plus a little margin
	Controls.OuterGrid:SetSizeY(contentSize + 48 + 35 + 30);
	Controls.OuterGrid:ReprocessAnchoring();

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
            Events.SerialEventGameMessagePopupProcessed.CallImmediate( ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROLOGUE, 0 );
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

-- NOTE: The popups in the game source don't have this but it seems necessary for mods,
--       otherwise the popup will show right away when a game is loaded or started and
--       can't be dismissed.
-- The source for this function came from Codex (https://steamcommunity.com/sharedfiles/filedetails/?id=780912351)
-- in the file randomeventoverviewpopup.lua
function OnLoadScreenClose()
	UIManager:QueuePopup(ContextPtr, PopupPriority.TextPopup)
	UIManager:DequeuePopup(ContextPtr)
	-- 'Active' (local human) player has changed
	Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked)
end
Events.LoadScreenClose.Add(OnLoadScreenClose)
