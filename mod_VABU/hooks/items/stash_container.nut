
// FIx of an Vanilla oversight.
// Vanilla resizes the Items array directly instead of using their custom 'function resize()' and therefor the member variable Capacity is never updated
::modVABU.HooksMod.hook("scripts/items/stash_container", function(q) {
	q.onDeserialize = @(__original)function(_in)
	{
		__original(_in);
		this.m.Capacity = this.m.Items.len();
	}
});
