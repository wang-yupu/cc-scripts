package ae2_createcpb_takeout;

import utils.AdvancedDrawing;
import cc_basics.Enums.Side;
import cc_basics.peripherals.Redstone.RedstonePin;
import sgui.widgets.Switch;
import sgui.widgets.Button;
import sgui.widgets.Label;
import sgui.containers.VerticalContainer;
import cc_basics.peripherals.Speaker;
import ae2_createcpb_takeout.Utils.SpeakerUtils;
import ae2_createcpb_takeout.Utils.NamespaceUtils;
import haxe.Exception;
import sgui.SGUI;
import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import ae2_createcpb_takeout.ClipboardReader;
import cc_basics.Logger;
import cc_basics.Base;
import cc_basics.peripherals.Monitor;
import cc_basics.peripherals.advanced.BlockReader;
import cc_basics.peripherals.advanced.MEBridge;
import utils.CMath;

typedef MovingOptions = {
	outToExternal:Bool,
	skipMissing:Bool
};

private enum State {
	WaitingForClipboard;
	WaitingForConfirm(list:ClipboardReader.ItemList);
	Moving(list:ClipboardReader.ItemList, option:MovingOptions);
	Done(stat:{total:Int, time:Int});
}

class Main {
	public static function main() {
		Logger.setTarget(LoggerTarget.local);

		while (true) {
			new Main().run();
		}
	}

	private var blockReader:BlockReader;
	private var clipboardReader:ClipboardReader;
	private var MEAccess:MEBridge;
	private var state:State;
	private var outControl:RedstonePin;

	private var wallMonitor:Monitor;
	private var outBuffer:FrameBuffer;

	private var spk:SpeakerUtils;

	private function new() {
		this.blockReader = new BlockReader("block_reader_2");
		this.clipboardReader = new ClipboardReader(this.blockReader);
		this.MEAccess = new MEBridge("me_bridge_2");
		this.outControl = new RedstonePin(Side.FRONT);
		this.wallMonitor = new Monitor(MonitorTarget.remote("monitor_2"));
		this.wallMonitor.setScale(0.5);

		try {
			this.spk = new SpeakerUtils(new Speaker("speaker_1"));
		} catch (e:Dynamic) {
			Logger.warning('Failed to open speaker. Error: ${e}');
		}

		this.BUFFER_SIZE = {x: MONITOR_SINGLE_BLOCK_SIZE.x * 3 - 2, y: MONITOR_SINGLE_BLOCK_SIZE.y * 3 + 1}
		this.outBuffer = new FrameBuffer(this.wallMonitor.getSize()[0], this.wallMonitor.getSize()[1]);
		Logger.info('Init main buffer. Size: ${this.wallMonitor.getSize()}');
		this.outBuffer.clear(null, Color.RED);

		this.initView();
	}

	private function run() {
		state = State.WaitingForClipboard;

		try {
			var tid:Int = 0;
			updateView();
			while (true) {
				sm();
				updateView();
				tid = Base.startTimer(0.05);
				var event = Base.pullEvent();
				if (event[0] != "timer") {
					switch (event[0]) {
						case "monitor_touch":
							if (event[1] == this.wallMonitor.getID()) {
								var ptInBuffer:Vec2i = VecUtils.sub({x: Math.floor(event[2] - 1), y: Math.floor(event[3] - 1)}, this.MONITOR_START);
								if (VecUtils.inside(this.settingsComposePos, this.settingsSize, ptInBuffer)) {
									var point:Vec2i = VecUtils.sub(ptInBuffer, this.settingsComposePos);
									this.UISettings.handleRawEvent(["monitor_touch", "undefined", point.x + 1, point.y + 1]);
								}
							}
						default:
					}
				} else {
					Base.cancelTimer(tid);
				}
			}
		} catch (e:Dynamic) {
			Logger.error('Error: ${e}');
			this.spk.boom();
			this.buffer.clear(null, Color.BLUE);
			this.buffer.writeText(1, 1, ":(", Color.WHITE, Color.BLUE);
			this.buffer.writeText(1, 2, "Your program DIED", Color.WHITE, Color.BLUE);
			this.buffer.writeText(1, 3, 'E: ${e}', Color.WHITE, Color.BLUE);
			this.outBuffer.compose(this.buffer, MONITOR_START.x, MONITOR_START.y);
			this.outBuffer.syncToMonitor(this.wallMonitor);
			Base.sleep(5);
		}
	}

