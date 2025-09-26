package example;

import cc_basics.peripherals.Redstone.RedstonePin;
import cc_basics.Enums;
import cc_basics.Base;
import cc_basics.peripherals.GenericInventory;

class Main {
	static function main() {
		Base.print("hello1");
		var gi = new GenericInventory(Side.TOP);
		var go = new GenericInventory(Side.RIGHT);
		var si = new RedstonePin(Side.FRONT);
		gi.sync();
		gi.printItemList();
		Base.print("done. waiting for signal");
		while (!si.read()) {}
		Base.print("moving");
		var result;
		for (slot in gi) {
			result = slot.pushToInventory(go);
			Base.print("Moving ", slot.getSlot(), ":", result);
		}
	}
}
