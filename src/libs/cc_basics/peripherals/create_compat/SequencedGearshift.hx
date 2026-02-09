package cc_basics.peripherals.create_compat;

import cc_basics.Base;
import cc_basics.Peripheral;

class SequencedGearshift extends Peripheral {
	public function rotate(degs:Int, doubleSpeed:Bool = false, reverse:Bool = false):Void {
		if (degs == 0) {
			return;
		}
		if (degs < 0) {
			reverse = !reverse;
			degs = 0 - degs;
		}

		this.call("rotate", degs, (reverse ? -1 : 1) * (doubleSpeed ? 2 : 1));
	}

	public function move(distance:Int, doubleSpeed:Bool = false, reverse:Bool = false):Void {
		if (distance == 0) {
			return;
		}
		if (distance < 0) {
			reverse = !reverse;
			distance = 0 - distance;
		}

		this.call("rotate", distance, (reverse ? -1 : 1) * (doubleSpeed ? 2 : 1));
	}

	public function isRunning():Bool {
		return this.call("isRunning");
	}

	public function wait():Void {
		while (this.isRunning()) {
			Base.sleep0();
		}
	}
}
