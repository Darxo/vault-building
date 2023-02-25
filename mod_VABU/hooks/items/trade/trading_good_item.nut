::mods_hookExactClass("items/trade/trading_good_item", function(o)
{
    local oldOnAddedToStash = o.onAddedToStash;
	o.onAddedToStash = function( _stashID )
	{
        if ( ::World.State.getCurrentTown() == null) return oldOnAddedToStash( _stashID );
        local building = ::World.State.getCurrentTown().getCurrentBuilding();
        if (building == null || building.getID() != "building.vault") return oldOnAddedToStash( _stashID );

        // Vanilla tries to assign bought prices whenever Items are added to the player stash while inside a town.
        // But for the Vault I don't want this behavior
        local oldBoughtAtPrice = this.m.BoughtAtPrice;
        oldOnAddedToStash(_stashID);
        this.m.BoughtAtPrice = oldBoughtAtPrice;
	}
});
