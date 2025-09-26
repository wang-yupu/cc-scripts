package clock;

import cc_basics.Enums;
import cc_basics.peripherals.Redstone.RedstoneMachine;
import cc_basics.peripherals.Redstone.RedstonePin;
import cc_basics.Base;

class Main {
	static inline function main() {
		var time, hour, min, hour1, hour2, min1, min2;
		var hour1Redstone = new RedstonePin(RedstoneMachine.relay(Side.BACK, "redstone_relay_0"));
		var hour2Redstone = new RedstonePin(RedstoneMachine.relay(Side.RIGHT, "redstone_relay_0"));
		var min1Redstone = new RedstonePin(RedstoneMachine.relay(Side.BACK, "redstone_relay_2"));
		var min2Redstone = new RedstonePin(RedstoneMachine.relay(Side.RIGHT, "redstone_relay_2"));
		while (true) {
			time = Base.time();
			hour = Math.floor(time);
			min = Math.floor((time * 1000) % 1000);
			min = Math.floor(min / 1000 * 60);

			hour2 = hour % 10;
			min2 = min % 10;
			hour1 = Math.floor(hour / 10) % 10;
			min1 = Math.floor(min / 10) % 10;

			hour1Redstone.set(hour1);
			hour2Redstone.set(hour2);
			min1Redstone.set(min1);
			min2Redstone.set(min2);
			Base.sleep0();

			Base.print("updating", time, " @ ", hour, ":", min, " @ ", hour1, hour2, min1, min2);
		}
	}
}
