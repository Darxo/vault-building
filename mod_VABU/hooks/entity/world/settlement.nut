::mods_hookExactClass("entity/world/settlement", function(o)
{
    local oldAddBuilding = o.addBuilding;
    o.addBuilding = function( _building, _slot = null )
    {
        oldAddBuilding(_building, _slot);
        if (_building.getID() == "building.vault")
        {
            ::Const.World.Buildings.Vaults++;
        }
    }
});
