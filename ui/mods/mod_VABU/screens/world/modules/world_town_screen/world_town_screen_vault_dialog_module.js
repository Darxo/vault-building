"use strict";

// TODO find better solution to insert ErrorCode

var WorldTownScreenVault =
{
	ItemOwner:
	{
		Stash: 'world-town-screen-vault-dialog-module.stash',
		Vault: 'world-town-screen-vault-dialog-module.vault'
	},

	ItemFlag:
	{
		Inserted: 0,
		Removed: 1,
		Updated: 2
    },

    OldItemOwnerStash: WorldTownScreenShop.ItemOwner.Stash,    // saves the vanilla WorldTownScreenShop.ItemOwner.Stash value while this DIV exists
    OldItemOwnerShop: WorldTownScreenShop.ItemOwner.Shop      // saves the vanilla WorldTownScreenShop.ItemOwner.Shop value while this DIV exists
};

var WorldTownScreenVaultDialogModule = function(_parent)
{
    var shopModule = new WorldTownScreenShopDialogModule(_parent);
    for (var attrname in shopModule)
    {
        if (typeof shopModule[attrname] === "function" && this[attrname] !== undefined) continue;
        this[attrname] = shopModule[attrname];
        // console.error("attrname copied over: " + attrname);
    }

    // buttons
    this.mBuyButton = null;

// City Vault
    // vault labels
    this.mVaultSlotsizeContainer = null;
    this.mVaultSlotsizeLabel = null;
    this.mVaultSpaceUsed = 0;
    this.mVaultSpaceMax = 0;        // Current slots in the vault
    this.mVaultSpaceLimit = 0;      // Maximum slots that are allowed to be purchased

    this.mNextSlotCost = 0;  // Price for the next slot
    this.mSlotCostLabel = null; // Label for the Price of the next slot
    this.mSlotCostContainer = null  // Container for the slot cost. important because tooltip
};

