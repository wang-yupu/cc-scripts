package monitor_example;

import sgui.widgets.withLabel.InputWithLabel;
import sgui.containers.HorizontalContainer;
import sgui.containers.TabContainer;
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

		var mainLayout = new TabContainer(root.width, root.height);
		root.add(mainLayout);
		var layout1 = new VerticalContainer(root.width, root.height, true);
		layout1.spacing = 1;
		mainLayout.addTab("Some widgets", layout1);

		var layout2 = new VerticalContainer(root.width, root.height, true);
		mainLayout.addTab("Config demo", layout2);

		var layout3 = new VerticalContainer(root.width, root.height, true);
		mainLayout.addTab("All the chars", layout3);

		var input = new Input(20);
		input.placeholder = "Input content";
		layout1.add(input);

		var switchWidget = new Switch();
		layout1.add(switchWidget);

		var button = new Button("Submit");
		button.onClick = function() {
			Logger.info("submitted :: ", input.text);
		};
		layout1.add(button);

		for (v in 0...5) {
			var w = new InputWithLabel();
			w.placeholder = '<Option ${v}>';
			w.labelText = 'Option ${v} :';
			w.background = Type.createEnumIndex(Color, v + 2);
			layout2.add(w);
		}
		layout2.add(new Label("Note: You can paste with Ctrl+V; Selection with Shift+L/R or Ctrl+A", LabelWidth.block, WrapMode.Space));
		var charCodeInput = new Input();
		charCodeInput.placeholder = "0";
		var charDisplay = new Label("");
		layout3.add(charCodeInput);
		layout3.add(charDisplay);

		var sbuf = new StringBuf();
		for (i in 0...8) {
			for (v in 0...8) {
				sbuf.add(String.fromCharCode(i * 8 + v));
			}
			sbuf.add("\n");
		}
		var cdsp = new Label(sbuf.toString(), LabelWidth.auto, WrapMode.Char);
		layout3.add(cdsp);

		disp.startBackgroundUpdate();

		for (i in 0...20) {
			var l = new Label('hi im ${i}');
			layout1.add(l);
		}
		disp.showFPS = true;
		while (true) {
			try {
				var v = Std.parseInt(charCodeInput.text);
				if (v != null) {
					charDisplay.text = String.fromCharCode(v) + String.fromCharCode(8);
					charCodeInput.placeholder = Std.string(v);
				}
			} catch (e:Dynamic) {}
			Base.sleep0();
		}
	}
}
