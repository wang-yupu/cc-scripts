package cc_basics;

import cc_basics.Side.getSideName;

@:native("redstone")
private extern class CC_redstone {
	static function setOutput(side:String, state:Bool):Void;
	static function getOutput(side:String):Bool;
}

class Redstone {
	public static function setOutput(side:Side, state:Bool):Void {
		CC_redstone.setOutput(getSideName(side), state);
		return;
	}

	public static function pulse(side:Side, time:Float = 0.1, reverse:Bool = false):Void {
		if (CC_redstone.getOutput(getSideName(side)) && !reverse) {
			return;
		}
		CC_redstone.setOutput(getSideName(side), !reverse);
		Base.sleep(time);
		CC_redstone.setOutput(getSideName(side), reverse);
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