WorldTownScreenVaultDialogModule.prototype.createDIV = function (_parentDiv)
{
    WorldTownScreenShopDialogModule.prototype.createDIV.call(this, _parentDiv);

    // Compatibility with EIMO by deactivating the SellAll Button they add
	if ('mSellAllButton' in this)
	{
        this.mSellAllButton.enableButton(false);
	}

    var self = this;
    this.mDialogContainer.findDialogFooterContainer().empty();  // Discard all the changes made from original createDIV so we apply out own

    // bottom left footer - leave button
    var footerBarLeft = $('<div class="left-footer-bar-vault"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerBarLeft);

        // create footer left button bar
        var footerButtonBar = $('<div class="l-button-bar"/>');
        footerBarLeft.append(footerButtonBar);

            // create Leave button
            var layout = $('<div class=".l-leave-button"/>');
            footerButtonBar.append(layout);
            this.mLeaveButton = layout.createTextButton("Leave", function()
            {
                self.notifyBackendLeaveButtonPressed();
            }, '', 1);

    // bottom right footer - buy button
    var footerBarRight = $('<div class="right-footer-bar-vault"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerBarRight);

        // create cost label
        this.mSlotCostContainer = $('<div class="row right-slot-cost-container-vault"/>');
        footerBarRight.append(this.mSlotCostContainer);
            var costsLabel = $('<div class="costs-label title-font-normal font-bold font-bottom-shadow font-color-title">Cost</div>');
            this.mSlotCostContainer.append(costsLabel);
            var costsContainer = $('<div class="l-costs-container"/>');
            this.mSlotCostContainer.append(costsContainer);
                // var costsImage = $('<img/>');
                // costsImage.attr('src', Path.GFX + Asset.ICON_ASSET_MONEY);
                // costsContainer.append(costsImage);
                // costsImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.Fee });
                this.mSlotCostLabel = $('<div class="label text-font-normal font-bottom-shadow font-color-description"/>');
                costsContainer.append(this.mSlotCostLabel);

        // create footer right button bar
        var footerButtonBarRight = $('<div class="l-button-bar-vault"/>');
        footerBarRight.append(footerButtonBarRight);

            // create Buy Slot button
            var layout = $('<div class=".l-leave-button"/>');
            footerButtonBarRight.append(layout);
            this.mBuyButton = layout.createTextButton("Buy Slot", function()
            {
                self.buyVaultSlot();
            }, '', 1);

        // create: vault slot size inside the footer button bar
        this.mVaultSlotsizeContainer = $('<div id="vabu-vault-building-stash-size"/>');    // TODO: Maybe custom css to make it appear right border?
        footerBarRight.append(this.mVaultSlotsizeContainer);
        var slotSizeImage = $('<img/>');
        slotSizeImage.attr('src', Path.GFX + Asset.ICON_BAG);
        this.mVaultSlotsizeContainer.append(slotSizeImage);
        this.mVaultSlotsizeLabel = $('<div class="label text-font-small font-bold font-color-value"/>');
        this.mVaultSlotsizeContainer.append(this.mVaultSlotsizeLabel);

    this.mIsVisible = false;
    this.setupEventHandler();
};

WorldTownScreenVaultDialogModule.prototype.destroyDIV = function ()
{

    this.mVaultSlotsizeLabel.remove();
    this.mVaultSlotsizeLabel = null;
    this.mVaultSlotsizeContainer.empty();
    this.mVaultSlotsizeContainer.remove();
    this.mVaultSlotsizeContainer = null;

    this.mBuyButton.remove();
    this.mBuyButton = null;

    this.mSlotCostLabel.empty();
    this.mSlotCostLabel.remove();
    this.mSlotCostLabel = null;
    this.mSlotCostContainer.empty();
    this.mSlotCostContainer.remove();
    this.mSlotCostContainer = null;

    WorldTownScreenShopDialogModule.prototype.destroyDIV.call(this);
};

WorldTownScreenVaultDialogModule.prototype.bindTooltips = function ()
{
    this.mLeaveButton.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.HireDialogModule.LeaveButton});

    WorldTownScreenShopDialogModule.prototype.bindTooltips.call(this);

    this.mVaultSlotsizeContainer.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Vault.FreeSlots });
    this.mBuyButton.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.VaultDialogModule.BuyButton });
    this.mSlotCostContainer.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldTownScreen.VaultDialogModule.SlotCostLabel});
};

WorldTownScreenVaultDialogModule.prototype.unbindTooltips = function ()
{
    WorldTownScreenShopDialogModule.prototype.unbindTooltips.call(this);

	this.mVaultSlotsizeContainer.unbindTooltip();
    this.mBuyButton.unbindTooltip();
    this.mSlotCostContainer.unbindTooltip();
};

WorldTownScreenVaultDialogModule.prototype.loadFromData = function (_data)
{
    WorldTownScreenShopDialogModule.prototype.loadFromData.call(this, _data);

    this.mIsRepairOffered = false;  // just incase

	if ('VaultInventoryName' in _data)
	{
        this.mDialogContainer.findDialogContentContainer().find(".title-font-normal").each(
        function(_idx, _element) {
            if ($(_element).html() === "Shop") $(_element).html(_data.VaultInventoryName);
        });
	}

	if ('VaultSpaceUsed' in _data)
	{
	    this.mVaultSpaceUsed = _data.VaultSpaceUsed;
	}

	if ('VaultSpaceMax' in _data)
	{
	    this.mVaultSpaceMax = _data.VaultSpaceMax;
	}

	if ('VaultSpaceLimit' in _data)
	{
	    this.mVaultSpaceLimit = _data.VaultSpaceLimit;
	}

    if ('NextSlotCost' in _data)
    {
        this.mNextSlotCost = _data.NextSlotCost;
        this.updateMoneyCost();
    }

    this.updateVaultFreeSlotsLabel();
};

