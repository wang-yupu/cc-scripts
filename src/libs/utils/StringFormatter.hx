package utils;

class StringFormatter {
	public static function secToString(secs:Int):String {
		var h:Int = Math.floor(secs / 3600);
		var m:Int = Math.floor((secs % 3600) / 60);
		var s:Int = secs % 60;
		return '${h}h${m}m${s}s';
	}
}
