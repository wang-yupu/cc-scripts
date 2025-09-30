package sgui.containers;

import sgui.core.Container;
import sgui.core.Widget;

class HorizontalContainer extends Container {
	public var spacing:Int = 0;
	public var alignMiddle:Bool = false;

	public function new(width:Int = 0, height:Int = 0) {
		super(width, height);
	}

	override public function layout():Void {
		var cursor = 0;
		var availableHeight = height;
		for (child in children) {
			if (!child.visible) {
				continue;
			}
			child.x = cursor;
			if (alignMiddle) {
				var offset = Std.int((availableHeight - child.height) / 2);
				if (offset < 0) {
					offset = 0;
				}
				child.y = offset;
			} else {
				child.y = 0;
			}
			if (child.height != availableHeight && !alignMiddle) {
				child.height = availableHeight;
			}
			child.layout();
			child.markLaidOut();
			cursor += child.width + spacing;
		}
		markLaidOut();
	}
}
