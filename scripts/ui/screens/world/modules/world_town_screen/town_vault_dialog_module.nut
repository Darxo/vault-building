this.town_vault_dialog_module <- this.inherit("scripts/ui/screens/world/modules/world_town_screen/town_shop_dialog_module", {
	m = {},

	function create()
	{
		this.town_shop_dialog_module.create();
		this.m.ID = "VaultDialogModule";
	}

	function onSortButtonClicked()
	{
		this.town_shop_dialog_module.onSortButtonClicked();

		if (this.Tactical.isActive() == false)
		{
			this.getBuilding().getStash().sort();
		}

		this.loadVaultList();
	}

	function onFilterAll()
	{
		local updateVault = (this.m.InventoryFilter != this.Const.Items.ItemFilter.All);
		this.town_shop_dialog_module.onFilterAll();
		if (updateVault) this.loadVaultList();
	}

	function onFilterWeapons()
	{
		local updateVault = (this.m.InventoryFilter != this.Const.Items.ItemFilter.Weapons);
		this.town_shop_dialog_module.onFilterWeapons();
		if (updateVault) this.loadVaultList();
	}

	function onFilterArmor()
	{
		local updateVault = (this.m.InventoryFilter != this.Const.Items.ItemFilter.Armor);
		this.town_shop_dialog_module.onFilterArmor();
		if (updateVault) this.loadVaultList();
	}

	function onFilterMisc()
	{
		local updateVault = (this.m.InventoryFilter != this.Const.Items.ItemFilter.Misc);
		this.town_shop_dialog_module.onFilterMisc();
		if (updateVault) this.loadVaultList();
	}

	function onFilterUsable()
	{
		local updateVault = (this.m.InventoryFilter != this.Const.Items.ItemFilter.Usable);
		this.town_shop_dialog_module.onFilterUsable();
		if (updateVault) this.loadVaultList();
	}

	function queryShopInformation()
	{
		local result = this.town_shop_dialog_module.queryShopInformation();

		// Because original call doesn't apply an ItemFilter. This may not be necessary if used with URUI mod in order to save performance
		result.Shop = [];
		::UIDataHelper.convertItemsToUIData(this.getBuilding().getStash().getItems(), result.Shop, ::Const.UI.ItemOwner.Shop, this.m.InventoryFilter);

		result.VaultInventoryName <- "Storage";
		result.VaultSpaceUsed <- this.getBuilding().getStash().getNumberOfFilledSlots();
		result.VaultSpaceMax <- this.getBuilding().getStash().getCapacity();
		result.VaultSpaceLimit <- this.getBuilding().m.VaultSpaceLimit;
		result.NextSlotCost <- this.getBuilding().getCurrentSlotPrice();

		result.rawdelete("IsRepairOffered");	// We never need this

		return result;
	}

	function onSwapItem( _data )
	{
		local sourceItemIdx = _data[0];
		local sourceItemOwner = _data[1];
		local targetItemIdx = _data[2];
		local targetItemOwner = _data[3];

		if (targetItemOwner == null) { ::logError("onSwapItem #1"); return null; }

		local shopStash = this.getBuilding().getStash();

		switch(sourceItemOwner)
		{
		case "world-town-screen-vault-dialog-module.stash":
			local sourceItem = ::Stash.getItemAtIndex(sourceItemIdx);
			if (sourceItem == null) { ::logError("onSwapItem(stash) #2"); return null; }

			if (targetItemIdx == null)	// We right-clicked on an item from the player stash:
			{
				if (!shopStash.hasEmptySlot())
				{
					return {
						Result = ::Const.UI.Error.NotEnoughVaultSpace	// Shop error needed
					};
				}

				local removedItem = ::Stash.removeByIndex(sourceItemIdx);
				if (removedItem != null)
				{
					removedItem.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
					shopStash.add(removedItem);
				}
			}

			if (targetItemIdx != null && sourceItemOwner == targetItemOwner)	// we swapped an item within the stash
			{
				if (sourceItemOwner == targetItemOwner)
				{
					if (::Stash.swap(sourceItemIdx, targetItemIdx))
					{
						sourceItem.item.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
					}
					else { ::logError("onSwapItem(stash) #3"); return null; }
				}
				else { ::logError("onSwapItem(stash) #3.1"); return null; }
			}
			else if (sourceItemOwner == targetItemOwner)	// we right-clicked an item in the stash
			{
				if (!this.Stash.isLastTakenSlot(sourceItemIdx))
				{
					local firstEmptySlotIdx = this.Stash.getFirstEmptySlot();
					if (firstEmptySlotIdx != null)
					{
						if (!::Stash.swap(sourceItemIdx, firstEmptySlotIdx)) { ::logError("onSwapItem(stash) #4"); return null; }

						sourceItem.item.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
					}
				}
			}
			else	// we dragge an Item from the playerstash into the shop stash
			{
				local targetItem = this.Stash.getItemAtIndex(targetItemIdx);

				if (targetItem != null && targetItem.item == null)	// Dragging an Item on an empty slot
				{
					shopStash.insert(sourceItem.item, targetItemIdx);
					::Stash.removeByIndex(sourceItemIdx);
				}
				else	// Dragging an Item on another item.
				{
					local targetItem = shopStash.insert(sourceItem.item, targetItemIdx);
					if (targetItem != null)
					{
						::Stash.insert(targetItem, sourceItemIdx);
					}
					else
					{
						::Stash.removeByIndex(sourceItemIdx);
					}
					sourceItem.item.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
				}
			}

			local result = this.queryShopInformationLight();
			result.rawdelete("NextSlotCost");
			result.Result <- 0;
			return result;

		case "world-town-screen-vault-dialog-module.vault":
			local sourceItem = shopStash.getItemAtIndex(sourceItemIdx);
			if (sourceItem == null) { ::logError("onSwapItem(found loot) #2"); return null; }

			if (targetItemIdx == null)	// We right-clicked on an item from the shop:
			{
				if (!::Stash.hasEmptySlot()) return { Result = ::Const.UI.Error.NotEnoughStashSpace };

				local removedItem = shopStash.removeByIndex(sourceItemIdx);
				if (removedItem != null)
				{
					removedItem.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
					::Stash.add(removedItem);
				}
			}

			if (targetItemIdx != null)	// We dragged&dropped an item from the shop
			{
				if (sourceItemOwner == targetItemOwner)		// We dragged it onto another item slot from the Shop
				{
					if (!shopStash.swap(sourceItemIdx, targetItemIdx)) { ::logError("onSwapItem(found loot) #3"); return null; }

					sourceItem.item.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
				}
				else	// We dragged it onto an Itemslot from the Player Stash
				{
					local targetItem = this.Stash.getItemAtIndex(targetItemIdx);

					if (targetItem != null && targetItem.item == null)	// Dragging an Item on an empty slot
					{
						::Stash.insert(sourceItem.item, targetItemIdx);
						shopStash.removeByIndex(sourceItemIdx);
					}
					else	// Dragging an Item on another item.
					{
						local targetItem = ::Stash.insert(sourceItem.item, targetItemIdx);
						if (targetItem != null)
						{
							shopStash.insert(targetItem, sourceItemIdx);
						}
						else
						{
							shopStash.removeByIndex(sourceItemIdx);
						}
						sourceItem.item.playInventorySound(::Const.Items.InventoryEventType.PlacedInBag);
					}
				}
			}

			local result = this.queryShopInformationLight();
			result.rawdelete("NextSlotCost");
			result.Result <- 0;
			return result;
		}

		::logError("Couldn't compute 'swap' for: " + sourceItemOwner);
		return null;
	}


// new functions
	function onBuySlotButtonPressed()
	{
		local currentMoney = ::World.Assets.getMoney();
		local cost = this.getBuilding().getCurrentSlotPrice();

		if (currentMoney - cost < 0)
		{
			return {
				Result = ::Const.UI.Error.NotEnoughMoney,
				Data = null
			};
		}

		::World.Assets.addMoney(-cost);
		this.getBuilding().getStash().resize(this.getBuilding().getStash().getCapacity() + 1);
		local data = this.queryVaultList();
		data.VaultSpaceMax <- this.getBuilding().getStash().getCapacity();
		data.NextSlotCost <- this.getBuilding().getCurrentSlotPrice();
		data.Assets <- this.m.Parent.queryAssetsInformation();

		return {
			Result = 0,
			Data = data
		};
	}

	function getBuilding()
	{
		return this.m.Shop;
	}

	function queryVaultList()
	{
		local result = {
			Shop = []
		};
		::UIDataHelper.convertItemsToUIData(this.getBuilding().getStash().getItems(), result.Shop, ::Const.UI.ItemOwner.Shop, this.m.InventoryFilter);
		return result;
	}

	function loadVaultList()
	{
		this.m.JSHandle.asyncCall("loadFromData", this.queryVaultList());
	}

// New Functions
	// Same method that's used in the asset_manager
	function removeExpiredFood()
	{
		foreach( i, item in this.getBuilding().getStash().getItems() )
		{
			if (item != null && item.isItemType(::Const.Items.ItemType.Food))
			{
				if (::Time.getVirtualTimeF() >= item.getBestBeforeTime()) this.getBuilding().getStash().getItems()[i] = null;
			}
		}
	}

	function queryShopInformationLight()
	{
		local result = this.queryShopInformation();

		// These values never change while in the same screen
		result.rawdelete("Title");
		result.rawdelete("SubTitle");
		result.rawdelete("VaultSpaceLimit");	// a bit ironic considering we are the ones writing it in there in the first place

		return result;
	}

});

