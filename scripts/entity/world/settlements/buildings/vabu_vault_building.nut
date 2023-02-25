this.vabu_vault_building <- this.inherit("scripts/entity/world/settlements/buildings/building", {
	//modified marketplace.
	m = {
		Stash = null,
		VaultSpaceLimit = 0
	},

	function getStash()
	{
		return this.m.Stash;
	}

	function create()
	{
		this.building.create();
		this.m.ID = "building.vault";
		this.m.Name = "City Vault";
		this.m.Description = "A secure building that you can use to store items indefinitely.";
		this.m.UIImage = "ui/settlements/vabu_warehouse_01";
		this.m.UIImageNight = "ui/settlements/vabu_warehouse_01_night";
		this.m.Tooltip = "world-town-screen.main-dialog-module.Vault";
		this.m.TooltipIcon = "ui/icons/buildings/fletcher.png";
		this.m.Stash = this.new("scripts/items/stash_container");
		this.m.Stash.setID("vault");
		this.m.Stash.setResizable(false);
		this.m.IsClosedAtNight = true;
		this.m.Sounds = [
			{
				File = "ambience/buildings/kennel_cage_00.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/kennel_cage_01.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/kennel_cage_02.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/docks_working_00.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/docks_working_01.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/docks_working_02.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/docks_working_03.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/docks_working_04.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/alchemist_creaking_door_01.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/market_bottles_00.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_crafting_01.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_crafting_02.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_crafting_03.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_crafting_04.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_crafting_05.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_hammering_01.wav",
				Volume = 1.0,
				Pitch = 1.0
			},
			{
				File = "ambience/buildings/taxidermist_hammering_02.wav",
				Volume = 1.0,
				Pitch = 1.0
			}
		];
		this.m.SoundsAtNight = [];

        this.m.Stash.resize(::modVABU.Config.UnlockedSlots);
		this.m.VaultSpaceLimit = ::modVABU.Config.VaultSpaceLimit;
	}

	function isClosed()
	{
		if (this.isClosedFromSituations()) return true;

		if (this.isUnlocked() == false) return true;

		return false;
	}

	function isUnlocked()
	{
		if (::modVABU.Config.IsUnlockedFromNoblesAware && !::World.Ambitions.getAmbition("ambition.make_nobles_aware").isDone()) return false;

		return true;
	}

	function isClosedFromSituations()
	{
		if (::modVABU.Config.ClosedFromSituations)
		{
			if (this.getSettlement().hasSituation("situation.warehouse_burned_down")) return true;
			if (this.getSettlement().hasSituation("situation.razed")) return true;
		}
		return false;
	}

	function onClicked( _townScreen )
	{
		if (this.isClosed()) return;
		_townScreen.getVaultDialogModule().setShop(this);
		_townScreen.showVaultDialog();
		this.pushUIMenuStack();
	}

	function onSerialize( _out )
	{
		this.building.onSerialize(_out);
		this.m.Stash.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		this.building.onDeserialize(_in);
		this.m.Stash.onDeserialize(_in);
	}

});

