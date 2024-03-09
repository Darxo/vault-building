::modVABU.HooksMod.hook("scripts/ui/screens/world/world_town_screen", function(q) {
	q.m.VaultDialogModule <- null;

	q.create = @(__original) function()
	{
		__original();
		this.m.VaultDialogModule = ::new("scripts/ui/screens/world/modules/world_town_screen/town_vault_dialog_module");
		this.m.VaultDialogModule.setParent(this);
		this.m.VaultDialogModule.connectUI(this.m.JSHandle);
	}

	q.destroy = @(__original) function()
	{
		this.clearEventListener();
		this.m.VaultDialogModule.destroy();
		this.m.VaultDialogModule = null;
		__original();
	}

	q.showLastActiveDialog = @(__original) function()
	{
		if (this.m.LastActiveModule == this.m.VaultDialogModule)
		{
			this.showVaultDialog();
		}
		else
		{
			__original();
		}
	}

	q.isAnimating = @(__original) function()
	{
		if (this.m.VaultDialogModule != null && this.m.VaultDialogModule.isAnimating()) return true;
		return __original();
	}

// New Functions
	q.showVaultDialog <- function()
	{
		if (this.m.JSHandle != null && this.isVisible())
		{
			this.m.LastActiveModule = this.m.VaultDialogModule;
			::Tooltip.hide();
			this.m.JSHandle.asyncCall("showVaultDialog", this.m.VaultDialogModule.queryShopInformation());  // Todo: change to Vault
		}
	}

	q.getVaultDialogModule <- function()
	{
		return this.m.VaultDialogModule;
	}
});
