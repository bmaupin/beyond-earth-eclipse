local isRisingTideActive = ContentManager.IsActive("54D2B257-C591-4045-8F17-A69F033166C7", ContentType.GAMEPLAY);
if isRisingTideActive then
	include("AssignStartingPlots-RisingTide");
else
	include("AssignStartingPlots-BaseGame");
end
