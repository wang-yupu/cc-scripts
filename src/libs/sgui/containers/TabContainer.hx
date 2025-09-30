package sgui.containers;

import cc_basics.Enums.Color;
import sgui.core.Container;
import sgui.core.FrameBuffer;

private typedef Tab = {
	var title:String;
	var content:Container;
	var label:String;
	var start:Int;
	var end:Int;
};

class TabContainer extends Container {
	public var headerHeight:Int = 1;
	public var inactiveColor:Color = Color.LIGHT_GRAY;
	public var activeColor:Color = Color.YELLOW;
	public var headerBackground:Color = Color.BLUE;

	private var tabs:Array<Tab> = [];
	private var activeIndex:Int = -1;

	public function new(width:Int = 0, height:Int = 0) {
		super(width, height);
	}

	public function addTab(title:String, content:Container):Int {
		var normalized = title != null ? title : "Tab";
		var label = ' ${normalized} ';
		var tab:Tab = {
			title: normalized,
			content: content,
			label: label,
			start: 0,
			end: 0
		};
		tabs.push(tab);
		content.visible = false;
		add(content);
		if (activeIndex == -1) {
			selectTab(0);
		} else {
			updateTabRegions();
		}
		return tabs.length - 1;
	}

	public function selectTab(index:Int):Void {
		if (index < 0 || index >= tabs.length) {
			return;
		}
		if (activeIndex == index) {
			return;
		}
		if (activeIndex != -1) {
			tabs[activeIndex].content.visible = false;
		}
		activeIndex = index;
		if (activeIndex != -1) {
			tabs[activeIndex].content.visible = true;
		}
		updateTabRegions();
		requestLayout();
		requestRender();
	}

	public function getActiveTab():Container {
		if (activeIndex == -1) {
			return null;
		}
		return tabs[activeIndex].content;
	}

	override public function layout():Void {
		var areaY = headerHeight;
		var areaHeight = height - headerHeight;
		if (areaHeight < 0) {
			areaHeight = 0;
		}
		for (tab in tabs) {
			tab.content.x = 0;
			tab.content.y = areaY;
			tab.content.width = width;
			tab.content.height = areaHeight;
			tab.content.layout();
			tab.content.markLaidOut();
		}
		markLaidOut();
	}

	override public function render(buffer:FrameBuffer):Void {
		var gx = getGlobalX();
		var gy = getGlobalY();
		if (activeIndex != -1) {
			tabs[activeIndex].content.render(buffer);
		}
		if (headerHeight > 0) {
			buffer.fillRect(gx, gy, width, headerHeight, " ", Color.WHITE, headerBackground);
			for (i in 0...tabs.length) {
				var tab = tabs[i];
				if (tab.start >= width) {
					continue;
				}
				var available = width - tab.start;
				if (available <= 0) {
					continue;
				}
				var label = tab.label;
				if (label.length > available) {
					label = label.substr(0, available);
				}
				var bg = (i == activeIndex) ? activeColor : inactiveColor;
				buffer.writeText(gx + tab.start, gy, label, Color.BLACK, bg);
			}
		}

		markRendered();
	}

	override public function handleRelease(localX:Int, localY:Int):Bool {
		if (localY >= headerHeight) {
			return false;
		}
		for (i in 0...tabs.length) {
			var tab = tabs[i];
			if (localX >= tab.start && localX < tab.end) {
				selectTab(i);
				return true;
			}
		}
		return false;
	}

	private function updateTabRegions():Void {
		var cursor = 0;
		for (tab in tabs) {
			tab.start = cursor;
			cursor += tab.label.length;
			tab.end = cursor;
			cursor += 1;
		}
	}
}
