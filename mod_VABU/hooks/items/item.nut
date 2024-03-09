::modVABU.HooksMod.hookTree("scripts/items/item", function(q) {
	// sets buy/sell price to 0 when using the vault building
	q.getBuyPrice = @(__original) function()
	{
		if (("State" in ::World) && ::World.State != null && ::World.State.getCurrentTown() != null && ::World.State.getCurrentTown().m.CurrentBuilding != null && ::World.State.getCurrentTown().m.CurrentBuilding.m.ID == "building.vault")
		{
			return 0.0;
		}
		else
		{
			return __original();
		}
	}

	q.getSellPrice = @(__original) function()
	{
		if (("State" in ::World) && ::World.State != null && ::World.State.getCurrentTown() != null && ::World.State.getCurrentTown().m.CurrentBuilding != null && ::World.State.getCurrentTown().m.CurrentBuilding.m.ID == "building.vault")
		{
			return 0.0;
		}
		else
		{
			return __original();
		}
	}
});