WorldTownScreenVaultDialogModule.prototype.assignItems = function (_owner, _items, _itemArray, _itemContainer)
{
    WorldTownScreenShopDialogModule.prototype.assignItems.call(this, _owner, _items, _itemArray, _itemContainer);

    if(_items.length > 0)
    {
        this.updateVaultFreeSlotsLabel();   // can probably be moved into updateShopList
    }
};

WorldTownScreenVaultDialogModule.prototype.updateAssets = function (_data)
{
    WorldTownScreenShopDialogModule.prototype.updateAssets.call(this, _data);

    this.updateMoneyCost();
}

// Overwritten Functions
WorldTownScreenVaultDialogModule.prototype.createItemSlot = function (_owner, _index, _parentDiv, _screenDiv)
{
    var self = this;

    var result = _parentDiv.createListItem(false);  // false = no price layers are added
    result.attr('id', 'slot-index_' + _index);

    // update item data
    var itemData = result.data('item') || {};
    itemData.index = _index;
    itemData.owner = _owner;
    result.data('item', itemData);

    // add event handler
    var dropHandler = function (_source, _target)
    {
        var sourceData = _source.data('item');
        var targetData = _target.data('item');

        var sourceOwner = (sourceData !== null && 'owner' in sourceData) ? sourceData.owner : null;
        var targetOwner = (targetData !== null && 'owner' in targetData) ? targetData.owner : null;

        if(sourceOwner === null || targetOwner === null)
        {
            console.error('Failed to drop item. Owner are invalid.');
            return;
        }

        var sourceItemIdx = (sourceData !== null && 'index' in sourceData) ? sourceData.index : null;
        var targetItemIdx = (targetData !== null && 'index' in targetData) ? targetData.index : null;

        if(sourceItemIdx === null)
        {
            console.error('Failed to drop item. Source idx is invalid.');
            return;
        }

        self.swapItem(sourceItemIdx, sourceOwner, targetItemIdx, targetOwner);
    };

    var dragEndHandler = function (_source, _target)
    {
        if(_source.length === 0 || _target.length === 0) return false;

        var sourceData = _source.data('item');
        var targetData = _target.data('item');

        var sourceOwner = (sourceData !== null && 'owner' in sourceData) ? sourceData.owner : null;
        var targetOwner = (targetData !== null && 'owner' in targetData) ? targetData.owner : null;
        var itemIdx = (sourceData !== null && 'index' in sourceData) ? sourceData.index : null;

        if(sourceOwner === null || targetOwner === null)
        {
            console.error('Failed to drop item. Owner is invalid.');
            return false;
        }

        return true;
    };

    result.assignListItemDragAndDrop(_screenDiv, null, dragEndHandler, dropHandler);

    result.assignListItemRightClick(function (_item, _event)
    {
        var data = _item.data('item');
        var isEmpty = (data !== null && 'isEmpty' in data) ? data.isEmpty : true;
        var owner = (data !== null && 'owner' in data) ? data.owner : null;
        var itemIdx = (data !== null && 'index' in data) ? data.index : null;

        if(isEmpty === false && owner !== null && itemIdx !== null)
        {
            // buy, sell or destroy
            var target = null;
            if (owner === WorldTownScreenVault.ItemOwner.Stash) target = WorldTownScreenVault.ItemOwner.Vault;
            if (owner === WorldTownScreenVault.ItemOwner.Vault) target = WorldTownScreenVault.ItemOwner.Stash;
            self.swapItem(itemIdx, owner, null, target);
        }
    });

    return result;
};

