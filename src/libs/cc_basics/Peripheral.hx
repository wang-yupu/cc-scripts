package cc_basics;

import cc_basics.Side.getSideName;
import haxe.Rest;
import haxe.extern.EitherType;

@:native("peripheral")
private extern class CC_Peripheral {
	static function isPresent(id:String):Bool;
	static function call(id:String, method:String, args:Rest<Any>):Any;
}

class Peripheral {
	private var id:String;

	public function new(id:EitherType<cc_basics.Side.Side, String>) {
		if (Std.isOfType(id, cc_basics.Side.Side)) {
			this.id = getSideName(id);
		} else {
			this.id = id;
		}

		if (!this.isPresent()) {
			Base.print("Lib Warning [Peripheral]: The peripheral is not exists: ", this.id);
		}
	}

	public function isPresent():Bool {
		return CC_Peripheral.isPresent(this.id);
	}

	private inline function call(method:String, args:Rest<Any>):Any {
		return CC_Peripheral.call(this.id, method, ...args);
	}

	public function getID():String {
		return this.id;
	}
}
