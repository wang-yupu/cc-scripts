package cc_basics;

import haxe.Rest;

@:native("_G")
private extern class CC_globals {
	static function sleep(time:Float):Void;
	static function print(content:String):Void;
}

@:native("os")
private extern class CC_os {
	static function clock():Float;
	static function time(typ:String = "ingame"):Float;
	static function pullEvent(eventFilter:String = null):Dynamic;
	static function queueEvent(name:String, ...args:Dynamic):Void;
}

class Base {
	public static function print(args:Rest<Any>) {
		var str = new StringBuf();
		for (arg in args) {
			str.add(Std.string(arg));
		}
		CC_globals.print(str.toString());
	}

	public static function sleep(time:Float):Void {
		CC_globals.sleep(time);
	}

	public inline static function sleep0() {
		CC_globals.sleep(0);
	}

	public static function clock():Float {
		return CC_os.clock();
	}

	public static function time(typ:String = "ingame"):Float {
		return CC_os.time(typ);
	}

	public inline static function pullEvent(eventFilter:String = null) {
		return CC_os.pullEvent(eventFilter);
	}

	public inline static function queueEvent(name:String, ...args:Dynamic) {
		CC_os.queueEvent(name, ...args);
	}
}