WorldTownScreenVaultDialogModule.prototype.swapItem = function (_sourceItemIdx, _sourceItemOwner, _targetItemIdx, _targetItemOwner)
{
    var self = this;
    this.notifyBackendSwapItem(_sourceItemIdx, _sourceItemOwner, _targetItemIdx, _targetItemOwner, function (data)
    {
        if (data === undefined || data == null || typeof (data) !== 'object')
        {
            console.error("ERROR: Failed to swap item. Reason: Invalid data result.");
            return;
        }

        // error?
        if (data.Result != 0)
        {
            // console.error("ErrorCode = " + data.Result);
            if (data.Result == ErrorCode.NotEnoughStashSpace)
            {
                self.mStashSlotSizeContainer.shakeLeftRight();
            }
            else if (data.Result == ErrorCode.NotEnoughVaultSpace)
            {
                // console.error("shakeLeftRight   mVaultSlotsizeContainer");
                self.mVaultSlotsizeContainer.shakeLeftRight();
            }
            else
            {
                console.error("Failed to swap item. Reason: Unknown");
            }

            return;
        }

        // update assets
        self.mParent.loadAssetData(data.Assets);

        if ('StashSpaceUsed' in data) self.mStashSpaceUsed = data.StashSpaceUsed;
        if ('StashSpaceMax' in data) self.mStashSpaceMax = data.StashSpaceMax;

        if ('VaultSpaceUsed' in data) self.mVaultSpaceUsed = data.VaultSpaceUsed;
        if ('VaultSpaceMax' in data) self.mVaultSpaceMax = data.VaultSpaceMax;
        self.updateVaultFreeSlotsLabel();

        if ('Stash' in data) self.updateStashList(data.Stash);
        if ('Shop' in data) self.updateShopList(data.Shop);

    });
};

WorldTownScreenVaultDialogModule.prototype.setupEventHandler = function ()
{
    var self = this;

    var dropHandler = function (ev, dd)
	{
        var drag = $(dd.drag);
        var drop = $(dd.drop);

        // do the swapping
        var sourceData = drag.data('item') || {};
        var targetData = drop.data('item') || {};

        var sourceOwner = (sourceData !== null && 'owner' in sourceData) ? sourceData.owner : null;
        var targetOwner = (targetData !== null && 'owner' in targetData) ? targetData.owner : null;

        if(sourceOwner === null || targetOwner === null)
        {
            console.error('Failed to drop item. Owner are invalid.');
            return;
        }

        var sourceItemIdx = (sourceData !== null && 'index' in sourceData) ? sourceData.index : null;
        var targetItemIdx = (targetData !== null && 'index' in targetData) ? targetData.index : null;

        if(sourceItemIdx === null)
        {
            console.error('Failed to drop item. Source idx is invalid.');
            return;
        }

        self.swapItem(sourceItemIdx, sourceOwner, targetItemIdx, targetOwner);

        // workaround if the source container was removed before we got here
        if(drag.parent().length === 0)
        {
            $(dd.proxy).remove();
        }
        else
        {
            drag.removeClass('is-dragged');
        }
    };

    // create drop handler for the stash & vault container
    $.drop({ mode: 'middle' });

    this.mStashListContainer.data('item', { owner: WorldTownScreenVault.ItemOwner.Stash });
    //this.mStashListContainer.drop('start', dropStartHandler);
    this.mStashListContainer.drop(dropHandler);
    //this.mStashListContainer.drop('end', dropEndHandler);

    this.mShopListContainer.data('item', { owner: WorldTownScreenVault.ItemOwner.Vault });
    //this.mShopListContainer.drop('start', dropStartHandler);
    this.mShopListContainer.drop(dropHandler);
    //this.mShopListContainer.drop('end', dropEndHandler);
};

// New Functions
WorldTownScreenVaultDialogModule.prototype.buyVaultSlot = function ()
{
    var self = this;
    this.notifyBackendBuySlotButtonPressed(function(data)
    {
    	// error?
    	if(data.Result != 0)
    	{
    		if(data.Result == ErrorCode.NotEnoughMoney)
    		{
    			self.mAssets.mMoneyAsset.shakeLeftRight();
    		}
    		else
    		{
    			console.error("Failed to travel. Reason: Unknown");
    		}

    		return;
    	}

    	// update assets
        if ('NextSlotCost' in data.Data)
        {
            self.mNextSlotCost = data.Data.NextSlotCost;
            self.updateMoneyCost();
        }
        if ('VaultSpaceMax' in data.Data)
        {
            self.mVaultSpaceMax = data.Data.VaultSpaceMax;
            self.updateVaultFreeSlotsLabel();
        }

    	self.mParent.loadAssetData(data.Data.Assets);
        self.updateShopList(data.Data.Shop);
    });
};

