package powah_charge;

import haxe.extern.EitherType;
import cc_basics.Side;
import cc_basics.peripherals.Speaker;
import cc_basics.peripherals.GenericInventory;
import cc_basics.Base;

typedef Recipe = {
	var output:String; // 合成的产物
	var inputs:Array<String>; // 需要的原料
}

class Main {
	// =========================================================
	// Craft one recipe
	// =========================================================
	static function craftRecipe(recipe:Recipe, read:GenericInventory, orb:GenericInventory, write:GenericInventory, spk:Speaker) {
		var orbSlotNow = 1;

		Base.print("Crafting: ", recipe.output);
		spk.playNote(Instrument.bell, Note.Ds4, 2.0);

		// ---------- collect requirements ----------
		var need = new Map<String, Int>();
		for (ingredient in recipe.inputs) {
			if (!need.exists(ingredient))
				need.set(ingredient, 0);
			need.set(ingredient, need.get(ingredient) + 1);
		}

		// ---------- push ingredients ----------
		for (ingredient => count in need) {
			var remaining = count;
			for (rslot in read) {
				if (remaining <= 0)
					break;
				if (!rslot.isEmpty() && rslot.getItem(false).name == ingredient) {
					var moved = rslot.pushTo(orb.slotAt(orbSlotNow), 1);
					if (moved.getParameters()[0] > 0) {
						orbSlotNow++;
						remaining--;
					}
				}
			}
			if (remaining > 0) {
				Base.print("Missing ingredient: ", ingredient, " need ", remaining, " more");
				return false;
			}
		}

		Base.print("Ingredients pushed, waiting for crafting...");

		// ---------- wait for result ----------
		var timeout = 200; // max ticks
		while (timeout > 0) {
			orb.sync();
			var result = orb.slotAt(0).getItem(false);
			if (!orb.slotAt(0).isEmpty() && result.name == recipe.output) {
				break;
			}
			Base.sleep0();
			timeout--;
		}
		if (timeout <= 0) {
			Base.print("Craft timeout: ", recipe.output);
			return false;
		}

		// ---------- output result ----------
		Base.print("Craft complete, moving to output...");
		orb.slotAt(0).pushToInventory(write);
		spk.playNote(Instrument.bell, Note.F5, 2.0);
		Base.print("Done: ", recipe.output);

		return true;
	}

	// =========================================================
	// Main program
	// =========================================================
	public inline static function main() {
		Base.print("Powah Charge Orb autocrafting Script");
		var orb = new GenericInventory("powah:energizing_orb_0");
		var read = new GenericInventory("sophisticatedbackpacks:backpack_0");
		var write = new GenericInventory("ae2:pattern_provider_1");
		var spk = new Speaker(Side.BACK);

		// 合成表
		var recipes:Array<Recipe> = [
			{output: "powah:steel_energized", inputs: ["minecraft:iron_ingot", "minecraft:gold_ingot"]},
			{output: "powah:crystal_blazing", inputs: ["minecraft:blaze_rod"]},
			{output: "powah:crystal_niotic", inputs: ["minecraft:diamond"]},
			{output: "powah:crystal_spirited", inputs: ["minecraft:emerald"]},
			{
				output: "powah:crystal_nitro",
				inputs: [
					"minecraft:nether_star",
					"minecraft:redstone_block",
					"minecraft:redstone_block",
					"powah:blazing_crystal_block"
				]
			},
		];

		spk.playNote(Instrument.pling, Note.Fs5, 2.0);

		// main loop
		while (true) {
			read.sync();
			var crafted = false;

			for (slot in read) {
				if (!slot.isEmpty()) {
					var itemName = slot.getItem(false).name;
					for (recipe in recipes) {
						if (recipe.inputs[0] == itemName) {
							var success = craftRecipe(recipe, read, orb, write, spk);
							if (success)
								crafted = true;
						}
					}
				}
			}

			if (!crafted) {
				Base.sleep(2); // no craft, idle
			} else {
				Base.sleep0(); // crafted something, short delay
			}
		}
	}
}
