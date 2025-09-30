package sgui.widgets;

import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

enum LabelAlign {
	LEFT;
	CENTER;
	RIGHT;
}

class Label extends Widget {
	public var text:String;
	public var foreground:Color = Color.WHITE;
	public var background:Color = Color.BLACK;
	public var align:LabelAlign = LabelAlign.LEFT;
	public var ellipsis:Bool = false;

	public function new(text:String = "", width:Int = 0, height:Int = 1) {
		super(width, height);
		this.text = text;
		if (this.height <= 0) {
			this.height = 1;
		}
	}

	override public function render(buffer:FrameBuffer):Void {
		if (!visible) {
			return;
		}
		var line = text != null ? text : "";
		if (ellipsis && width > 0 && line.length > width) {
			var truncated = width >= 3 ? width - 3 : width;
			if (truncated < 0) {
				truncated = 0;
			}
			line = line.substr(0, truncated) + (width >= 3 ? "..." : "");
		}
		var renderWidth = width > 0 ? width : line.length;
		if (renderWidth <= 0) {
			return;
		}
		buffer.fillRect(getGlobalX(), getGlobalY(), renderWidth, height, " ", foreground, background);
		var actual = line;
		if (actual.length > renderWidth) {
			actual = actual.substr(0, renderWidth);
		}
		var offset = 0;
		switch (align) {
			case LEFT:
				offset = 0;
			case CENTER:
				offset = Std.int((renderWidth - actual.length) / 2);
			case RIGHT:
				offset = renderWidth - actual.length;
		}
		if (offset < 0) {
			offset = 0;
		}
		buffer.writeText(getGlobalX() + offset, getGlobalY(), actual, foreground, background);
	}
}
