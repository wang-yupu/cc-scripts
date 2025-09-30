package sgui;

import cc_basics.Base;
import cc_basics.Enums.Color;
import cc_basics.Logger;
import cc_basics.peripherals.Monitor;
import fmt.EventHandler;
import fmt.Manager;
import Type;
import sgui.core.Container;
import sgui.core.FrameBuffer;
import sgui.core.Widget;
import sgui.containers.RootContainer;
import sgui.events.Events;
import sgui.widgets.Button;
import sgui.widgets.Input;

class SGUI {
	public var monitor(default, null):Monitor;
	public var root(default, null):RootContainer;

	public var onRelease:TouchHandler;
	public var onScroll:ScrollHandler;
	public var onKeyInput:KeyHandler;
	public var onCharInput:CharHandler;
	public var onResize:ResizeHandler;

	private var framebuffer:FrameBuffer;
	private var buttonGrid:Array<Array<Button>>;
	private var focused:Widget;
	private var monitorWidth:Int;
	private var monitorHeight:Int;
	private var autoHandler:EventHandler;
	private var backgroundRunnerActive:Bool = false;
	private var backgroundInterval:Float = 0.05;
	private var monitorId:String;
	private var autoLoopRegistered:Bool = false;

	public function new(monitor:Monitor) {
		this.monitor = monitor;
		monitorId = monitor.getID();
		var dims = readMonitorSize();
		monitorWidth = dims.width;
		monitorHeight = dims.height;
		framebuffer = new FrameBuffer(monitorWidth, monitorHeight);
		root = new RootContainer(monitorWidth, monitorHeight);
		buttonGrid = [];
		ensureButtonGrid();

		if (!this.monitor.isLocal()) {
			Base.print("[SGUI Tips] No keyboard? type your things in native term!");
		}
		Logger.info("[SGUI] initialised for monitor ", monitorId, " (", monitorWidth, "x", monitorHeight, ")");
	}

	public function update():Void {
		ensureSize();
		if (root.needsLayout()) {
			Logger.debug("[SGUI] update layout");
			root.layout();
		}
		framebuffer.clear(Color.WHITE, root.background, " ");
		root.render(framebuffer);
		framebuffer.syncToMonitor(monitor);
		rebuildButtonLookup();
	}

	public function startBackgroundUpdate(interval:Float = 0.05):Void {
		backgroundInterval = interval;
		if (!autoLoopRegistered) {
			ThreadManager.add(updateLoop);
			autoLoopRegistered = true;
		}
		if (autoHandler == null) {
			autoHandler = new EventHandler(onCCEvent, "monitor_touch", "mouse_scroll", "char", "key", "mouse_drag", "mouse_up", "monitor_resize",
				"term_resize", "paste");
			EventHandler.registerAll();
		}
		if (!backgroundRunnerActive) {
			backgroundRunnerActive = true;
			ThreadManager.start();
			Logger.info("[SGUI] background update started @ interval=", interval);
		}
	}

	public function stopBackgroundUpdate():Void {
		backgroundRunnerActive = false;
		Logger.info("[SGUI] background update stopped");
	}

	public function handleRelease(x:Int, y:Int):Void {
		Logger.debug("[SGUI] handleRelease input=", x, ",", y);
		if (!insideDisplay(x, y)) {
			Logger.debug("[SGUI] release outside display");
			return;
		}
		if (onRelease != null) {
			onRelease(x, y);
		}

		var target:Widget = buttonAt(x, y);
		if (target == null) {
			target = root.findLeaf(x, y);
		}
		Logger.debug("[SGUI] release target=", widgetLabel(target));
		if (target == null) {
			setFocus(null);
			return;
		}
		if (target.isFocusable()) {
			setFocus(target);
		} else if (!Std.isOfType(target, Container)) {
			setFocus(null);
		}
		dispatchRelease(target, x, y);
	}

