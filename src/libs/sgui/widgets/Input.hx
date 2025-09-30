package sgui.widgets;

import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import sgui.core.Keys;
import sgui.core.Widget;

typedef InputHandler = String->Void;

class Input extends Widget {
	public var text(get, set):String;
	public var maxLength:Int = 128;
	public var placeholder:String = "";
	public var background:Color = Color.BLACK;
	public var foreground:Color = Color.WHITE;
	public var placeholderColor:Color = Color.GRAY;
	public var cursorColor:Color = Color.YELLOW;
	public var onChange:InputHandler;
	public var onSubmit:InputHandler;

	private var buffer:String;
	private var cursorPos:Int = 0;
	private var viewOffset:Int = 0;
	private var focused:Bool = false;

	public function new(width:Int = 12) {
		super(width, 1);
		buffer = "";
	}

	private function get_text():String {
		return buffer;
	}

	private function set_text(value:String):String {
		if (value == null) {
			value = "";
		}
		if (value != buffer) {
			buffer = value;
			cursorPos = buffer.length;
			ensureCursorVisible();
			requestRender();
			if (onChange != null) {
				onChange(buffer);
			}
		}
		return buffer;
	}

	override public function isFocusable():Bool {
		return true;
	}

	override public function onFocus():Void {
		focused = true;

		requestRender();
	}

	override public function onBlur():Void {
		focused = false;
		requestRender();
	}

	override public function render(fbuf:FrameBuffer):Void {
		var gx = getGlobalX();
		var gy = getGlobalY();
		var drawColor = foreground;
		var content = buffer;
		if (content.length == 0 && !focused && placeholder.length > 0) {
			content = placeholder;
			drawColor = placeholderColor;
		}
		fbuf.fillRect(gx, gy, width, height, " ", drawColor, background);
		var visible = content;
		if (viewOffset > 0) {
			visible = content.substr(viewOffset);
		}
		if (visible.length > width) {
			visible = visible.substr(0, width);
		}
		fbuf.writeText(gx, gy, visible, drawColor, background);
		if (focused && width > 0) {
			var caretX = cursorPos - viewOffset;
			if (caretX < 0) {
				caretX = 0;
			} else if (caretX >= width) {
				caretX = width - 1;
			}
			// fbuf.setCell(gx + caretX, gy, "_", cursorColor, background);
			fbuf.setCursorPosition(gx + caretX, gy);
			fbuf.setCursorBlink(true);
		} else {
			fbuf.setCursorBlink(false);
		}
	}

	override public function handleCharInput(ch:String):Bool {
		if (!focused) {
			return false;
		}
		if (ch == null || ch.length == 0) {
			return false;
		}
		if (buffer.length >= maxLength) {
			return false;
		}
		var left = buffer.substr(0, cursorPos);
		var right = buffer.substr(cursorPos);
		buffer = left + ch + right;
		cursorPos += ch.length;
		ensureCursorVisible();
		requestRender();
		if (onChange != null) {
			onChange(buffer);
		}
		return true;
	}

	override public function handlePaste(content:String):Bool {
		if (!focused) {
			return false;
		}
		if (content == null || content.length == 0) {
			return false;
		}
		if (buffer.length >= maxLength) {
			return false;
		}
		var spaceAvailable = maxLength - buffer.length;
		var left = buffer.substr(0, cursorPos);
		var right = buffer.substr(cursorPos);
		content = content.substr(0, spaceAvailable);
		buffer = left + content + right;
		cursorPos += content.length;
		ensureCursorVisible();
		requestRender();
		if (onChange != null) {
			onChange(buffer);
		}
		return true;
	}

	override public function handleKeyInput(keyCode:Int):Bool {
		if (!focused) {
			return false;
		}

		var key = resolveKey(keyCode);

		switch (key) {
			case Keys.backspace:
				if (cursorPos > 0 && buffer.length > 0) {
					buffer = buffer.substr(0, cursorPos - 1) + buffer.substr(cursorPos);
					cursorPos--;
					if (cursorPos < 0) {
						cursorPos = 0;
					}
					ensureCursorVisible();
					requestRender();
					if (onChange != null) {
						onChange(buffer);
					}
				}
				return true;
			case Keys.delete:
				if (cursorPos < buffer.length && buffer.length > 0) {
					buffer = buffer.substr(0, cursorPos) + buffer.substr(cursorPos + 1);
					ensureCursorVisible();
					requestRender();
					if (onChange != null) {
						onChange(buffer);
					}
				}
				return true;
			case Keys.left:
				if (cursorPos > 0) {
					cursorPos--;
					ensureCursorVisible();
					requestRender();
				}
				return true;
			case Keys.right:
				if (cursorPos < buffer.length) {
					cursorPos++;
					ensureCursorVisible();
					requestRender();
				}
				return true;
			case Keys.home:
				cursorPos = 0;
				ensureCursorVisible();
				requestRender();
				return true;
			case Keys.end:
				cursorPos = buffer.length;
				ensureCursorVisible();
				requestRender();
				return true;
			case Keys.enter:
				if (onSubmit != null) {
					onSubmit(buffer);
				}
				return true;
			case _:
		}
		return false;
	}

	private function ensureCursorVisible():Void {
		if (cursorPos < viewOffset) {
			viewOffset = cursorPos;
			return;
		}
		var rightEdge = viewOffset + width - 1;
		if (cursorPos > rightEdge) {
			viewOffset = cursorPos - width + 1;
		}
		if (viewOffset < 0) {
			viewOffset = 0;
		}
	}
}
