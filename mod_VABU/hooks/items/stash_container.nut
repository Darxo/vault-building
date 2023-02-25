
// FIx of an Vanilla oversight.
// Vanilla resizes the Items array directly instead of using their custom 'function resize()' and therefor the member variable Capacity is never updated
::mods_hookNewObject("items/stash_container", function (o)
{
	local oldOnDeserialize = o.onDeserialize;
	o.onDeserialize = function(_in)
	{
		oldOnDeserialize(_in);
		this.m.Capacity = this.m.Items.len();
	}
});
