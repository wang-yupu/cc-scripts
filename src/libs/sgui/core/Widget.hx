package sgui.core;

import sgui.core.FrameBuffer;

typedef Bounds = {
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
};

class Widget {
	public var name:String;
	public var visible:Bool = true;
	public var enabled:Bool = true;
	public var x(default, set):Int = 0;
	public var y(default, set):Int = 0;
	public var width(default, set):Int = 0;
	public var height(default, set):Int = 0;
	public var parent(default, null):Container;

	private var dirtyLayout:Bool = true;
	private var dirtyRender:Bool = true;

	public function new(width:Int = 0, height:Int = 0) {
		this.width = width;
		this.height = height;
	}

	inline public function getGlobalX():Int {
		return (parent != null ? parent.getGlobalX() : 0) + x;
	}

	inline public function getGlobalY():Int {
		return (parent != null ? parent.getGlobalY() : 0) + y;
	}

	public inline function getBounds():Bounds {
		return {
			x: x,
			y: y,
			width: width,
			height: height
		};
	}

	public inline function getGlobalBounds():Bounds {
		return {
			x: getGlobalX(),
			y: getGlobalY(),
			width: width,
			height: height
		};
	}

	public inline function toLocal(globalX:Int, globalY:Int):{x:Int, y:Int} {
		return {x: globalX - getGlobalX(), y: globalY - getGlobalY()};
	}

	public function layout():Void {}

	public function render(buffer:FrameBuffer):Void {}

	public function handleRelease(localX:Int, localY:Int):Bool {
		return false;
	}

	public function handleDrag(localX:Int, localY:Int, deltaX:Int, deltaY:Int):Bool {
		return false;
	}

	public function handleScroll(direction:Int, localX:Int, localY:Int):Bool {
		return false;
	}

	public function handleKeyInput(keyCode:Int):Bool {
		return false;
	}

	public function handleCharInput(ch:String):Bool {
		return false;
	}

	public function onFocus():Void {}

	public function onBlur():Void {}

	public function isFocusable():Bool {
		return false;
	}

	public function hitTest(globalX:Int, globalY:Int):Bool {
		var bounds = getGlobalBounds();
		return globalX >= bounds.x && globalX < bounds.x + bounds.width && globalY >= bounds.y && globalY < bounds.y + bounds.height;
	}

	public function requestLayout():Void {
		dirtyLayout = true;
		if (parent != null) {
			parent.requestLayout();
		}
	}

	public function needsLayout():Bool {
		return dirtyLayout;
	}

	public function markLaidOut():Void {
		dirtyLayout = false;
	}

	public function requestRender():Void {
		dirtyRender = true;
		if (parent != null) {
			parent.requestRender();
		}
	}

	public function needsRender():Bool {
		return dirtyRender;
	}

	public function markRendered():Void {
		dirtyRender = false;
	}

	function set_x(value:Int):Int {
		if (value != x) {
			x = value;
			requestLayout();
		}
		return value;
	}

	function set_y(value:Int):Int {
		if (value != y) {
			y = value;
			requestLayout();
		}
		return value;
	}

	function set_width(value:Int):Int {
		var newValue = Math.floor(Math.max(0, value));
		if (newValue != width) {
			width = newValue;
			requestLayout();
		}
		return newValue;
	}

	function set_height(value:Int):Int {
		var newValue = Math.floor(Math.max(0, value));
		if (newValue != height) {
			height = newValue;
			requestLayout();
		}
		return newValue;
	}

	public function dispose():Void {}
}
