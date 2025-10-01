package sgui.containers;

import cc_basics.Enums.Color;
import sgui.core.Container;
import sgui.core.FrameBuffer;

class RootContainer extends Container {
	public function new(width:Int, height:Int) {
		super(width, height);
	}

	public function resize(width:Int, height:Int):Void {
		if (this.width != width) {
			this.width = width;
		}
		if (this.height != height) {
			this.height = height;
		}

		requestLayout();
		requestRender();
	}

	override public function render(buffer:FrameBuffer):Void {
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		buffer.fillRect(0, 0, actualWidth, actualHeight, " ", Color.WHITE, background);
		super.render(buffer);
	}
}
