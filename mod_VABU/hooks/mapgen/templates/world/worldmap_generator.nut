::mods_hookNewObject("mapgen/templates/world/worldmap_generator", function(o)
{
    local oldGuaranteeAllBuildingsInSettlements = o.guaranteeAllBuildingsInSettlements;
    o.guaranteeAllBuildingsInSettlements = function()
    {
        if (::modVABU.Config.SpawnDuringMapGeneration == false) return oldGuaranteeAllBuildingsInSettlements();

        if (::Const.World.Buildings.Vaults < ::modVABU.Const.GuaranteedVaults)
        {
            local vaultsToSpawn = ::modVABU.Const.GuaranteedVaults - ::Const.World.Buildings.Vaults;
            ::modVABU.spawnVaultBuildings(vaultsToSpawn);

            if (::Const.World.Buildings.Vaults == 0)
            {
                ::logWarning("No Vaults are placed on the world map!");
            }
        }

        oldGuaranteeAllBuildingsInSettlements();
    }
});
