package fmt;

import haxe.extern.EitherType;
import haxe.Rest;
import haxe.Constraints.Function;
import cc_basics.Base;
import fmt.Manager;

private typedef EventHandlerCallback = (String, Rest<Dynamic>) -> Void;

class EventHandler {
	private static var unregisterdHandlers:Array<EventHandler> = [];

	private var callback:EventHandlerCallback;
	private var events:Array<String>;
	private var deactivated:Bool = false;

	public function new(callback:EventHandlerCallback, ...events:String) {
		this.callback = callback;
		this.events = events;
		unregisterdHandlers.push(this);
	}

	private function loop() {
		var r:Array<Dynamic>;
		while (!this.deactivated) {
			r = Base.pullEvent();
			if (this.deactivated) {
				break;
			}
			if (this.events.contains(r[0])) {
				this.callback(r.shift(), ...r);
			}
		}
	}

	public function remove() {
		this.deactivated = true;
	}

	public static function registerAll() {
		for (handler in unregisterdHandlers) {
			ThreadManager.add(handler.loop);
		}
		ThreadManager.start();
	}
}
