package sgui.containers;

import cc_basics.Logger;
import cc_basics.Enums.Color;
import sgui.core.Container;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

class VerticalContainer extends Container {
	public var spacing:Int = 0;
	public var scrollable:Bool = false;
	public var scrollBarWidth:Int = 1;
	public var scrollStep:Int = 1;
	public var scrollOffset(default, null):Int = 0;
	public var scrollBarBackground:Color = LIGHT_GRAY;
	public var scrollBarForeground:Color = WHITE;
	public var scrollBarActiveForeground:Color = CYAN;

	private var contentHeight:Int = 0;
	private var dragging:Bool = false;
	private var hasScrollBar:Bool = false;
	private var dragGrabOffset:Int = 0;
	private var knobHeight:Int = 1;
	private var scrollBarHighlightTime:Int = 0;

	public function new(width:Int = 0, height:Int = 0, scrollable:Bool = false) {
		super(width, height);
		this.scrollable = scrollable;
	}

	override inline public function layout():Void {
		var availableWidth = width;
		if (scrollable) {
			availableWidth -= scrollBarWidth;
			if (availableWidth < 0) {
				availableWidth = 0;
			}
		}
		var cursor = -scrollOffset;
		var lastVisible:Widget = null;
		contentHeight = 0;
		for (child in children) {
			if (!child.visible) {
				continue;
			}
			child.x = 0;
			if (child.width != availableWidth) {
				child.width = availableWidth;
			}
			child.y = cursor;
			child.layout();
			child.markLaidOut();
			cursor += child.height + spacing;
			lastVisible = child;
		}
		if (lastVisible != null) {
			cursor -= spacing;
		}
		contentHeight = cursor + scrollOffset;
		if (contentHeight < height) {
			contentHeight = height;
		}
		computeKnobHeight();
		markLaidOut();
	}

	override public inline function render(fbuf:FrameBuffer):Void {
		super.render(fbuf);
		if (!scrollable || !hasOverflow()) {
			return;
		}
		this.hasScrollBar = true;
		var barX = getGlobalX() + width - scrollBarWidth;
		var barY = getGlobalY();
		var sfg = this.scrollBarForeground;
		if (this.scrollBarHighlightTime != 0) {
			sfg = this.scrollBarActiveForeground;
			this.scrollBarHighlightTime--;
		}
		fbuf.fillRect(barX, barY, scrollBarWidth, height, " ", this.scrollBarBackground, this.scrollBarBackground);
		var knobTop = computeKnobTop();
		fbuf.fillRect(barX, barY + knobTop, scrollBarWidth, knobHeight, " ", sfg, sfg);
	}

	override public function handleScroll(direction:Int, localX:Int, localY:Int):Bool {
		if (!scrollable || !hasOverflow()) {
			return false;
		}
		setScrollOffset(this.scrollOffset + direction * scrollStep);
		return true;
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (this.hasScrollBar && this.scrollable) {
			if (localX + 1 == this.width) {
				var perctange = localY / (this.height - 1) * 1.5;
				this.setScrollOffset(Math.ceil(perctange * this.height));
				this.scrollBarHighlightTime = 5;

				return true;
			} else {
				return false;
			}
		}
		return false;
	}

	public function setScrollOffset(value:Int):Void {
		var maxScroll = contentHeight - height;
		if (maxScroll < 0) {
			maxScroll = 0;
		}
		var newValue = value;
		if (newValue < 0) {
			newValue = 0;
		} else if (newValue > maxScroll) {
			newValue = maxScroll;
		}
		if (newValue != scrollOffset) {
			scrollOffset = newValue;
			requestLayout();
			requestRender();
		}
	}

	private inline function hasOverflow():Bool {
		return contentHeight > height;
	}

	private function computeKnobHeight():Void {
		if (!scrollable || !hasOverflow()) {
			knobHeight = height;
			return;
		}
		var maxScroll = contentHeight - height;
		if (maxScroll <= 0) {
			knobHeight = height;
			return;
		}
		var trackRange = height;
		var ratio = height / contentHeight;
		var proposed = Std.int(Math.round(ratio * trackRange));
		if (proposed < 1) {
			proposed = 1;
		}
		if (proposed > height) {
			proposed = height;
		}
		knobHeight = proposed;
	}

	private function computeKnobTop():Int {
		if (!scrollable || !hasOverflow()) {
			return 0;
		}
		var trackRange = height - knobHeight;
		if (trackRange <= 0) {
			return 0;
		}
		var maxScroll = contentHeight - height;
		if (maxScroll <= 0) {
			return 0;
		}
		var ratio = scrollOffset / maxScroll;
		return Std.int(Math.round(ratio * trackRange));
	}
}
