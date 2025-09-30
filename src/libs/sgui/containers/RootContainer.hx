package sgui.containers;

import cc_basics.Enums.Color;
import sgui.core.Container;
import sgui.core.FrameBuffer;

class RootContainer extends Container {
	public var background:Color = Color.BLACK;

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
	}

	override public function render(buffer:FrameBuffer):Void {
		buffer.fillRect(0, 0, width, height, " ", Color.WHITE, background);
		super.render(buffer);
	}
}
