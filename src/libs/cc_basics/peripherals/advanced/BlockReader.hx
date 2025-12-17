package cc_basics.peripherals.advanced;

import haxe.extern.EitherType;
import cc_basics.Enums.Side;

class BlockReader extends Peripheral {
	public function new(id:EitherType<String, Side>) {
		super(id);
	}

	public function getBlockData():Dynamic {
		return this.call("getBlockData");
	}

	public function getBlockID():String {
		return this.call("getBlockName");
	}
}
