package utils;

import cc_basics.Enums;
import utils.CMath;
import sgui.core.FrameBuffer;

enum Direction {
	Up;
	Down;
	Left;
	Right;
}

class AdvancedDrawing {
	public static function drawSimpleTriangle(fbuf:FrameBuffer, vertex:Vec2i, b:Int, h:Int, dir:Direction, char:String, fg:Color, bg:Color) {
		var halfBase:Float = b / 2.0;
		var cx = vertex.x;
		var cy = vertex.y;

		inline function transform(x:Int, y:Int):Vec2i {
			return switch (dir) {
				case Up:
					{x: x, y: y};

				case Down:
					{x: 2 * cx - x, y: 2 * cy - y};

				case Right:
					{x: cx - (y - cy), y: cy + (x - cx)};

				case Left:
					{x: cx + (y - cy), y: cy - (x - cx)};
			}
		}

		for (i in 0...h + 1) {
			var y = vertex.y + i;
			var half = (i * halfBase) / h;

			var xStart = Math.ceil(vertex.x - half);
			var xEnd = Math.floor(vertex.x + half);

			for (x in xStart...xEnd + 1) {
				var p = transform(x, y);
				fbuf.setCell(p.x, p.y, char, fg, bg);
			}
		}
	}

	public static function alignedText(fbuf:FrameBuffer, y:Int, align:Float, text:String, fg:Color = null, bg:Color = null) {
		fbuf.writeText(Math.floor((fbuf.width - text.length) * align), y, text, fg, bg);
	}

	public static function alignedTextWithX(fbuf:FrameBuffer, pos:Vec2i, w:Int, align:Float, text:String, fg:Color = null, bg:Color = null) {
		fbuf.writeText(pos.x + Math.floor((w - text.length) * align), pos.y, text, fg, bg);
	}

	public static function drawLine(fbuf:FrameBuffer, p1:Vec2i, p2:Vec2i, char:String, fg:Color, bg:Color) {
		var x1 = p1.x;
		var y1 = p1.y;
		var x2 = p2.x;
		var y2 = p2.y;

		var dx = Math.abs(x2 - x1);
		var dy = Math.abs(y2 - y1);
		var sx = if (x1 < x2) 1 else -1;
		var sy = if (y1 < y2) 1 else -1;
		var err = dx - dy;

		while (true) {
			fbuf.setCell(x1, y1, char, fg, bg);
			if (x1 == x2 && y1 == y2)
				break;
			var e2 = err * 2;
			if (e2 > -dy) {
				err -= dy;
				x1 += sx;
			}
			if (e2 < dx) {
				err += dx;
				y1 += sy;
			}
		}
	}

	public static function drawCircle(fbuf:FrameBuffer, center:Vec2i, r:Int, char:String, fg:Color, bg:Color) {
		var cx = center.x;
		var cy = center.y;
		var x = 0;
		var y = r;
		var d = 3 - 2 * r;

		while (x <= y) {
			// 利用对称性设置圆周上的点
			fbuf.setCell(cx + x, cy + y, char, fg, bg);
			fbuf.setCell(cx - x, cy + y, char, fg, bg);
			fbuf.setCell(cx + x, cy - y, char, fg, bg);
			fbuf.setCell(cx - x, cy - y, char, fg, bg);
			fbuf.setCell(cx + y, cy + x, char, fg, bg);
			fbuf.setCell(cx - y, cy + x, char, fg, bg);
			fbuf.setCell(cx + y, cy - x, char, fg, bg);
			fbuf.setCell(cx - y, cy - x, char, fg, bg);

			if (d < 0) {
				d += 4 * x + 6;
			} else {
				d += 4 * (x - y) + 10;
				y--;
			}
			x++;
		}
	}
}
