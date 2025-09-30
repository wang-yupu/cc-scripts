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

	private var activate:Bool = false;

	public function new(text:String = "Button", width:Int = 0, height:Int = 1) {
		super(width, height);
		this.text = text;
		if (this.width <= 0) {
			this.width = Math.floor(Math.max(text.length + 2, 4));
		}
		if (this.height <= 0) {
			this.height = 3;
		}
	}

	override public function render(fbuf:FrameBuffer):Void {
		if (!visible) {
			return;
		}

		var gx = getGlobalX();
		var gy = getGlobalY();
		var rbg = background;
		if (this.activate) {
			rbg = this.activeBackground;
		}
		fbuf.fillRect(gx, gy, width, height, " ", foreground, rbg);
		var label = text != null ? text : "";
		if (label.length > width - 2) {
			label = label.substr(0, width - 2);
		}
		var offsetX = gx + Std.int((width - label.length) / 2);
		var offsetY = gy + Std.int(height / 2);
		fbuf.writeText(offsetX, offsetY, label, foreground, rbg);
		this.activate = false;
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (!enabled) {
			return false;
		}
		this.activate = true;
		var inside = localX >= 0 && localX < width && localY >= 0 && localY < height;
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
