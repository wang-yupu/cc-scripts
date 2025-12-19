package cc_basics;

import cc_basics.Enums;
import haxe.Rest;
import haxe.extern.EitherType;

@:native("peripheral")
private extern class CC_Peripheral {
	static function isPresent(id:String):Bool;
	static function call(id:String, method:String, args:Rest<Any>):Any;
	static function getType(id:String):String;
}

class Peripheral {
	private var id:String;

	public function new(id:EitherType<Side, String>) {
		if (Std.isOfType(id, Side)) {
			this.id = getSideName(id);
		} else {
			this.id = id;
		}

		if (this.id != null) {
			if (!this.isPresent()) {
				Logger.warning("[Lib warning] The peripheral is not exists: ", this.id);
			}
		}
	}

	public function isPresent():Bool {
		return CC_Peripheral.isPresent(this.id);
	}

	public function getType():String {
		return CC_Peripheral.getType(this.id);
	}

	private inline function call(method:String, args:Rest<Any>):Any {
		var r = untyped __lua__("{ {0} }", CC_Peripheral.call(this.id, method, ...args));
		var v = [];
		for (key in Reflect.fields(r)) {
			v.push(Reflect.field(r, key));
		}

		if (v.length == 0) {
			return null;
		} else if (v.length == 1) {
			return v[0];
		} else {
			return v;
		}
	}

	private inline function fcall(method:String, args:Rest<Any>):Any {
		return CC_Peripheral.call(this.id, method, ...args);
	}

	public function getID():String {
		return this.id;
	}
}
