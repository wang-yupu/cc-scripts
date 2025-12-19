package arcade_mp_fight_1;

import cc_basics.Logger;
import cc_basics.peripherals.Redstone.RedstoneMachine;
import cc_basics.peripherals.Redstone.RedstonePin;

enum Key {
	Up;
	Down;
	Left;
	Right;
	A;
	B;
}

enum KeyState {
	NotPressed;
	Rasing;
	Pressed;
	Falling;
}

class Player {
	public var currentStates:Int = 0x0;
	public var oldStates:Int = 0x0;

	public function new() {}

	public function isPress(key:Key):Bool {
		return (this.currentStates & 1 << key.getIndex()) >= 1;
	}

	public function keyState(key:Key):KeyState {
		var mask:Int = 1 << key.getIndex();
		if (this.currentStates & mask >= 1) {
			if (this.oldStates & mask >= 1) {
				return KeyState.Pressed;
			}
			return KeyState.Rasing;
		}
		if (this.oldStates & mask >= 1) {
			return KeyState.Falling;
		}
		return KeyState.NotPressed;
	}

	public function update(inputs:Array<RedstonePin>) {
		var mask:Int = 1;
		this.oldStates = this.currentStates;
		this.currentStates = 0;
		for (input in inputs) {
			if (input.read()) {
				this.currentStates |= mask;
			}

			mask *= 2;
		}
	}
}

typedef InputSource = {
	Up:RedstoneMachine,
	Down:RedstoneMachine,
	Left:RedstoneMachine,
	Right:RedstoneMachine,
	A:RedstoneMachine,
	B:RedstoneMachine
}

class InputManager {
	public var P1:Player;
	public var P2:Player;

	private var P1Input:Array<RedstonePin> = [];
	private var P2Input:Array<RedstonePin> = [];

	public function new(p1:InputSource, p2:InputSource) {
		P1Input.push(new RedstonePin(p1.Up));
		P1Input.push(new RedstonePin(p1.Down));
		P1Input.push(new RedstonePin(p1.Left));
		P1Input.push(new RedstonePin(p1.Right));
		P1Input.push(new RedstonePin(p1.A));
		P1Input.push(new RedstonePin(p1.B));

		P2Input.push(new RedstonePin(p2.Up));
		P2Input.push(new RedstonePin(p2.Down));
		P2Input.push(new RedstonePin(p2.Left));
		P2Input.push(new RedstonePin(p2.Right));
		P2Input.push(new RedstonePin(p2.A));
		P2Input.push(new RedstonePin(p2.B));

		this.P1 = new Player();
		this.P2 = new Player();

		Logger.info("[Input] OK");
	}

	public function update() {
		P1.update(P1Input);
		P2.update(P2Input);
	}
}
