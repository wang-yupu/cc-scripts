package tube_router;

import cc_basics.peripherals.Redstone;
import cc_basics.Enums.Side;
import cc_basics.peripherals.Modem;
import cc_basics.Logger;

inline final CONTROL_MSG_CHANNEL = 11451;

class Main {
	private static var id:String = "";
	private static var rs:Map<String, RedstonePin> = ["1" => new RedstonePin(RedstoneMachine.relay(Side.TOP, "redstone_relay_0")),];

	public static function main() {
		var m:Modem = new Modem(Side.BOTTOM);
		var c:Channel = m.open(CONTROL_MSG_CHANNEL);

		Logger.info('Init Router Node with: ID `${id}`');

		while (true) {
			var msg:NetworkData = c.recv();
			var pl:String = StringTools.trim(Std.string(msg.payload));
			Logger.info('Recived: ${pl}');
			if (pl == "shutdown") {
				Logger.info("Shutdown all ports");
				shutdown();
			} else {
				if (StringTools.startsWith(pl, id)) {
					var t:String = pl.substr(id.length, 1);
					if (rs.exists(t)) {
						Logger.info('Switch to ${t}');
						shutdown();
						rs.get(t).set(true);
					} else {
						Logger.warning('Not exists: ${t}');
						shutdown();
					}
				} else {
					Logger.info("Shutdown all ports");
					shutdown();
				}
			}
		}
	}

	private static function shutdown() {
		for (v in rs.keyValueIterator()) {
			v.value.set(false);
		}
	}
}