	private final MONITOR_START:Vec2i = {x: 18, y: 12};
	private final MONITOR_SINGLE_BLOCK_SIZE:Vec2i = {x: 22, y: 14};
	private final BUFFER_SIZE:Vec2i;
	private final background:Color = Color.GRAY;

	private var UISettings:SGUI;
	private var settingsSize:Vec2i;
	private var settingsComposePos:Vec2i;

	private var buffer:FrameBuffer;
	private var depotInformationFBUF:FrameBuffer;
	private var itemListFBUF:FrameBuffer;
	private var outputIndicatorFBUF:FrameBuffer;

	private var progressString:String = "Program Loading";
	private var progressColor:Int = 1;
	private final PROGRESS_COLOR_MAPPING = [Color.WHITE, Color.LIME, Color.YELLOW, Color.RED];

	private function initView() {
		Logger.info('Main buffer size: ${this.BUFFER_SIZE}');
		this.buffer = new FrameBuffer(this.BUFFER_SIZE.x, this.BUFFER_SIZE.y);
		this.buffer.clear(null, background);

		this.depotInformationFBUF = new FrameBuffer(MONITOR_SINGLE_BLOCK_SIZE.x - 1, 3);
		this.depotInformationFBUF.clear(null, background);
		this.depotInformationFBUF.writeText(Math.floor((MONITOR_SINGLE_BLOCK_SIZE.x - 9) * 0.5), 1, "Clipboard", Color.MAGENTA);

		this.itemListFBUF = new FrameBuffer(MONITOR_SINGLE_BLOCK_SIZE.x * 2 - 1, MONITOR_SINGLE_BLOCK_SIZE.y * 2 - 1);
		this.itemListFBUF.clear(null, Color.BROWN);
		this.drawItemList(null);

		this.outputIndicatorFBUF = new FrameBuffer(MONITOR_SINGLE_BLOCK_SIZE.x - 1, MONITOR_SINGLE_BLOCK_SIZE.y + 1);
		this.outputIndicatorFBUF.clear(null, background);

		this.settingsSize = {x: MONITOR_SINGLE_BLOCK_SIZE.x - 1, y: MONITOR_SINGLE_BLOCK_SIZE.y * 2 - 1}
		this.settingsComposePos = {x: MONITOR_SINGLE_BLOCK_SIZE.x * 2 - 1, y: 1};
		this.UISettings = new SGUI(null, {width: this.settingsSize.x, height: this.settingsSize.y});
		this.initSettingsGUI();

		this.updateList(null, true);
	}

	private var settingsConfirmButton:Button;
	private var settingsAutocraftingSwitch:Switch;
	private var settingsOutputInterfaceSwitch:Switch;

	private var movingOptions:MovingOptions;

	private function initSettingsGUI() {
		Logger.info('Settings SGUI compose pos: ${this.settingsComposePos} + ${this.settingsSize}');
		var container:VerticalContainer = new VerticalContainer(this.settingsSize.x, this.settingsSize.y);
		this.UISettings.root.add(container);
		this.UISettings.root.background = Color.CYAN;
		container.background = Color.BLUE;

		var header:Label = new Label("[ OPERATIONS ]", LabelWidth.block);
		header.align = LabelAlign.CENTER;
		header.foreground = Color.MAGENTA;
		header.background = Color.CYAN;
		container.add(header);

		this.settingsConfirmButton = new Button("START", null, 3);
		container.add(this.settingsConfirmButton);
		this.settingsConfirmButton.onClick = this.startMoving;

		this.settingsAutocraftingSwitch = new Switch(true, null, 3);
		this.settingsAutocraftingSwitch.onLabel = "Craft missing items";
		this.settingsAutocraftingSwitch.offLabel = "Skip missing items";
		this.settingsAutocraftingSwitch.onToggle = function(state) {
			this.progressString = state ? "Switch toggled ON" : "Switch toggled OFF";
		};
		container.add(this.settingsAutocraftingSwitch);

		this.settingsOutputInterfaceSwitch = new Switch(false, null, 3);
		this.settingsOutputInterfaceSwitch.onLabel = "Out: EXTERNAL";
		this.settingsOutputInterfaceSwitch.offLabel = "Out: INTERNAL";
		this.settingsOutputInterfaceSwitch.onColor = Color.CYAN;
		this.settingsOutputInterfaceSwitch.offColor = Color.PINK;
		container.add(this.settingsOutputInterfaceSwitch);
		this.settingsOutputInterfaceSwitch.onToggle = function(state) {
			this.outControl.set(state);
		}

		this.UISettings.update();
	}

