::mods_hookDescendants("items/item", function ( o ) // copied from Taro Stronghold mod
{
	// sets buy/sell price to 0 when using stronghold marketplace
	local getBuyPrice = ::mods_getMember(o, "getBuyPrice")
	local getSellPrice = ::mods_getMember(o, "getSellPrice")
	o.getBuyPrice <- function()
	{
		if (("State" in ::World) && ::World.State != null && ::World.State.getCurrentTown() != null && ::World.State.getCurrentTown().m.CurrentBuilding != null && ::World.State.getCurrentTown().m.CurrentBuilding.m.ID == "building.vault")
		{
			return 0.0;
		}
		else
		{
			return getBuyPrice();
		}
	}

	o.getSellPrice <- function()
	{
		if (("State" in ::World) && ::World.State != null && ::World.State.getCurrentTown() != null && ::World.State.getCurrentTown().m.CurrentBuilding != null && ::World.State.getCurrentTown().m.CurrentBuilding.m.ID == "building.vault")
		{
			return 0.0;
		}
		else
		{
			return getSellPrice();
		}
	}
});
