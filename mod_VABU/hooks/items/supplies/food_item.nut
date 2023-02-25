::mods_hookExactClass("items/supplies/food_item", function(o)
{
    local oldOnAddedToStash = o.onAddedToStash;
	o.onAddedToStash = function( _stashID )
	{
        if ( ::World.State.getCurrentTown() == null) return oldOnAddedToStash( _stashID );
        local building = ::World.State.getCurrentTown().getCurrentBuilding();
        if (building == null || building.getID() != "building.vault") return oldOnAddedToStash( _stashID );

        // For some reason the world asset food count doesn't update in this specific case
		if (_stashID == "player" && this.m.BestBefore != 0) ::World.Assets.updateFood();    // Because Vanilla doesn't update Food under these conditions

        // Vanilla tries to assign bought prices whenever Items are added to the player stash while inside a town.
        // But for the Vault I don't want this behavior
        local oldBestBefore = this.m.BestBefore;
        local oldBoughtAtPrice = this.m.BoughtAtPrice;
        oldOnAddedToStash(_stashID);
        this.m.BestBefore = oldBestBefore;
        this.m.BoughtAtPrice = oldBoughtAtPrice;
	}
});
