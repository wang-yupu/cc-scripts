package export_keys;

import cc_basics.Base;

@:native("keys")
extern class CC_keys_api {
	static function getName(v:Int):String;
}

@:native("io")
extern class CC_io {
	static function open(file:String, mode:String):Dynamic;
	static function close(file:Dynamic):Void;
}

class Main {
	static function main() {
		Base.print("Starting...");
		var file = CC_io.open("result", "w+");
		var a;
		for (i in 0...256) {
			// a = CC_keys_api.getName(i);
			a = String.fromCharCode(i);
			if (a != null) {
				Base.print(i, " - ", a);
				file.write(a + "\n");
			}
		}
	}
}
