::Hooks.registerJS("ui/mods/mod_VABU/enums.js");

foreach(file in ::IO.enumerateFiles("ui/mods/mod_VABU/js_hooks"))
{
	::Hooks.registerJS(file + ".js");
}

// New Screens
::Hooks.registerJS("ui/mods/mod_VABU/screens/world/modules/world_town_screen/world_town_screen_vault_dialog_module.js");
::Hooks.registerCSS("ui/mods/mod_VABU/screens/world/modules/world_town_screen/world_town_screen_vault_dialog_module.css");