	public function handleScroll(direction:Int, x:Int, y:Int):Void {
		Logger.debug("[SGUI] handleScroll dir=", direction, " @ ", x, ",", y);
		if (onScroll != null) {
			onScroll(direction, x, y);
		}
		var target = root.findLeaf(x, y);
		Logger.debug("[SGUI] scroll target=", widgetLabel(target));
		dispatchScroll(target, direction, x, y);
	}

	public function handleDrag(x:Int, y:Int):Void {
		this.handleRelease(x, y);
	}

	public function handleChar(ch:String):Void {
		Logger.debug("[SGUI] handleChar ch=", ch);
		if (onCharInput != null) {
			onCharInput(ch);
		}
		if (focused != null) {
			focused.handleCharInput(ch);
		}
	}

	public function handleKey(keyCode:Int):Void {
		Logger.debug("[SGUI] handleKey code=", keyCode);
		if (onKeyInput != null) {
			onKeyInput(keyCode);
		}
		if (focused != null) {
			focused.handleKeyInput(keyCode);
		}
	}

	public function handleResize():Void {
		Logger.info("[SGUI] handleResize triggered");
		ensureSize(true);
	}

	public function handleRawEvent(event:Array<Dynamic>):Void {
		if (event == null || event.length == 0) {
			return;
		}
		Logger.debug("[SGUI] event fired :: ", event);
		var name = Std.string(event[0]);
		switch (name) {
			case "monitor_touch":
				if (event.length >= 4 && matchesMonitor(event[1])) {
					handleRelease(Std.int(event[2]) - 1, Std.int(event[3]) - 1);
				}
			case "mouse_up":
				if (event.length >= 4) {
					handleRelease(Std.int(event[2]) - 1, Std.int(event[3]) - 1);
				}
			case "mouse_scroll":
				if (event.length >= 4) {
					handleScroll(Std.int(event[1]), Std.int(event[2]) - 1, Std.int(event[3]) - 1);
				}
			case "mouse_drag":
				if (event.length >= 4) {
					handleDrag(Std.int(event[2]) - 1, Std.int(event[3]) - 1);
				}
			case "char":
				if (event.length >= 2) {
					handleChar(Std.string(event[1]));
				}
			case "key":
				if (event.length >= 2) {
					handleKey(Std.int(event[1]));
				}
			case "monitor_resize":
				if (event.length >= 2 && matchesMonitor(event[1])) {
					handleResize();
				}
			case "term_resize":
				if (monitorId == null) {
					handleResize();
				}
			default:
		}
	}

	public function getFocused():Widget {
		return focused;
	}

	public function getMonitorSize():{width:Int, height:Int} {
		return {width: monitorWidth, height: monitorHeight};
	}

	private function updateLoop():Void {
		while (backgroundRunnerActive) {
			update();
			Base.sleep(backgroundInterval);
		}
	}

	private function dispatchRelease(widget:Widget, globalX:Int, globalY:Int):Widget {
		var current = widget;
		while (current != null) {
			var local = current.toLocal(globalX, globalY);
			if (current.handleRelease(local.x, local.y)) {
				Logger.debug("[SGUI] dispatchRelease handled by=", widgetLabel(current), " local=", local.x, ",", local.y);
				return current;
			}
			current = current.parent;
		}
		return null;
	}

	private function dispatchScroll(widget:Widget, direction:Int, globalX:Int, globalY:Int):Bool {
		var current = widget;
		while (current != null) {
			var local = current.toLocal(globalX, globalY);
			if (current.handleScroll(direction, local.x, local.y)) {
				Logger.debug("[SGUI] dispatchScroll handled by=", widgetLabel(current), " dir=", direction, " local=", local.x, ",", local.y);
				return true;
			}
			current = current.parent;
		}
		return false;
	}

	private function setFocus(widget:Widget):Void {
		if (focused == widget) {
			return;
		}
		if (focused != null) {
			focused.onBlur();
		}
		focused = widget != null && widget.isFocusable() ? widget : null;
		Logger.debug("[SGUI] focus -> ", widgetLabel(focused));
		if (focused != null) {
			focused.onFocus();
		}
	}

