package cc_basics;

import cc_basics.Enums;
import cc_basics.peripherals.Monitor;

enum LoggerTarget {
	local;
	monitor(p:Monitor);
	file;
	none;
}

class Logger {
	private static var target:LoggerTarget = LoggerTarget.local;
	public static var level:Int = 0;

	private static function log(foreground:Color, background:Color, ...args) {
		var str = new StringBuf();
		for (arg in args) {
			str.add(Std.string(arg));
		}
		switch (target) {
			case local:
				Base.print(str);

			case monitor(p):
				p.setForeground(foreground);
				p.setBackground(background);
				var mh:Int = p.getSize()[1];
				var cl:Int = p.getCursorPosition()[1];
				if (mh <= cl) {
					p.clear();
					p.setCursorPosition(0, 0);
				} else {
					p.setCursorPosition(0, cl);
				}
				if (p != null) {
					p.write(str.toString());
				}
				p.setBackgroundColor(Color.BLACK);

			case file:
				return;

			case none:
				return;
		}
	}

	public static function info(...args:Dynamic) {
		if (level < 21) {
			log(Color.WHITE, Color.BLACK, ...args);
		}
	}

	public static function debug(...args:Dynamic) {
		if (level < 11) {
			log(Color.CYAN, Color.BLACK, ...args);
		}
	}

	public static function warning(...args:Dynamic) {
		if (level < 31) {
			log(Color.YELLOW, Color.LIGHT_GRAY, ...args);
		}
	}

	public static function error(...args:Dynamic) {
		log(Color.RED, Color.WHITE, ...args);
	}

	public static function setTarget(tgt:LoggerTarget) {
		target = tgt;
	}
}
