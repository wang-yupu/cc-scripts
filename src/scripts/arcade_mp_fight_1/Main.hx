package arcade_mp_fight_1;

import sgui.core.FrameBuffer;
import cc_basics.peripherals.Speaker;
import cc_basics.peripherals.Redstone.RedstoneMachine;
import cc_basics.peripherals.Redstone.RedstonePin;
import cc_basics.peripherals.GenericInventory;
import cc_basics.Base;
import cc_basics.peripherals.Monitor;
import cc_basics.Logger;
import cc_basics.Enums;

private enum CurrentGame {
	Menu;
}

class Main {
	public static function main() {
		new Main().run();
	}

	private var display:DisplayManager;
	private var input:InputManager;
	private var coinMan:CoinManager;
	private var sound:SoundManager;

	public function new() {
		var monitor:Monitor = new Monitor(MonitorTarget.remote("monitor_5"));
		monitor.setScale(0.5);
		this.display = new DisplayManager(monitor);

		this.input = new InputManager({
			Up: relay(Side.BACK, "redstone_relay_5"),
			Down: local(Side.RIGHT),
			Left: local(Side.LEFT),
			Right: relay(Side.TOP, "redstone_relay_3"),
			A: relay(Side.BACK, "redstone_relay_3"),
			B: relay(Side.RIGHT, "redstone_relay_3")
		}, {
			Up: relay(Side.TOP, "redstone_relay_6"),
			Down: relay(Side.FRONT, "redstone_relay_6"),
			Left: relay(Side.LEFT, "redstone_relay_4"),
			Right: relay(Side.TOP, "redstone_relay_4"),
			A: relay(Side.RIGHT, "redstone_relay_4"),
			B: relay(Side.BACK, "redstone_relay_4")
		},);

		this.coinMan = new CoinManager(new GenericInventory("minecraft:hopper_1"), new GenericInventory("ae2:interface_1"));
		this.coinMan.cheating = new RedstonePin(RedstoneMachine.relay(Side.BACK, "redstone_relay_8"));

		this.sound = new SoundManager(new Speaker("speaker_0"));

		var restartKey = new RedstonePin(RedstoneMachine.relay(Side.TOP, "redstone_relay_8"));
		this.lifecycle = new LifecycleManager(this.input, this.display.getSize(), this.coinMan, this.sound, restartKey);

		Logger.info('Init menu with size: ${this.display.getSize()}');
	}

	private var lifecycle:LifecycleManager;

	public function run() {
		while (true) {
			try {
				while (true) {
					loop();
					loop();
					loop();
					loop();
					loop();
					loop();
					this.lifecycle.update();
					Base.sleep0();
				}
			} catch (e:Dynamic) {
				var fbuf:FrameBuffer = new FrameBuffer(this.display.getSize().x, this.display.getSize().y);
				fbuf.clear(Color.WHITE, Color.BLUE);

				fbuf.writeText(5, 5, ":(");
				fbuf.writeText(5, 6, "Your device ran into a problem and needs to explode. ");
				fbuf.writeText(5, 7, "We're just wasting your time. We will restart device ");
				fbuf.writeText(5, 8, "after 114514 seconds.");
				fbuf.writeText(5, 10, 'Error: ${e} (0x114514)');
				this.display.compose(fbuf);
				this.display.draw();
				Base.sleep(20);
				this.lifecycle.restart();
			}
		}
	}

	public function loop() {
		this.input.update();

		if (this.lifecycle.currentRunning()) {
			this.display.compose(this.lifecycle.getCurrent().update());
		}

		this.display.draw();
	}
}