	private function updateSettingsGUI() {
		if (this.state.getIndex() == State.WaitingForConfirm(null).getIndex()) {
			this.settingsConfirmButton.enabled = true;
			this.settingsConfirmButton.background = this.settingsConfirmButton.background == Color.GRAY ? Color.GREEN : Color.GRAY;
		} else {
			this.settingsConfirmButton.background = Color.LIGHT_GRAY;
			this.settingsConfirmButton.enabled = false;
		}
		static var locked:Bool = false;
		if ((this.state.getIndex() == State.Moving(null, null).getIndex()) != locked) {
			locked = this.state.getIndex() == State.Moving(null, null).getIndex();
			if (locked) {
				this.settingsAutocraftingSwitch.enabled = false;
			}
		}
	}

	private function startMoving() {
		switch (this.state) {
			case WaitingForConfirm(list):
				this.state = Moving(list, {
					skipMissing: this.settingsAutocraftingSwitch.value,
					outToExternal: this.settingsOutputInterfaceSwitch.value
				});
			default:
				return;
		}
	}

	private inline function setProgress(s:String, c:Int) {
		this.progressString = s;
		this.progressColor = Math.floor(Math.min(3, c));
	}

	private function updateView() {
		// GUI
		if (this.lastItemList != this.currentItemList) {
			this.drawItemList(this.currentItemList);
			this.lastItemList = this.currentItemList;
			this.forceUpdateItemList = false;
		}
		this.updateOutputIndicator();
		this.updateSettingsGUI();

		// overlay
		this.buffer.writeText(0, 0, StringTools.rpad(this.progressString, " ", BUFFER_SIZE.x), PROGRESS_COLOR_MAPPING[this.progressColor], Color.LIGHT_GRAY);

		var pos:Vec2i = {
			x: this.outputIndicatorFBUF.width - 1,
			y: Math.floor(this.outputIndicatorFBUF.height / 2)
		}; // 20,7

		// last: compose & sync
		this.buffer.compose(this.depotInformationFBUF, 0, MONITOR_SINGLE_BLOCK_SIZE.y * 2);
		this.buffer.compose(this.itemListFBUF, 0, 1);
		this.buffer.compose(this.outputIndicatorFBUF, MONITOR_SINGLE_BLOCK_SIZE.x, MONITOR_SINGLE_BLOCK_SIZE.y * 2);
		this.buffer.compose(this.UISettings.update(), this.settingsComposePos.x, this.settingsComposePos.y);

		this.outBuffer.compose(this.buffer, MONITOR_START.x, MONITOR_START.y);
		this.outBuffer.syncToMonitor(this.wallMonitor);
	}

	private var lastItemList:Null<ItemList> = null;
	private var currentItemList:Null<ItemList> = null;
	private var forceUpdateItemList:Bool = false;

