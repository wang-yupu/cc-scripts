package lava_auto_crafting;

import cc_basics.peripherals.GenericInventory;
import cc_basics.Base;
import cc_basics.peripherals.GenericFluid;

class Main {
	public static function main() {
		Base.print("Starting...");
		var lavaSource = new GenericFluidStorage("create:fluid_tank_0");
		var lavaPutInto = new GenericFluidStorage("ae2:interface_0");
		var itemPutInto = new GenericInventory("ae2:interface_0");
		var checkingContainer = new GenericInventory("minecraft:barrel_0");
		var lavaPerEveryItem = 92000;
		var loop = 0;

		var hasItem = false, lt;
		while (true) {
			checkingContainer.sync();
			for (i in checkingContainer) {
				if (i.getItem(false).name != null) {
					hasItem = true;
				}
			}

			if (hasItem) {
				Base.print("Founded item. Moving lava.");
				lavaSource.trigSync(true);
				lt = lavaSource.getTank(0);
				if (lt != null) {
					while (!(lt.getCount() > lavaPerEveryItem + 10000)) {}
					if (lt.getCount() > lavaPerEveryItem + 10000) {
						// 搬运岩浆
						// lt.pushToFluidStorage(lavaPutInto, lavaPerEveryItem);
						lavaPutInto.pullFluid(lavaSource.getID(), lavaPerEveryItem / 2);
						lavaPutInto.pullFluid(lavaSource.getID(), lavaPerEveryItem / 2);
						// 移除物品
						checkingContainer.sync();
						for (i in checkingContainer) {
							if (i.getItem(false).name != null) {
								i.pushToInventory(itemPutInto, 1);
								break;
							}
						}
						Base.print("Success to move lava into target. ", loop);
						loop++;
					}
				}
			}
			hasItem = false;
			Base.sleep0();
			checkingContainer.sync();
		}
	}
}
