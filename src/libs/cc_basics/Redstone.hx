package cc_basics;

import cc_basics.Side.getSideName;

@:native("redstone")
private extern class CC_redstone {
	static function setOutput(side:String, state:Bool):Void;
	static function getOutput(side:String):Bool;
}

class RedstonePin {
	private var side:Side;

	public function new(side:Side, state:Bool = false) {
		this.side = side;
		this.set(state);
	}

	public function set(state:Bool) {
		CC_redstone.setOutput(getSideName(side), state);
	}

	public function pulse(time:Float = 0.1, reverse:Bool = false, waitAfterPulse:Bool = true):Void {
		var side:String = getSideName(this.side);
		if (CC_redstone.getOutput(side) && !reverse) {
			return;
		}
		CC_redstone.setOutput(side, !reverse);
		Base.sleep(time);
		CC_redstone.setOutput(side, reverse);
		if (waitAfterPulse) {
			Base.sleep(time);
		}
	}
}

class Redstone {
	private static function setOutput(side:Side, state:Bool):Void {
		CC_redstone.setOutput(getSideName(side), state);
		return;
	}

	public static function setAll(state:Bool = false) {
		setOutput(Side.TOP, state);
		setOutput(Side.BOTTOM, state);
		setOutput(Side.LEFT, state);
		setOutput(Side.RIGHT, state);
		setOutput(Side.FRONT, state);
		setOutput(Side.BACK, state);
	}
}
