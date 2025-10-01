package sgui.widgets;

import cc_basics.Enums.Color;
import cc_basics.Logger;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

typedef ButtonHandler = Void->Void;

class Button extends Widget {
	public var text:String;
	public var foreground:Color = Color.BLACK;
	public var background:Color = Color.LIGHT_GRAY;
	public var activeBackground:Color = Color.BLUE;
	public var border:Color = Color.WHITE;
	public var onClick:ButtonHandler;
	public var align:Float = 0.5;

	private var activateTime:Int = 0;

	public function new(text:String = "Button", width:Null<Int> = null, height:Null<Int> = 1) {
		super(width, height);
		this.text = text;
		if (this.width != null && this.width <= 0) {
			this.width = Math.floor(Math.max(text.length + 2, 4));
		}
		if (this.height != null && this.height <= 0) {
			this.height = 3;
		}
	}

	override public function render(fbuf:FrameBuffer):Void {
		if (!visible) {
			return;
		}

		var gx = getGlobalX();
		var gy = getGlobalY();
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		var rbg = background;
		if (this.activateTime != 0) {
			rbg = this.activeBackground;
			this.activateTime--;
		}
		fbuf.fillRect(gx, gy, actualWidth, actualHeight, " ", foreground, rbg);
		var label = text != null ? text : "";
		if (label.length > actualWidth - 2) {
			label = label.substr(0, actualWidth - 2);
		}
		var offsetX = gx + Std.int((actualWidth - label.length) * this.align);
		var offsetY = gy + Std.int(actualHeight * this.align);
		fbuf.writeText(offsetX, offsetY, label, foreground, rbg);
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (!enabled) {
			return false;
		}
		this.activateTime = 1;
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		var inside = localX >= 0 && localX < actualWidth && localY >= 0 && localY < actualHeight;
		Logger.debug("[Button] release name=", name != null ? name : text, " inside=", inside, " local=", localX, ",", localY);
		if (!inside) {
			return false;
		}
		if (onClick != null) {
			onClick();
		}
		return true;
	}
}
