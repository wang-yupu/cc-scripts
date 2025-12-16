package sgui_example;

import sgui.core.FrameBuffer;
import cc_basics.Base;
import cc_basics.Enums.Color;
import cc_basics.Enums.Side;
import cc_basics.peripherals.Monitor;
import sgui.SGUI;
import sgui.containers.TabContainer;
import sgui.containers.VerticalContainer;
import sgui.widgets.Button;
import sgui.widgets.Input;
import sgui.widgets.Label;
import sgui.widgets.Switch;

class Main {
	public static function main() {
		var monitor = new Monitor(MonitorTarget.remote(Side.RIGHT));
		var buf = new FrameBuffer(monitor.getSize()[0], monitor.getSize()[1]);
		var gui = new SGUI(null, {width: 20, height: 30});

		var root = gui.root;
		root.background = Color.BLACK;

		var tabs = new TabContainer(root.width, root.height);
		root.add(tabs);

		var controls = new VerticalContainer(root.width, root.height - tabs.headerHeight, true);
		controls.spacing = 1;
		tabs.addTab("Controls", controls);

		var header = new Label("Simple GUI Demo", LabelWidth.fixed(root.width), WrapMode.None);
		header.foreground = Color.LIGHT_BLUE;
		controls.add(header);

		var input = new Input(20);
		input.placeholder = "Type and press Enter";

		var message = new Label("Ready.", LabelWidth.fixed(root.width), WrapMode.None);
		message.foreground = Color.CYAN;
		controls.add(message);

		input.onSubmit = function(value) {
			message.text = 'Submitted: ' + value;
		};
		controls.add(input);

		var toggle = new Switch(false);
		toggle.onToggle = function(state) {
			message.text = state ? "Switch toggled ON" : "Switch toggled OFF";
		};
		controls.add(toggle);

		var button = new Button("Click me", 12, 3);
		button.onClick = function() {
			message.text = "Button clicked!";
		};
		controls.add(button);

		gui.update();

		while (true) {
			var event = Base.pullEvent();
			gui.handleRawEvent(event, {x: -10, y: -5});
			buf.compose(gui.update(), 10, 5, 20, 30);
			buf.syncToMonitor(monitor);
		}
	}
}
