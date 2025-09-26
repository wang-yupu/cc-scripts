package fmt;

import haxe.Constraints.Function;
import cc_basics.Base;

@:native("parallel")
private extern class CC_parallel {
	static function waitForAll(...funcs:Function):Void;
	static function waitForAny(...funcs:Function):Void;
}

class ThreadManager {
	private static final startFunctionsEventName:String = "fmt_start_functions";

	private static var funcQueue:Array<Function>;

	public function new(main:Function) {
		funcQueue = [];
		CC_parallel.waitForAny(main, loop);
	}

	public static function add(func:Function) {
		funcQueue.push(func);
	}

	public static function start() {
		Base.queueEvent(startFunctionsEventName);
	}

	private static function loop() {
		Base.pullEvent(startFunctionsEventName);
		var funcs = funcQueue.copy();
		funcs.push(loop);
		funcQueue = [];
		CC_parallel.waitForAll(...funcs);
	}
}
