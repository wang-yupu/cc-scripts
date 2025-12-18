package utils;

import cc_basics.Base;

class FakeRandom {
	// LCG impl
	private static var initalized:Bool = false;
	private static var seed:Int = 114514;

	private static final a:Int = 1103515245;
	private static final c:Int = 12345;
	private static final m:Int = Math.floor(Math.pow(2, 31));

	public static function next():Float {
		if (!initalized) {
			seed = Math.floor(Base.epoch("utc") * Base.time("ingame") / Base.epoch("local"));
			initalized = true;
		}
		seed = (a * seed + c) % m;
		return seed / m;
	}

	public static function get(a:Int, b:Int):Int {
		return Math.floor(next() * (b - a)) + a;
	}
}
