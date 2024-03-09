::modVABU.HooksMod.hook("scripts/items/trade/trading_good_item", function(q) {
	q.onAddedToStash = @(__original) function( _stashID )
	{
		if (::World.State == null) return __original(_stashID);
		if (::World.State.getCurrentTown() == null) return __original(_stashID);

		local building = ::World.State.getCurrentTown().getCurrentBuilding();
		if (building == null || building.getID() != "building.vault") return __original(_stashID);

		// Vanilla tries to assign bought prices whenever Items are added to the player stash while inside a town.
		// But for the Vault I don't want this behavior
		local oldBoughtAtPrice = this.m.BoughtAtPrice;
		__original(_stashID);
		this.m.BoughtAtPrice = oldBoughtAtPrice;
	}
});
