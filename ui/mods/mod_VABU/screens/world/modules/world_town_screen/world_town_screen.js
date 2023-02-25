

var VABU_onDisconnection = WorldTownScreen.prototype.onDisconnection;
WorldTownScreen.prototype.onDisconnection = function ()
{
    this.mVaultDialogModule.onDisconnection();
    VABU_onDisconnection.call(this);
};

var VABU_onModuleOnConnectionCalled = WorldTownScreen.prototype.onModuleOnConnectionCalled;
WorldTownScreen.prototype.onModuleOnConnectionCalled = function (_module)
{
    if (this.mVaultDialogModule !== null && this.mVaultDialogModule.isConnected())
    {
        VABU_onModuleOnConnectionCalled.call(this, _module);
    }
};

var VABU_onModuleOnDisconnectionCalled = WorldTownScreen.prototype.onModuleOnDisconnectionCalled;
WorldTownScreen.prototype.onModuleOnDisconnectionCalled = function (_module)
{
    if (this.mVaultDialogModule === null && !this.mVaultDialogModule.isConnected())
    {
        VABU_onModuleOnDisconnectionCalled.call(this, _module)
    }
};

var VABU_registerModules = WorldTownScreen.prototype.registerModules;
WorldTownScreen.prototype.registerModules = function ()
{
    // We have to do this here because createModules and the constructor can't be hooked into with modding script hooks
    this.mVaultDialogModule = new WorldTownScreenVaultDialogModule(this);

    this.mVaultDialogModule.register(this.mContainer);
    VABU_registerModules.call(this);
};

var VABU_unregisterModules = WorldTownScreen.prototype.unregisterModules;
WorldTownScreen.prototype.unregisterModules = function ()
{
    VABU_unregisterModules.call(this);
    this.mVaultDialogModule.unregister();
};

WorldTownScreen.prototype.showVaultDialog = function ( _data)
{
    WorldTownScreenShop.ItemOwner.Stash = WorldTownScreenVault.ItemOwner.Stash;
    WorldTownScreenShop.ItemOwner.Shop = WorldTownScreenVault.ItemOwner.Vault;

	var _withSlideAnimation = true;

	this.mContainer.addClass('display-block').removeClass('display-none');

	if (this.mActiveModule != null)
		this.mActiveModule.hide(_withSlideAnimation);
	else
		this.mMainDialogModule.hide();

	this.mActiveModule = this.mVaultDialogModule;

	if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
		this.loadAssetData(_data.Assets);
		this.mVaultDialogModule.loadFromData(_data);
    }

    this.mVaultDialogModule.show(_withSlideAnimation, _data);
};

var VABU_getModule = WorldTownScreen.prototype.getModule;
WorldTownScreen.prototype.getModule = function (_name)
{
    if (_name == 'VaultDialogModule') return this.mVaultDialogModule;
    return VABU_getModule.call(this, _name);
};

var VABU_getModules = WorldTownScreen.prototype.getModules;
WorldTownScreen.prototype.getModules = function ()
{
    var ret = VABU_getModules(this);
    ret.push({ name: 'VaultDialogModule', module: this.mVaultDialogModule });
    return ret;
};
