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
	static function pullEvent(eventFilter:String = null):Array<Dynamic>;
	static function queueEvent(name:String, ...args:Dynamic):Void;
	static function date(fmt:String, time:Int):String;
}

class Base {
	public static function print(args:Rest<Any>) {
		var str = new StringBuf();
		for (arg in args) {
			str.add(Std.string(arg));
		}
		CC_globals.print(str.toString());
	}

	public static inline function fprint(a:String) {
		CC_globals.print(a);
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

	public inline static function pullEvent(?eventFilter:String):Array<Dynamic> {
		var r = untyped __lua__("{ {0} }", CC_os.pullEvent(eventFilter));
		var v = [];
		for (key in Reflect.fields(r)) {
			v.push(Reflect.field(r, key));
		}
		return v;
	}

	public inline static function queueEvent(name:String, ...args:Dynamic):Void {
		CC_os.queueEvent(name, ...args);
	}

	public static function toReadableTime(time:Int):String {
		return CC_os.date("%Y/%m/%d %H:%M:%S", time);
	}
}