WorldTownScreenVaultDialogModule.prototype.updateMoneyCost = function()
{
    var currentMoney = this.mAssets.getValues().Money;

    this.mSlotCostLabel.html('' + Helper.numberWithCommas(this.mNextSlotCost));

    if (this.mVaultSpaceMax < this.mVaultSpaceLimit)
    {
        this.mBuyButton.enableButton(true);
    }
    else
    {
        this.mBuyButton.enableButton(false);
        this.mSlotCostLabel.html('-----');
    }

    // console.error(currentMoney + " - - - " + this.mNextSlotCost);
    if((currentMoney - this.mNextSlotCost) >= 0)
    {
        this.mSlotCostLabel.removeClass('font-color-assets-negative-value').addClass('font-color-description');
    }
    else
    {
        this.mSlotCostLabel.removeClass('font-color-description').addClass('font-color-assets-negative-value');
    }
};

WorldTownScreenVaultDialogModule.prototype.assignItemToSlot = function (_owner, _slot, _item)
{
    // In Vanilla this is not supposed to happen and it will produce errors and negative sideeffects
    // This only happens if a stash gains a new empty slot.
    // The player stash can't gain new slots. And when a shop gains new slots they are usually filled with the sold item instantly
    if (_item === null) return;
    WorldTownScreenShopDialogModule.prototype.assignItemToSlot.call(this, _owner, _slot, _item);
}

WorldTownScreenVaultDialogModule.prototype.updateSlotItem = function (_owner, _itemArray, _item, _index, _flag)
{
    WorldTownScreenShopDialogModule.prototype.updateSlotItem.call(this, _owner, _itemArray, _item, _index, _flag);
    if(_owner === WorldTownScreenShop.ItemOwner.Shop)
    {
        this.updateVaultFreeSlotsLabel();
    }
};


WorldTownScreenVaultDialogModule.prototype.updateVaultFreeSlotsLabel = function ()
{
    this.mVaultSlotsizeLabel.html('' + this.mVaultSpaceUsed + '/' + this.mVaultSpaceMax);

    if (this.mVaultSpaceUsed >= this.mVaultSpaceMax)
    {
        this.mVaultSlotsizeLabel.removeClass('font-color-value').addClass('font-color-negative-value');
    }
    else
    {
        this.mVaultSlotsizeLabel.removeClass('font-color-negative-value').addClass('font-color-value');
    }
};

WorldTownScreenVaultDialogModule.prototype.hide = function()
{
    // maybe this also needs to be done at DestroyDIV.
    // reset the global ItemOwner const
    WorldTownScreenShop.ItemOwner.Stash = WorldTownScreenVault.OldItemOwnerStash;
    WorldTownScreenShop.ItemOwner.Shop = WorldTownScreenVault.OldItemOwnerShop;
    WorldTownScreenShopDialogModule.prototype.hide.call(this);
}

WorldTownScreenVaultDialogModule.prototype.notifyBackendBuySlotButtonPressed = function (_callback)
{
    SQ.call(this.mSQHandle, 'onBuySlotButtonPressed', null, _callback);
};

// We dont use these functions and don't want them to do anything
WorldTownScreenVaultDialogModule.prototype.repairItem = function() {};
WorldTownScreenVaultDialogModule.prototype.updateItemPriceLabel = function() {};
WorldTownScreenVaultDialogModule.prototype.updateItemPriceLabels = function() {};
WorldTownScreenVaultDialogModule.prototype.hasEnoughMoneyToBuy = function() {};
WorldTownScreenVaultDialogModule.prototype.notifyBackendRepairItem = function() {};
