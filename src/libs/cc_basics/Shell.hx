package cc_basics;

@:native("shell")
private extern class CC_shell {
	public static function execute(command:String, ...args:String):Bool;
	public static function openTab(...args:String):Int;
	public static function switchTab(id:Int):Void;
	public static function exit():Void;
}

class Shell {
	public static function execute(command:String, ...args:String) {
		CC_shell.execute(command, ...args);
	}

	public static function openTab(...args:String):Int {
		return CC_shell.openTab(...args);
	}

	public static function switchTab(id:Int) {
		CC_shell.switchTab(id);
	}

	public static function exit() {
		CC_shell.exit();
	}
}
