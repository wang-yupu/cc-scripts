package utils;

typedef Vec2i = {x:Int, y:Int}

class VecUtils {
	public static function inside(start:Vec2i, size:Vec2i, point:Vec2i) {
		return point.x >= 0 && point.y >= 0 && start.x <= point.x && point.x <= start.x + size.x && start.y <= point.y && point.y <= start.y + size.y;
	}

	public static function add(a:Vec2i, b:Vec2i) {
		return {x: a.x + b.x, y: a.y + b.y};
	}

	public static function sub(a:Vec2i, b:Vec2i) {
		return {x: a.x - b.x, y: a.y - b.y};
	}
}
