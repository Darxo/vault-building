::mods_hookNewObject("ui/screens/world/world_town_screen", function(o)
{
    o.m.VaultDialogModule <- ::new("scripts/ui/screens/world/modules/world_town_screen/town_vault_dialog_module");
    o.m.VaultDialogModule.setParent(o);
    o.m.VaultDialogModule.connectUI(o.m.JSHandle);

	o.getVaultDialogModule <- function()
	{
		return this.m.VaultDialogModule;
	}

    local oldDestroy = o.destroy;
    o.destroy = function()
    {
        this.clearEventListener();
        this.m.VaultDialogModule.destroy();
        this.m.VaultDialogModule = null;
        oldDestroy();
    }

    local oldShowLastActiveDialog = o.showLastActiveDialog;
    o.showLastActiveDialog = function()
    {
        if (this.m.LastActiveModule == this.m.VaultDialogModule)
        {
            this.showVaultDialog();
        }
        else
        {
            oldShowLastActiveDialog();
        }
    }

    o.showVaultDialog <- function()
	{
		if (this.m.JSHandle != null && this.isVisible())
		{
			this.m.LastActiveModule = this.m.VaultDialogModule;
			::Tooltip.hide();
			this.m.JSHandle.asyncCall("showVaultDialog", this.m.VaultDialogModule.queryShopInformation());  // Todo: change to Vault
		}
	}

    local oldIsAnimating = o.isAnimating
	o.isAnimating = function()
	{
        if (this.m.VaultDialogModule != null && this.m.VaultDialogModule.isAnimating()) return true;
        return oldIsAnimating();
	}

});
