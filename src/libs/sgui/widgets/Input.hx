package sgui.widgets;

import cc_basics.Logger;
import cc_basics.Enums.revertColor;
import sgui.events.Events.KeyEvent;
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

	private var selectStart:Int;
	private var selectEnd:Int;

	public function new(width:Null<Int> = null) {
		super(width, 1);
		buffer = "";
		this.clearSelect();
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
		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		var drawColor = foreground;
		var content = buffer;
		if (content.length == 0 && !focused && placeholder.length > 0) {
			content = placeholder;
			drawColor = placeholderColor;
		}
		fbuf.fillRect(gx, gy, actualWidth, actualHeight, " ", drawColor, background);

		var visible = content;
		if (viewOffset > 0) {
			visible = content.substr(viewOffset);
		}
		if (visible.length > actualWidth) {
			visible = visible.substr(0, actualWidth);
		}
		fbuf.writeText(gx, gy, visible, drawColor, background);
		if (this.selectEnd != 0) {
			var fgr = revertColor[drawColor];
			var bgr = revertColor[this.background];
			for (x in this.selectStart...this.selectEnd) {
				fbuf.setCell(gx + x, gy, visible.charAt(x), fgr, bgr);
			}
		}
		if (focused && actualWidth > 0) {
			var caretX = cursorPos - viewOffset;

			if (caretX < 0) {
				fbuf.setCursorBlink(false);
				return;
			} else if (caretX >= actualWidth) {
				fbuf.setCursorBlink(false);
				return;
			}

			fbuf.setCursorPosition(gx + caretX, gy);
			fbuf.setCursorBlink(true);
		}
	}

	override public function handleCharInput(ch:String):Bool {
		return this.handlePaste(ch);
	}

	override public inline function handlePaste(content:String):Bool {
		if (!focused) {
			return false;
		}
		if (content == null || content.length == 0) {
			return false;
		}
		var lastSelectStart = null;
		if (this.selectEnd != 0) {
			var left = buffer.substr(0, this.selectStart);
			var right = buffer.substr(this.selectEnd);
			this.buffer = left + right;
			lastSelectStart = this.selectStart;
			this.clearSelect();
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
		if (lastSelectStart != null) {
			this.cursorPos = lastSelectStart + 1;
		}
		return true;
	}

	override public inline function handleKeyInput(event:KeyEvent):Bool {
		if (!focused) {
			return false;
		}

		for (key in event.keys) {
			switch (key) {
				case Keys.backspace:
					if (this.selectEnd == 0 && cursorPos > 0 && buffer.length > 0) {
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
					} else {
						if (this.selectEnd != 0) {
							var left = buffer.substr(0, this.selectStart);
							var right = buffer.substr(this.selectEnd);
							this.buffer = left + right;
							this.cursorPos = this.selectStart;
							this.clearSelect();
							ensureCursorVisible();
							requestRender();
							if (onChange != null) {
								onChange(buffer);
							}
						}
					}
					return true;
				case Keys.delete:
					if (this.selectEnd == 0 && cursorPos < buffer.length && buffer.length > 0) {
						buffer = buffer.substr(0, cursorPos) + buffer.substr(cursorPos + 1);
						ensureCursorVisible();
						requestRender();
						if (onChange != null) {
							onChange(buffer);
						}
					} else {
						if (this.selectEnd != 0) {
							var left = buffer.substr(0, this.selectStart);
							var right = buffer.substr(this.selectEnd);
							this.buffer = left + right;
							this.cursorPos = this.selectStart;
							this.clearSelect();
							ensureCursorVisible();
							requestRender();
							if (onChange != null) {
								onChange(buffer);
							}
						}
					}
					return true;
				case Keys.left:
					if (cursorPos > 0) {
						var old = cursorPos;
						cursorPos--;
						if (event.shift) {
							if (selectStart == selectEnd) {
								selectStart = cursorPos;
								selectEnd = old;
							} else if (old == selectEnd) {
								if (cursorPos >= selectStart) {
									selectEnd = cursorPos;
								} else {
									selectEnd = selectStart;
									selectStart = cursorPos;
								}
							} else {
								selectStart = cursorPos;
							}
							if (selectStart > selectEnd) {
								var t = selectStart;
								selectStart = selectEnd;
								selectEnd = t;
							}
						} else {
							selectStart = selectEnd = cursorPos;
						}

						ensureCursorVisible();
						requestRender();
					}
					return true;
				case Keys.right:
					if (cursorPos < buffer.length) {
						var old = cursorPos;
						cursorPos++;

						if (event.shift) {
							if (selectStart == selectEnd) {
								selectStart = old;
								selectEnd = cursorPos;
							} else if (old == selectStart) {
								if (cursorPos <= selectEnd) {
									selectStart = cursorPos;
								} else {
									selectStart = selectEnd;
									selectEnd = cursorPos;
								}
							} else {
								selectEnd = cursorPos;
							}
							if (selectStart > selectEnd) {
								var t = selectStart;
								selectStart = selectEnd;
								selectEnd = t;
							}
						} else {
							selectStart = selectEnd = cursorPos;
						}

						ensureCursorVisible();
						requestRender();
					}
					return true;
				case Keys.home:
					cursorPos = 0;
					this.clearSelect();
					ensureCursorVisible();
					requestRender();
					return true;
				case Keys.end:
					cursorPos = buffer.length;
					this.clearSelect();
					ensureCursorVisible();
					requestRender();
					return true;
				case Keys.enter:
					if (onSubmit != null) {
						onSubmit(buffer);
					}
					this.clearSelect();
					return true;
				case Keys.a:
					if (event.ctrl) {
						this.selectStart = 0;
						this.selectEnd = this.buffer.length;
					}
				case _:
			}
		}
		return false;
	}

	private function ensureCursorVisible():Void {
		if (cursorPos < viewOffset) {
			viewOffset = cursorPos;
			return;
		}
		var actualWidth = getActualWidth();
		var rightEdge = viewOffset + actualWidth - 1;
		if (cursorPos > rightEdge) {
			viewOffset = cursorPos - actualWidth + 1;
		}
		if (viewOffset < 0) {
			viewOffset = 0;
		}
	}

	private function clearSelect() {
		this.selectStart = 0;
		this.selectEnd = 0;
	}
}
