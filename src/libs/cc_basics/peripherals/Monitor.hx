package cc_basics.peripherals;

import cc_basics.Enums;
import haxe.extern.EitherType;

enum MonitorTarget {
	local;
	remote(p:EitherType<Side, String>);
}

@:native("term")
private extern class CC_term {
	static function setTextScale(scale:Float):Void;
	static function getTextScale():Float;
	static function getSize():Dynamic;
	static function isColor():Bool;
	static function setTextColor(color:Int):Void;
	static function setBackgroundColor(color:Int):Void;
	static function getBackgroundColor():Int;
	static function write(content:String):Void;
	static function blit(content:String, fg:String, bg:String):Void;
	static function clear():Void;
	static function setCursorBlink(blinking:Bool):Void;
	static function setCursorPos(x:Int, y:Int):Void;
	static function getCursorPos():Dynamic;
}

class Monitor extends Peripheral {
	private var isRemote:Bool = false;

	public function new(target:MonitorTarget = MonitorTarget.local) {
		switch (target) {
			case local:
				super(null);
			case remote(p):
				this.isRemote = true;
				super(p);
		}
		if (!this.callable()) {
			Logger.warning("[Lib warning] The monitor is not exists");
		}
		//
		this.setScale(1.0);
		this.setCursorBlink(false);
		this.setCursorPosition(0, 0);
		this.clear(Color.BLACK);
	}

	public function isLocal() {
		return !this.isRemote;
	}

	public function callable():Bool {
		if (this.isRemote) {
			return this.isPresent();
		}
		return true;
	}

	public function setScale(scale:Float) {
		/* 
		 * 注意: 调用此功能将清除屏幕！
		 * 在local显示器调用无效果(不报错)
		 */
		scale = Math.max(Math.min(scale, 5), 0.5);
		if (this.isRemote) {
			this.call("setTextScale", scale);
			return;
		}
	}

	public function getScale():Float {
		if (this.isRemote) {
			return this.call("getTextScale");
		} else {
			return 1.0;
		}
	}

	public function getSize():Array<Int> {
		if (this.isRemote) {
			return this.call("getSize");
		} else {
			var r = untyped __lua__("{ {0} }", CC_term.getSize());
			var v = [];
			for (key in Reflect.fields(r)) {
				v.push(Reflect.field(r, key));
			}

			return v;
		}
	}

	public function isColor():Bool {
		if (this.isRemote) {
			return this.call("isColor");
		}
		return CC_term.isColor();
	}

	public function setForeground(color:Color):Void {
		var c = asCCColor(color);
		if (this.isRemote) {
			this.call("setTextColor", c);
			return;
		}
		CC_term.setTextColor(c);
	}

	public function setTextColor(color:Color):Void {
		this.setForeground(color);
	}

	public function setBackground(color:Color):Void {
		var c = asCCColor(color);
		if (this.isRemote) {
			this.call("setBackgroundColor", c);
			return;
		}
		CC_term.setBackgroundColor(c);
	}

	public function setBackgroundColor(color:Color):Void {
		this.setBackground(color);
	}

	public function clear(fillWith:Color = null):Void {
		var setBackgroundBackToColor:Int = 0;
		if (fillWith != null) {
			if (this.isRemote) {
				setBackgroundBackToColor = this.call("getBackgroundColor");
			} else {
				setBackgroundBackToColor = CC_term.getBackgroundColor();
			}
			this.setBackground(fillWith);
		}

		if (this.isRemote) {
			this.call("clear");
		} else {
			CC_term.clear();
		}

		if (fillWith != null) {
			this.setBackgroundColor(parseCCColor(setBackgroundBackToColor));
		}
	}

	public function write(v:String, nl:Bool = false):Void {
		if (this.isRemote) {
			this.call("write", v);
			return;
		}
		CC_term.write(v);
	}

	public function blit(v:String, fg:String, bg:String):Void {
		if (this.isRemote) {
			this.call("blit", v, fg, bg);
			return;
		}
		CC_term.blit(v, fg, bg);
	}

	public function setCursorPosition(x:Int, y:Int):Void {
		if (this.isRemote) {
			this.call("setCursorPos", x + 1, y + 1);
			return;
		}
		CC_term.setCursorPos(x + 1, y + 1);
	}

	public function getCursorPosition():Array<Int> {
		if (this.isRemote) {
			return this.call("getCursorPos");
		} else {
			var r = untyped __lua__("{ {0} }", CC_term.getCursorPos());
			var v = [];
			for (key in Reflect.fields(r)) {
				v.push(Math.floor(Reflect.field(r, key) - 1));
			}

			return v;
		}
	}

	public function setCursorBlink(blinking:Bool):Void {
		if (this.isRemote) {
			this.call("setCursorBlink", blinking);
			return;
		}
		CC_term.setCursorBlink(blinking);
	}
}
