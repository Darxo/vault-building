::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function(o)
{
    local oldGeneral_queryUIElementTooltipData = o.general_queryUIElementTooltipData;
    o.general_queryUIElementTooltipData = function ( _entityId, _elementId, _elementOwner )
    {
        if(_elementId == "world-town-screen.main-dialog-module.Vault")
        {
			local ret = [
				{
					id = 1,
					type = "title",
					text = "City Vault"
				},
				{
					id = 2,
					type = "description",
					text = "A secure storage building that you can use to store items for later use."
				}
			];
			if (::World.State.getCurrentTown() != null)
			{
				local vault = ::World.State.getCurrentTown().getBuilding("building.vault");
				if (vault.isClosedFromSituations())
				{
					ret.push({
						id = 6,
						type = "hint",
						icon = "ui/tooltips/warning.png",
						text = "This building is currently closed due to negative situations in this settlement"
					});
				}
				else if (vault.isUnlocked() == false)
				{
					ret.push({
						id = 7,
						type = "hint",
						icon = "ui/tooltips/warning.png",
						text = "You need to fulfill the Ambition 'Make Nobles Aware' in order to unlock this building"
					});
				}
				else if (vault.isClosed())
				{
					ret.push({
						id = 6,
						type = "hint",
						icon = "ui/tooltips/warning.png",
						text = "This building is currently closed for unknown reasons"
					});
				}
			}
			return ret;
        }

		if (_elementId == "world-town-screen.vault-dialog-module.LeaveButton")
		{
			return [
				{
					id = 1,
					type = "title",
					text = "Leave Vault"
				},
				{
					id = 2,
					type = "description",
					text = "Leave this screen and return to the previous one."
				}
			];
		}

		if (_elementId == "world-town-screen.vault-dialog-module.BuyButton")
		{
			local ret = [
				{
					id = 1,
					type = "title",
					text = "Buy New Slot"
				},
				{
					id = 2,
					type = "description",
					text = "Permanently unlock a new storage slot in this vault."
				}
			];
			local vault = ::World.State.getTownScreen().getVaultDialogModule().getShop().getStash();
			if (vault.getCapacity() == ::modVABU.Config.VaultSpaceLimit)
			{
				ret.push({
					id = 5,
					type = "hint",
					icon = "ui/tooltips/warning.png",
					text = "Maximum Limit is reached. You can't buy more slots."
				})
			}
			return ret;
		}

		if (_elementId == "world-town-screen.vault-dialog-module.SlotCostLabel")
		{
			return [
				{
					id = 1,
					type = "title",
					text = "Slot Cost"
				},
				{
					id = 2,
					type = "description",
					text = "Price for unlocking the next slot permanently."
				},
				{
					id = 3,
					type = "text",
					icon = "ui/icons/asset_money.png",
					text = "Base Cost: " + ::modVABU.Config.BaseCost
				},
				{
					id = 4,
					type = "text",
					icon = "ui/icons/asset_money.png",
					text = "Cost per already unlocked Slot: " + ::modVABU.Config.CostPerSlot
				}
			];
		}

		if (_elementId == "vault.FreeSlots")
		{
			return [
				{
					id = 1,
					type = "title",
					text = "Vault Capacity"
				},
				{
					id = 2,
					type = "description",
					text = "Shows your current and maximum storage space in this vault."
				}
			];
		}

        return oldGeneral_queryUIElementTooltipData( _entityId, _elementId, _elementOwner );;
    }

    local oldTactical_helper_addHintsToTooltip = o.tactical_helper_addHintsToTooltip;
    o.tactical_helper_addHintsToTooltip = function ( _activeEntity, _entity, _item, _itemOwner, _ignoreStashLocked = false )
	{
		local ret = oldTactical_helper_addHintsToTooltip( _activeEntity, _entity, _item, _itemOwner, _ignoreStashLocked );
		if (_itemOwner == "world-town-screen-vault-dialog-module.vault")
		{
			if (!::Stash.hasEmptySlot())
			{
				ret.push({
					id = 5,
					type = "hint",
					icon = "ui/tooltips/warning.png",
					text = "Stash is full"
				});
			}
			if (_item.isItemType(::Const.Items.ItemType.Food))
			{
				ret.push({
					id = 6,
					type = "hint",
					icon = "ui/tooltips/warning.png",
					text = "This food will keep spoiling in here"
				});
			}
		}
		return ret
	}

    local oldStrategic_queryUIItemTooltipData = o.strategic_queryUIItemTooltipData;
    o.strategic_queryUIItemTooltipData = function ( _entityId, _itemId, _itemOwner )
	{
		if (_itemOwner == "world-town-screen-vault-dialog-module.stash")
		{
			local result = this.Stash.getItemByInstanceID(_itemId);

			if (result != null)
			{
				return this.tactical_helper_addHintsToTooltip(null, null, result.item, _itemOwner, true);
			}

			return null;
		}
		if (_itemOwner == "world-town-screen-vault-dialog-module.vault")
		{
			local stash = ::World.State.getTownScreen().getVaultDialogModule().getShop().getStash();

			if (stash != null)
			{
				local result = stash.getItemByInstanceID(_itemId);

				if (result != null)
				{
					return this.tactical_helper_addHintsToTooltip(null, null, result.item, _itemOwner, true);
				}
			}

			return null;
		}
		return oldStrategic_queryUIItemTooltipData( _entityId, _itemId, _itemOwner );
	}

});
