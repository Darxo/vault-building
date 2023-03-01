local oldReset = ::Const.World.Buildings.reset;
::Const.World.Buildings.reset = function()
{
    oldReset();
    this.Vaults = 0;
}
