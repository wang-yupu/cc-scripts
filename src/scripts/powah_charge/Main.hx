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
		// 结束

		spk.playNote(Instrument.pling, Note.Fs5, 2.0);
		var orbSlotNow = 1, r0, founded = false;
		while (true) {
			read.sync();
			for (slot in read) {
				if (!slot.isEmpty()) {
					founded = true;
					for (recipe in recipes) {
						if (recipe.inputs[0] == slot.getItem(false).name) {
							Base.print("Crafting: ", recipe.output);
							spk.playNote(Instrument.bell, Note.Ds4, 2.0);
							orb.sync();
							for (ingredient in recipe.inputs) {
								for (rslot in read) {
									if (rslot.isEmpty()) {
										continue;
									}
									if (rslot.getItem(false).name == ingredient) {
										r0 = rslot.pushTo(orb.slotAt(orbSlotNow), 1);
										orbSlotNow++;
									}
								}
							}
							Base.print("Ingredient pushed, awaiting. max slot: #", orbSlotNow);
							while (true) {
								orb.sync();
								if (orb.slotAt(0).getItem(false).name == recipe.output) {
									break;
								}
							}
							Base.print("Craft done. Outputing...");
							orb.slotAt(0).pushToInventory(write);
							Base.print("Done.");
							spk.playNote(Instrument.bell, Note.F5, 2.0);
						}
					}
				}
			}
			orbSlotNow = 1;
			Base.sleep0();
			if (!founded) {
				Base.sleep(2);
			}
			founded = false;
		}
	}
}
