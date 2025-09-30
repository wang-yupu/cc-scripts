package sgui.containers;

import sgui.core.Container;
import sgui.core.Widget;

class HorizontalContainer extends Container {
	public var spacing:Int = 0;
	public var alignMiddle:Bool = false;

	public function new(width:Null<Int> = null, height:Null<Int> = 1) {
		super(width, height);
	}

	override public function layout():Void {
		var cursor = 0;
		var availableHeight = getActualHeight();
		for (child in children) {
			if (!child.visible) {
				continue;
			}
			child.x = cursor;
			if (alignMiddle) {
				var actualChildHeight = child.getActualHeight();
				var offset = Std.int((availableHeight - actualChildHeight) / 2);
				if (offset < 0) {
					offset = 0;
				}
				child.y = offset;
			} else {
				child.y = 0;
			}
			if (child.height == null || (child.getActualHeight() != availableHeight && !alignMiddle)) {
				child.height = availableHeight;
			}
			child.layout();
			child.markLaidOut();
			cursor += child.getActualWidth() + spacing;
		}
		markLaidOut();
	}
}
