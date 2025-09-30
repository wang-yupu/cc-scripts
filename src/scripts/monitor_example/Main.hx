package monitor_example;

import sgui.widgets.Switch;
import sgui.widgets.Label;
import sgui.widgets.Button;
import sgui.widgets.Input;
import sgui.containers.VerticalContainer;
import cc_basics.peripherals.Monitor;
import cc_basics.Base;
import cc_basics.Enums;
import cc_basics.Logger;
import fmt.EventHandler;
import sgui.SGUI;

class Main {
	public static function main() {
		var monitor = new Monitor(MonitorTarget.local);
		var logger = new Monitor(MonitorTarget.remote(Side.RIGHT));
		Logger.setTarget(LoggerTarget.monitor(logger));
		var disp = new SGUI(monitor);
		var root = disp.root;

		var layout = new VerticalContainer(root.width, root.height, true);
		layout.spacing = 1;
		root.add(layout);

		var input = new Input(20);
		input.placeholder = "Input content";
		layout.add(input);

		var switchWidget = new Switch();
		layout.add(switchWidget);

		var button = new Button("Submit");
		button.onClick = function() {
			Logger.info("submitted :: ", input.text);
		};
		layout.add(button);

		disp.startBackgroundUpdate();

		for (i in 0...20) {
			var l = new Label('hi im ${i}');
			layout.add(l);
		}

		while (true) {
			Base.sleep0();
		}
	}
}
