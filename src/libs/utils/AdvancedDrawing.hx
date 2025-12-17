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
}
