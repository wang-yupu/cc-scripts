package sgui.widgets;

import cc_basics.Enums.Color;
import cc_basics.Logger;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

typedef SwitchHandler = Bool -> Void;

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

	public function new(value:Bool = false, width:Int = 6, height:Int = 3) {
		super(width, height);
		if (this.width < 4) {
			this.width = 4;
		}
		if (this.height < 3) {
			this.height = 3;
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
		var bg = current ? onColor : offColor;
		buffer.fillRect(gx, gy, width, height, " ", textColor, bg);
		for (x in 0...width) {
			buffer.setCell(gx + x, gy, "-", border, bg);
			buffer.setCell(gx + x, gy + height - 1, "-", border, bg);
		}
		for (y in 0...height) {
			buffer.setCell(gx, gy + y, "|", border, bg);
			buffer.setCell(gx + width - 1, gy + y, "|", border, bg);
		}
		buffer.setCell(gx, gy, "+", border, bg);
		buffer.setCell(gx + width - 1, gy, "+", border, bg);
		buffer.setCell(gx, gy + height - 1, "+", border, bg);
		buffer.setCell(gx + width - 1, gy + height - 1, "+", border, bg);
		var label = current ? onLabel : offLabel;
		if (label.length > width - 2) {
			label = label.substr(0, width - 2);
		}
		var offsetX = gx + Std.int((width - label.length) / 2);
		var offsetY = gy + Std.int(height / 2);
		buffer.writeText(offsetX, offsetY, label, textColor, bg);
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (!enabled) {
			return false;
		}
		if (localX < 0 || localX >= width || localY < 0 || localY >= height) {
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