	private function insideDisplay(x:Int, y:Int):Bool {
		return x >= 0 && y >= 0 && x < monitorWidth && y < monitorHeight;
	}

	private function buttonAt(x:Int, y:Int):Button {
		if (buttonGrid == null || y < 0 || y >= buttonGrid.length) {
			return null;
		}
		var row = buttonGrid[y];
		if (row == null || x < 0 || x >= row.length) {
			return null;
		}
		return row[x];
	}

	private function rebuildButtonLookup():Void {
		ensureButtonGrid();
		for (row in buttonGrid) {
			for (i in 0...row.length) {
				row[i] = null;
			}
		}
		root.visit(function(widget:Widget) {
			if (!Std.isOfType(widget, Button)) {
				return;
			}
			var btn:Button = cast widget;
			var bounds = btn.getGlobalBounds();
			for (dy in 0...bounds.height) {
				var by = bounds.y + dy;
				if (by < 0 || by >= monitorHeight) {
					continue;
				}
				var row = buttonGrid[by];
				for (dx in 0...bounds.width) {
					var bx = bounds.x + dx;
					if (bx < 0 || bx >= monitorWidth) {
						continue;
					}
					row[bx] = btn;
				}
			}
		});
	}

	private function ensureButtonGrid():Void {
		if (buttonGrid != null && buttonGrid.length == monitorHeight) {
			var first = monitorHeight > 0 ? buttonGrid[0] : null;
			if (first != null && first.length == monitorWidth) {
				return;
			}
		}
		Logger.debug("[SGUI] resizing button grid to ", monitorWidth, "x", monitorHeight);
		buttonGrid = [];
		for (y in 0...monitorHeight) {
			var row:Array<Button> = [];
			for (x in 0...monitorWidth) {
				row.push(null);
			}
			buttonGrid.push(row);
		}
	}

	private function ensureSize(force:Bool = false):Void {
		var dims = readMonitorSize();
		if (!force && dims.width == monitorWidth && dims.height == monitorHeight) {
			return;
		}
		Logger.info("[SGUI] monitor size updated to ", dims.width, "x", dims.height);
		monitorWidth = dims.width;
		monitorHeight = dims.height;
		framebuffer.resize(monitorWidth, monitorHeight);
		root.resize(monitorWidth, monitorHeight);
		rebuildButtonLookup();
		if (onResize != null) {
			onResize(monitorWidth, monitorHeight);
		}
	}

	private function readMonitorSize():{width:Int, height:Int} {
		var size:Dynamic = monitor.getSize();
		var width = monitorWidth;
		var height = monitorHeight;
		if (Std.isOfType(size, Array)) {
			var arr:Array<Dynamic> = cast size;
			if (arr.length >= 3) {
				width = Std.int(arr[1]);
				height = Std.int(arr[2]);
			} else if (arr.length >= 2) {
				width = Std.int(arr[0]);
				height = Std.int(arr[1]);
			}
		}
		if (width <= 0) {
			width = 1;
		}
		if (height <= 0) {
			height = 1;
		}
		return {width: width, height: height};
	}

	private function onCCEvent(event:String, ...args:Dynamic):Void {
		var payload:Array<Dynamic> = [event];
		for (arg in args) {
			payload.push(arg);
		}
		handleRawEvent(payload);
	}

	private function matchesMonitor(target:Dynamic):Bool {
		if (monitorId == null || monitorId.length == 0) {
			return true;
		}
		var name = Std.string(target);
		if (name == monitorId) {
			return true;
		}
		if (name == 'monitor_' + monitorId) {
			return true;
		}
		return false;
	}

	private inline function widgetLabel(widget:Widget):String {
		if (widget == null) {
			return "null";
		}
		if (widget.name != null && widget.name.length > 0) {
			return widget.name;
		}
		return Type.getClassName(Type.getClass(widget));
	}
}
