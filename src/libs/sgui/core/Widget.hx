package sgui.core;

import cc_basics.Logger;
import sgui.events.Events.KeyEvent;
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
	public var width(default, set):Null<Int> = null;
	public var height(default, set):Null<Int> = null;
	public var parent(default, null):Container;

	private var dirtyLayout:Bool = true;
	private var dirtyRender:Bool = true;

	public function new(width:Null<Int> = null, height:Null<Int> = 1) {
		this.width = width;
		this.height = height;
	}

	inline public function getGlobalX():Int {
		return (parent != null ? parent.getGlobalX() : 0) + x;
	}

	inline public function getGlobalY():Int {
		return (parent != null ? parent.getGlobalY() : 0) + y;
	}

	public function getActualWidth():Int {
		return width != null ? width : (parent != null ? parent.getActualWidth() : 0);
	}

	public function getActualHeight():Int {
		return height != null ? height : 1;
	}

	public inline function getBounds():Bounds {
		return {
			x: x,
			y: y,
			width: getActualWidth(),
			height: getActualHeight()
		};
	}

	public inline function getGlobalBounds():Bounds {
		return {
			x: getGlobalX(),
			y: getGlobalY(),
			width: getActualWidth(),
			height: getActualHeight()
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

	public function handleKeyInput(keyCode:KeyEvent):Bool {
		return false;
	}

	public function handleCharInput(ch:String):Bool {
		return false;
	}

	public function handlePaste(content:String):Bool {
		return false;
	}

	public function onFocus():Void {}

	public function onBlur():Void {}

	public function isFocusable():Bool {
		return false;
	}

	public function hitTest(globalX:Int, globalY:Int):Bool {
		var bounds = getGlobalBounds();
		var result = globalX >= bounds.x && globalX < bounds.x + bounds.width && globalY >= bounds.y && globalY < bounds.y + bounds.height;
		Logger.debug('[SGUI] hitTest: gx=$globalX, gy=$globalY, bounds=$bounds, result=$result');
		return result;
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

	function set_width(value:Null<Int>):Null<Int> {
		var newValue = value == null ? null : Math.floor(Math.max(0, value));
		if (newValue != width) {
			width = newValue;
			requestLayout();
		}
		return newValue;
	}

	function set_height(value:Null<Int>):Null<Int> {
		var newValue = value == null ? null : Math.floor(Math.max(1, value));
		if (newValue != height) {
			height = newValue;
			requestLayout();
		}
		return newValue;
	}

	public function dispose():Void {}
}
