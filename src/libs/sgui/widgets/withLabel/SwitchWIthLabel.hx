package sgui.widgets.withLabel;

import sgui.containers.HorizontalContainer;
import sgui.widgets.Switch;
import sgui.widgets.Label;
import sgui.widgets.Label.LabelWidth;
import sgui.widgets.Label.WrapMode;
import sgui.widgets.Switch.SwitchHandler;
import cc_basics.Enums.Color;

typedef SwitchWithLabelOptions = {
	?labelText:String,
	?labelWidth:LabelWidth,
	?switchWidth:Null<Int>,
	?value:Bool,
	?onLabel:String,
	?offLabel:String
};

class SwitchWithLabel extends HorizontalContainer {
	public var label(default, null):Label;
	public var switchWidget(default, null):Switch;

	public var value(get, set):Bool;
	public var onLabel(get, set):String;
	public var offLabel(get, set):String;
	public var onColor(get, set):Color;
	public var offColor(get, set):Color;
	public var onToggle(get, set):SwitchHandler;

	public var labelText(get, set):String;
	public var background(get, set):Color;
	public var foreground(get, set):Color;

	public function new(options:SwitchWithLabelOptions = null) {
		super();

		if (options == null)
			options = {};

		var labelWidth = options.labelWidth != null ? options.labelWidth : LabelWidth.auto;
		label = new Label(options.labelText != null ? options.labelText : "Option:", labelWidth, WrapMode.None);

		var initialValue = options.value != null ? options.value : false;
		switchWidget = new Switch(initialValue, options.switchWidth);

		if (options.onLabel != null) {
			switchWidget.onLabel = options.onLabel;
		}
		if (options.offLabel != null) {
			switchWidget.offLabel = options.offLabel;
		}

		add(label);
		add(switchWidget);

		spacing = 1;
	}

	function get_value():Bool {
		return switchWidget.value;
	}

	function set_value(v:Bool):Bool {
		return switchWidget.value = v;
	}

	function get_onLabel():String {
		return switchWidget.onLabel;
	}

	function set_onLabel(value:String):String {
		return switchWidget.onLabel = value;
	}

	function get_offLabel():String {
		return switchWidget.offLabel;
	}

	function set_offLabel(value:String):String {
		return switchWidget.offLabel = value;
	}

	function get_onColor():Color {
		return switchWidget.onColor;
	}

	function set_onColor(value:Color):Color {
		return switchWidget.onColor = value;
	}

	function get_offColor():Color {
		return switchWidget.offColor;
	}

	function set_offColor(value:Color):Color {
		return switchWidget.offColor = value;
	}

	function get_onToggle():SwitchHandler {
		return switchWidget.onToggle;
	}

	function set_onToggle(value:SwitchHandler):SwitchHandler {
		return switchWidget.onToggle = value;
	}

	function get_labelText():String {
		return label.text;
	}

	function set_labelText(value:String):String {
		return label.text = value;
	}

	function get_background():Color {
		return label.background;
	}

	function set_background(value:Color):Color {
		return label.background = value;
	}

	function get_foreground():Color {
		return label.foreground;
	}

	function set_foreground(value:Color):Color {
		return label.foreground = value;
	}
}
