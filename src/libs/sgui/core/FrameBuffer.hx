package sgui.core;

import cc_basics.Enums.Color;
import cc_basics.Enums.asBlitColor;
import cc_basics.peripherals.Monitor;

class FrameBuffer {
	public var width(default, null):Int;
	public var height(default, null):Int;

	private var chars:Array<Array<String>>;
	private var fore:Array<Array<String>>;
	private var back:Array<Array<String>>;
	private var cursorBlinking:Bool = false;
	private var cursorPosX:Int = 0;
	private var cursorPosY:Int = 0;

	public function new(width:Int, height:Int) {
		chars = [];
		fore = [];
		back = [];
		resize(width, height);
	}

	public function resize(width:Int, height:Int):Void {
		if (width <= 0 || height <= 0) {
			throw 'Invalid framebuffer size ${width}x${height}';
		}
		if (width == this.width && height == this.height) {
			return;
		}
		this.width = width;
		this.height = height;
		chars = [];
		fore = [];
		back = [];
		for (y in 0...height) {
			var charRow = [];
			var fgRow = [];
			var bgRow = [];
			for (x in 0...width) {
				charRow.push(" ");
				fgRow.push("0");
				bgRow.push("f");
			}
			chars.push(charRow);
			fore.push(fgRow);
			back.push(bgRow);
		}
	}

	public function clear(?fg:Color, ?bg:Color, ?fillChar:String):Void {
		var fgCode = fg != null ? toBlitChar(fg) : null;
		var bgCode = bg != null ? toBlitChar(bg) : null;
		var cellChar = (fillChar != null && fillChar.length > 0) ? fillChar.substr(0, 1) : " ";
		for (y in 0...height) {
			var charRow = chars[y];
			var fgRow = fore[y];
			var bgRow = back[y];
			for (x in 0...width) {
				charRow[x] = cellChar;
				if (fgCode != null) {
					fgRow[x] = fgCode;
				}
				if (bgCode != null) {
					bgRow[x] = bgCode;
				}
			}
		}
	}

	public function fillRect(x:Int, y:Int, w:Int, h:Int, char:String, fg:Color, bg:Color):Void {
		if (w <= 0 || h <= 0) {
			return;
		}
		var ch = (char.length > 0) ? char.substr(0, 1) : " ";
		var fgCode = toBlitChar(fg);
		var bgCode = toBlitChar(bg);
		var x0:Int = Math.floor(Math.max(x, 0));
		var y0:Int = Math.floor(Math.max(y, 0));
		var x1:Int = Math.floor(Math.min(x + w, width));
		var y1:Int = Math.floor(Math.min(y + h, height));
		for (row in y0...y1) {
			var charRow = chars[row];
			var fgRow = fore[row];
			var bgRow = back[row];
			for (col in x0...x1) {
				charRow[col] = ch;
				fgRow[col] = fgCode;
				bgRow[col] = bgCode;
			}
		}
	}

	public inline function setCell(x:Int, y:Int, char:String, fg:Color, bg:Color):Void {
		if (!inside(x, y)) {
			return;
		}
		chars[y][x] = char != null && char.length > 0 ? char.substr(0, 1) : " ";
		fore[y][x] = toBlitChar(fg);
		back[y][x] = toBlitChar(bg);
	}

	public function writeText(x:Int, y:Int, text:String, fg:Color = null, bg:Color = null):Void {
		if (text == null || text.length == 0) {
			return;
		}
		if (y < 0 || y >= height) {
			return;
		}
		var fgCode = fg == null ? null : toBlitChar(fg);
		var bgCode = bg == null ? null : toBlitChar(bg);
		var cursor = x;
		for (i in 0...text.length) {
			if (cursor >= width) {
				break;
			}
			if (cursor >= 0) {
				chars[y][cursor] = text.substr(i, 1);
				if (fgCode != null)
					fore[y][cursor] = fgCode;

				if (bgCode != null)
					back[y][cursor] = bgCode;
			}
			cursor++;
		}
	}

	public function setCursorBlink(blink:Bool) {
		this.cursorBlinking = blink;
	}

	public function setCursorPosition(x:Int, y:Int) {
		this.cursorPosX = x;
		this.cursorPosY = y;
	}

	public function syncToMonitor(monitor:Monitor):Void {
		for (row in 0...height) {
			monitor.setCursorPosition(0, row);
			monitor.blit(rowToString(chars[row]), rowToString(fore[row]), rowToString(back[row]));
		}
		monitor.setCursorBlink(this.cursorBlinking);
		monitor.setCursorPosition(this.cursorPosX, this.cursorPosY);
	}

	public function clone():FrameBuffer {
		var copy = new FrameBuffer(width, height);
		for (row in 0...height) {
			for (col in 0...width) {
				copy.chars[row][col] = chars[row][col];
				copy.fore[row][col] = fore[row][col];
				copy.back[row][col] = back[row][col];
			}
		}
		return copy;
	}

	public function compose(subbuf:FrameBuffer, sx:Int, sy:Int, wmax:Int = -1, hmax:Int = -1):Void {
		var widthToCopy:Int = (wmax == -1) ? subbuf.width : Math.floor(Math.min(wmax, subbuf.width));
		var heightToCopy:Int = (hmax == -1) ? subbuf.height : Math.floor(Math.min(hmax, subbuf.height));

		for (y in 0...heightToCopy) {
			var targetY = sy + y;
			if (targetY >= height) {
				break;
			}

			for (x in 0...widthToCopy) {
				var targetX = sx + x;
				if (targetX >= width) {
					break;
				}

				chars[targetY][targetX] = subbuf.chars[y][x];
				fore[targetY][targetX] = subbuf.fore[y][x];
				back[targetY][targetX] = subbuf.back[y][x];
			}
		}
	}

	private inline function inside(x:Int, y:Int):Bool {
		return x >= 0 && x < width && y >= 0 && y < height;
	}

	private inline function toBlitChar(color:Color):String {
		return asBlitColor(color).toLowerCase();
	}

	private inline function rowToString(row:Array<String>):String {
		var sb = new StringBuf();
		for (ch in row) {
			sb.add(ch);
		}
		return sb.toString();
	}
}
