package arcade_mp_fight_1;

import cc_basics.peripherals.Redstone.RedstonePin;
import cc_basics.peripherals.GenericInventory;

enum CoinStatus {
	NotEnough(i:Int);
	OK;
}

class CoinManager {
	public var coinRequired:Int = 4;
	public var coin:String = "minecraft:diamond_block";
	public var cheating:RedstonePin = null;

	private var checkInventory:GenericInventory;
	private var putInventory:GenericInventory;

	public function new(check:GenericInventory, put:GenericInventory) {
		this.checkInventory = check;
		this.putInventory = put;
	}

	public function take():CoinStatus {
		if (cheating != null) {
			if (cheating.read()) {
				return OK;
			}
		}
		this.checkInventory.sync();
		var foundedCount:Int = 0;
		for (item in this.checkInventory) {
			if (item.getItem().name == this.coin) {
				foundedCount += item.getItem().count;
				if (item.getItem().count >= this.coinRequired) {
					// take
					switch (item.pushToInventory(this.putInventory, this.coinRequired)) {
						case Success(count):
							if (count >= this.coinRequired) {
								return OK;
							}
						case Failed:
							foundedCount -= item.getItem().count;
					}
				}
			}
		}
		return NotEnough(this.coinRequired - foundedCount);
	}
}
