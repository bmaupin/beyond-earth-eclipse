include( "IconSupport" );

-------------------------------------------------
-- Victory Progress Popup
-------------------------------------------------

local m_PopupInfo = nil;

-- TODO: is this needed? remove it and see if it breaks anything
-- Since this is an enum, it just has to be a unique number; I just generated a random 6-digit number 🤷‍♂️
ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS = 823485;

function OnPopup( popupInfo )
	if( popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_VICTORY_PROGRESS ) then
		return;
	end

	local victoryType = popupInfo.Data1;

	Controls.AlphaAnim:SetToBeginning();
	Controls.AlphaAnim:Play();

	-- Find the corresponding quest entry
	local questInfo = GameInfo.Quests[victoryType];

	-- TODO: title text isn't working; it's saying "Gifts from Home"
	-- Set the title based on the victory type
	if questInfo then
		Controls.TitleText:SetText(Locale.ConvertTextKey(questInfo.Description));  -- Localized title
	end

	-- TODO: image isn't working
	-- Set the image based on the victory type
	if questInfo and questInfo.IconAtlas and questInfo.PortraitIndex then
		IconHookup(questInfo.PortraitIndex, 128, questInfo.IconAtlas, Controls.Image);
	end

	-- Set the description text
	Controls.BodyText:LocalizeAndSetText(popupInfo.Text);

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

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked);
