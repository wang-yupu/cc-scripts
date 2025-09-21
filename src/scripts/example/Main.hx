package example;

import cc_basics.Base;
import cc_basics.Redstone;
import cc_basics.Side;

class Main {
	static function main() {
		Redstone.setAll(false);
		Base.print("set all sides to false");
		var Top = new RedstonePin(Side.TOP);
		Top.pulse();
		Base.print("Sending a pulse");
	}
}
