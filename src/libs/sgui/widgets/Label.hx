package sgui.widgets;

import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import sgui.core.Widget;

enum LabelAlign {
	LEFT;
	CENTER;
	RIGHT;
}

enum LabelWidth {
	fixed(width:Int);
	block;
	auto;
}

enum WrapMode {
	None;
	Space;
	Char;
}

class Label extends Widget {
	public var text(default, set):String;
	public var foreground:Color = Color.WHITE;
	public var background:Color = Color.BLACK;
	public var align:LabelAlign = LabelAlign.LEFT;
	public var ellipsis:Bool = false;
	public var labelWidth(default, set):LabelWidth;
	public var wrapMode(default, set):WrapMode;

	// 缓存相关
	private var _wrappedLines:Array<String> = null;
	private var _cacheValid:Bool = false;
	private var _lastActualWidth:Int = -1;  // 用于检测宽度变化

	public function new(text:String = "", labelWidth:LabelWidth = auto, wrapMode:WrapMode = None) {
		super(null, null);  // 宽度和高度都自动计算
		this.text = text;
		this.labelWidth = labelWidth;
		this.wrapMode = wrapMode;
	}

	override public function getActualWidth():Int {
		return switch (labelWidth) {
			case fixed(w): w;
			case block: parent != null ? parent.getActualWidth() : 0;
			case auto: text != null ? text.length : 0;
		};
	}

	override public function getActualHeight():Int {
		// Label的高度总是根据换行后的文本行数自动计算
		var lines = wrapText();
		return Std.int(Math.max(1, lines.length));
	}

	private function invalidateCache():Void {
		_cacheValid = false;
		_wrappedLines = null;
		requestLayout();
		requestRender();
	}

	function set_text(value:String):String {
		if (text != value) {
			text = value;
			invalidateCache();
		}
		return text;
	}

	function set_labelWidth(value:LabelWidth):LabelWidth {
		if (labelWidth != value) {
			labelWidth = value;
			invalidateCache();
		}
		return labelWidth;
	}

	function set_wrapMode(value:WrapMode):WrapMode {
		if (wrapMode != value) {
			wrapMode = value;
			invalidateCache();
		}
		return wrapMode;
	}

	private function wrapText():Array<String> {
		// 检查宽度是否变化
		var currentWidth = getActualWidth();
		if (currentWidth != _lastActualWidth) {
			_lastActualWidth = currentWidth;
			invalidateCache();
		}

		// 检查缓存
		if (_cacheValid && _wrappedLines != null) {
			return _wrappedLines;
		}

		// 计算换行结果
		_wrappedLines = computeWrappedLines();
		_cacheValid = true;
		return _wrappedLines;
	}

	private function computeWrappedLines():Array<String> {
		if (text == null || text.length == 0) {
			return [""];
		}

		// 首先按换行符分割文本
		var inputLines = text.split("\n");
		if (wrapMode == None) {
			return inputLines;
		}

		var actualWidth = getActualWidth();
		if (actualWidth <= 0) {
			return inputLines;
		}

		var resultLines:Array<String> = [];
		
		// 对每一行进行换行处理
		for (inputLine in inputLines) {
			if (inputLine.length <= actualWidth) {
				resultLines.push(inputLine);
				continue;
			}
			
			// 需要换行的长行
			var currentText = inputLine;
			
			while (currentText.length > 0) {
				if (currentText.length <= actualWidth) {
					resultLines.push(currentText);
					break;
				}

				switch (wrapMode) {
					case Space:
						// 按空格换行：在actualWidth范围内找最后一个空格
						var lastSpace = -1;
						for (i in 0...Std.int(Math.min(actualWidth, currentText.length))) {
							if (currentText.charAt(i) == " ") {
								lastSpace = i;
							}
						}
						if (lastSpace > 0) {
							// 找到空格，在空格处断行
							resultLines.push(currentText.substr(0, lastSpace));
							currentText = currentText.substr(lastSpace + 1); // 跳过空格
						} else {
							// 没有空格，按字符强制断行
							resultLines.push(currentText.substr(0, actualWidth));
							currentText = currentText.substr(actualWidth);
						}

					case Char:
						// 按字符换行
						resultLines.push(currentText.substr(0, actualWidth));
						currentText = currentText.substr(actualWidth);

					case None:
						// 不应该到这里
						resultLines.push(currentText);
						break;
				}
			}
		}

		return resultLines.length > 0 ? resultLines : [""];
	}

	override public function render(buffer:FrameBuffer):Void {
		if (!visible) {
			return;
		}

		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		var gx = getGlobalX();
		var gy = getGlobalY();

		if (actualWidth <= 0 || actualHeight <= 0) {
			return;
		}

		// 获取分行后的文本
		var lines = wrapText();

		// 填充背景
		buffer.fillRect(gx, gy, actualWidth, actualHeight, " ", foreground, background);

		// 渲染每一行
		for (lineIdx in 0...Std.int(Math.min(lines.length, actualHeight))) {
			var line = lines[lineIdx];
			if (line == null || line.length == 0) {
				continue;
			}

			var renderWidth = actualWidth;
			var actual = line;

			// 处理ellipsis（省略号）- 只在最后一行且文本被截断时显示
			if (ellipsis && lineIdx == actualHeight - 1 && lineIdx < lines.length - 1) {
				// 这是最后一行但还有更多文本
				if (renderWidth >= 3) {
					actual = actual.substr(0, renderWidth - 3) + "...";
				} else {
					actual = actual.substr(0, renderWidth);
				}
			} else if (actual.length > renderWidth) {
				actual = actual.substr(0, renderWidth);
			}

			// 计算对齐偏移
			var offset = 0;
			switch (align) {
				case LEFT:
					offset = 0;
				case CENTER:
					offset = Std.int((renderWidth - actual.length) / 2);
				case RIGHT:
					offset = renderWidth - actual.length;
			}
			if (offset < 0) {
				offset = 0;
			}

			// 渲染这一行
			var lineY = gy + lineIdx;
			buffer.writeText(gx + offset, lineY, actual, foreground, background);
		}
	}
}
