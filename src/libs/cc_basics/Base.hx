package cc_basics;

import haxe.Rest;

@:native("_G")
private extern class CC_globals {
	static function sleep(time:Float):Void;
	static function print(content:String):Void;
}

class Base {
	public static function print(args:Rest<String>) {
		var args:Array<String> = args;
		CC_globals.print(args.join(""));
	}

	public static function sleep(time:Float):Void {
		CC_globals.sleep(time);
	}
}
