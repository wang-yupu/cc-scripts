package sgui.widgets;

import cc_basics.Enums.Color;
import cc_basics.Logger;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

typedef SwitchHandler = Bool->Void;

class Switch extends Widget {
	public var onLabel:String = "ON";
	public var offLabel:String = "OFF";
	public var onColor:Color = Color.LIME;
	public var offColor:Color = Color.RED;
	public var border:Color = Color.WHITE;
	public var textColor:Color = Color.BLACK;
	public var onToggle:SwitchHandler;

	public var value(get, set):Bool;

	private var current:Bool;

	public function new(value:Bool = false, width:Null<Int> = null, height:Null<Int> = 1) {
		super(width, height);
		if (this.width != null && this.width < 4) {
			this.width = 4;
		}
		if (this.height != null && this.height < 1) {
			this.height = 1;
		}
		current = value;
	}

	function get_value():Bool {
		return current;
	}

	function set_value(v:Bool):Bool {
		if (current != v) {
			current = v;
			requestRender();
		}
		return current;
	}

	override public function render(buffer:FrameBuffer):Void {
		var gx = getGlobalX();
		var gy = getGlobalY();
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		var bg = current ? onColor : offColor;
		buffer.fillRect(gx, gy, actualWidth, actualHeight, " ", textColor, bg);
		var label = current ? onLabel : offLabel;
		if (label.length > actualWidth - 2) {
			label = label.substr(0, actualWidth - 2);
		}
		var offsetX = gx + Std.int((actualWidth - label.length) / 2);
		var offsetY = gy + Std.int(actualHeight / 2);
		buffer.writeText(offsetX, offsetY, label, textColor, bg);
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (!enabled) {
			return false;
		}
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		if (localX < 0 || localX >= actualWidth || localY < 0 || localY >= actualHeight) {
			return false;
		}
		value = !current;
		Logger.debug("[Switch] toggled to ", value);
		if (onToggle != null) {
			onToggle(current);
		}
		return true;
	}
}