	private function drawItemList(i:Null<ItemList>) {
		// layout
		var fbufHeight:Int = this.itemListFBUF.height - 1;
		var fbufWidth:Int = this.itemListFBUF.width;
		// 清空
		this.itemListFBUF.clear(Color.WHITE, Color.BROWN);
		this.itemListFBUF.writeText(Math.floor((fbufWidth - 13) * 0.5), 0, "[ Item List ]", Color.MAGENTA);
		if (i == null) {
			this.itemListFBUF.writeText(Math.floor((fbufWidth - 18) * 0.5), Math.floor(fbufHeight * 0.5), "NO VALID CLIPBOARD", Color.YELLOW);
			return;
		}
		// 重绘
		var list = i.list.slice(0, fbufHeight);
		var index:Int = 1;
		for (item in list) {
			var name:String = item.id.split(":")[1];
			var namespace:{s:String, c:Color} = Utils.NamespaceUtils.toShortNamespace(item.id);
			this.itemListFBUF.writeText(0, index, '${item.amount}x ${name}');
			var colors:Array<Color> = [Color.LIME, Color.LIGHT_GRAY, namespace.c, Color.PURPLE];
			if (item.skip) {
				for (i in 0...colors.length) {
					colors[i] = Color.LIGHT_GRAY;
				}
			}
			Utils.DrawUtils.writeTextParts(this.itemListFBUF, 0, index, ['${item.amount}', "x ", namespace.s, name], colors);

			index++;
		}
	}

	private function updateList(i:Null<ItemList>, forceUpdate:Bool = false) {
		this.currentItemList = i;
		this.forceUpdateItemList = forceUpdate;
	}

	private function updateOutputIndicator() {
		static var lastOutputTarget:Bool = null; // true: EXTERNAL,CYAN; false: INTERNAL,PINK
		if (lastOutputTarget == null) {
			lastOutputTarget = this.settingsOutputInterfaceSwitch.value;
		} else if (lastOutputTarget == this.settingsOutputInterfaceSwitch.value) {
			return;
		}
		lastOutputTarget = this.settingsOutputInterfaceSwitch.value;
		this.outputIndicatorFBUF.clear(null, background);
		this.outputIndicatorFBUF.writeText(Math.floor((this.outputIndicatorFBUF.width - 14) * 0.5), 3, "Output Target:", Color.LIGHT_GRAY);

		switch (this.settingsOutputInterfaceSwitch.value) {
			case true:
				var pos:Vec2i = {
					x: this.outputIndicatorFBUF.width - 1,
					y: Math.floor(this.outputIndicatorFBUF.height / 2)
				};
				AdvancedDrawing.drawSimpleTriangle(this.outputIndicatorFBUF, pos, 7, 3, Direction.Right, " ", Color.WHITE, Color.CYAN);
				AdvancedDrawing.alignedText(this.outputIndicatorFBUF, 4, 0.5, "External", Color.CYAN);

			case false:
				var pos:Vec2i = {
					x: Math.floor(this.outputIndicatorFBUF.width / 2),
					y: this.outputIndicatorFBUF.height - 1
				};
				AdvancedDrawing.drawSimpleTriangle(this.outputIndicatorFBUF, pos, 9, 4, Direction.Down, " ", Color.WHITE, Color.PINK);
				AdvancedDrawing.alignedText(this.outputIndicatorFBUF, 4, 0.5, "Internal", Color.PINK);
		}
	}

	private function sm() {
		this.setProgress("Pending", 0);
		switch (this.state) {
			case WaitingForClipboard:
				this.updateList(null);
				var r:ClipboardValidState = this.clipboardReader.read();
				static var rLast:Int = 1;

				switch (r) {
					case NotDepot:
						throw new Exception("WHERE IS THE DEPOT???");
					case NoItem:
						this.setProgress("Put clipboard on depot", 1);
					case NotClipboard(id):
						var name:String = id.split(":")[1];
						this.setProgress('Not a clipboard: ${name}', 2);
						if (r.getIndex() != rLast) this.spk.wrong();
					case ClipboardNotItemList:
						this.setProgress("Clipboard isn't an item list", 2);
						if (r.getIndex() != rLast) this.spk.wrong();
					case FailedToParse(e):
						this.setProgress('Failed to parse data: ${e}', 3);
						Logger.error('Exception: ${e}');
					case Valid(items):
						this.state = WaitingForConfirm(items);
						this.spk.ring();
				}
				rLast = r.getIndex();
			case WaitingForConfirm(list):
				this.setProgress("Confirm to continue", 1);

				var r:ClipboardValidState = this.clipboardReader.read(false);
				if (!Type.enumEq(r, ClipboardValidState.Valid(null))) {
					this.state = WaitingForClipboard;
				}
				this.updateList(list);
			case Moving(list, option):

			case Done(stat):
		}
	}
}
