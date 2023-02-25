::modVABU <- {
	ID = "mod_VABU",
	Name = "Vault Building",
	Version = "0.1.0",
	Const = {
		GuaranteedVaults = 2	// The game tries to spawn this many Vaults per new map.
	},
	Config = {
		VaultSpaceLimit = 60,	// Maximum amount of slots you can unlock in each Vault
		UnlockedSlots = 5,		// Unlocked Slots at the start
		BaseCost = 100,
		CostPerSlot = 25,	// Cost per already unlocked slot

		IsUnlockedFromNoblesAware = false,	// Access to the vaults unlocks alongside the noble contracts
		ClosedFromSituations = true		// Situation specific can cause the vault to temporarily close
	}
}

::mods_registerMod(::modVABU.ID, ::modVABU.Version, ::modVABU.Name);

::mods_queue(::modVABU.ID, "mod_msu, >mod_legends, >mod_URUI", function()
{
	::modVABU.Mod <- ::MSU.Class.Mod(::modVABU.ID, ::modVABU.Version, ::modVABU.Name);

	::includeFiles(::IO.enumerateFiles("mod_VABU/hooks"));

    ::mods_registerJS("mod_VABU/screens/world/modules/world_town_screen/world_town_screen_vault_dialog_module.js");
    ::mods_registerJS("mod_VABU/screens/world/modules/world_town_screen/world_town_screen.js");
    ::mods_registerJS("mod_VABU/enums.js");

    ::mods_registerCSS("mod_VABU/screens/world/modules/world_town_screen/world_town_screen_vault_dialog_module.css");

	::modVABU.calculateSlotPrice <- function (_currentSlots, _town = null)
	{
		return ::modVABU.Config.BaseCost + (::modVABU.Config.CostPerSlot * _currentSlots);
	}

	::Const.World.Buildings.Vaults <- 0;

	local oldReset = ::Const.World.Buildings.reset;
	::Const.World.Buildings.reset = function()
	{
		oldReset();
		this.Vaults = 0;
	}

/*	// Insert a custom id in a mod-friendly way
	{	// We want our new id right at the first empty position
		local positionToCheck = 10;
		local foundPosition = true;
 		while (true)
		{
			foreach(errorID in ::Const.UI.Error)
			{
				if (foundPosition == errorID)
				{
					positionToCheck++;
					foundPosition = false;
					break;
				}
			}
			if (foundPosition) break;
		}
	}*/

	// It is important that this is the same/synchronized with the Error Code on javascript side
	::Const.UI.Error.NotEnoughVaultSpace <- 401;    // TODO: Replace once MSU implements some nice cross-sync feature

	// You can globally call this function with a dev-console mod in order to spawn [more] vaults into an existing savegame
	::modVABU.spawnVaultBuildings <- function( _amount, _ignoreCitySize = false )
	{
		local settlements = ::World.EntityManager.getSettlements();

		local candidates = [];

		foreach( s in settlements )
		{
			if ((s.getSize() == 1 || _ignoreCitySize) && s.hasFreeBuildingSlot() && s.isMilitary() && !s.hasBuilding("building.vault"))
			{
				candidates.push(s);
			}
		}
		local vaultsSpawned = 0;
		for( local i = 0; i < _amount; i = ++i )
		{
			if (candidates.len() == 0) break;

			local r = ::Math.rand(0, candidates.len() - 1);
			local s = candidates[r];
			candidates.remove(r);
			s.addBuilding(::new("scripts/entity/world/settlements/buildings/vabu_vault_building"));
			vaultsSpawned++;
		}
		::logWarning(vaultsSpawned + " vaults were spawned in the world.");
	}
});
