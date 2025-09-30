package sgui.widgets.withLabel;

import sgui.containers.HorizontalContainer;
import sgui.widgets.Input;
import sgui.widgets.Label;
import sgui.widgets.Label.LabelWidth;
import sgui.widgets.Label.WrapMode;
import sgui.widgets.Input.InputHandler;
import cc_basics.Enums.Color;

typedef InputWithLabelOptions = {
	?labelText:String,
	?labelWidth:LabelWidth,
	?inputWidth:Null<Int>,
	?placeholder:String,
	?maxLength:Int
};

class InputWithLabel extends HorizontalContainer {
	public var label(default, null):Label;
	public var input(default, null):Input;

	public var text(get, set):String;
	public var placeholder(get, set):String;
	public var maxLength(get, set):Int;
	public var onChange(get, set):InputHandler;
	public var onSubmit(get, set):InputHandler;

	public var labelText(get, set):String;
	public var background(get, set):Color;
	public var foreground(get, set):Color;

	public function new(options:InputWithLabelOptions = null) {
		super();

		if (options == null)
			options = {};

		var labelWidth = options.labelWidth != null ? options.labelWidth : LabelWidth.auto;
		label = new Label(options.labelText != null ? options.labelText : "Label:", labelWidth, WrapMode.None);

		input = new Input(options.inputWidth);
		if (options.placeholder != null) {
			input.placeholder = options.placeholder;
		}
		if (options.maxLength != null) {
			input.maxLength = options.maxLength;
		}

		add(label);
		add(input);
	}

	function get_text():String {
		return input.text;
	}

	function set_text(value:String):String {
		return input.text = value;
	}

	function get_placeholder():String {
		return input.placeholder;
	}

	function set_placeholder(value:String):String {
		return input.placeholder = value;
	}

	function get_maxLength():Int {
		return input.maxLength;
	}

	function set_maxLength(value:Int):Int {
		return input.maxLength = value;
	}

	function get_onChange():InputHandler {
		return input.onChange;
	}

	function set_onChange(value:InputHandler):InputHandler {
		return input.onChange = value;
	}

	function get_onSubmit():InputHandler {
		return input.onSubmit;
	}

	function set_onSubmit(value:InputHandler):InputHandler {
		return input.onSubmit = value;
	}

	function get_labelText():String {
		return label.text;
	}

	function set_labelText(value:String):String {
		return label.text = value;
	}

	function get_background():Color {
		return input.background;
	}

	function set_background(value:Color):Color {
		input.background = value;
		label.background = value;

		return value;
	}

	function get_foreground():Color {
		return input.foreground;
	}

	function set_foreground(value:Color):Color {
		return input.foreground = value;
	}

	override public function isFocusable():Bool {
		return input.isFocusable();
	}

	override public function onFocus():Void {
		input.onFocus();
	}

	override public function onBlur():Void {
		input.onBlur();
	}
}
