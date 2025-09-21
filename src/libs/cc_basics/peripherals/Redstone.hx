package cc_basics.peripherals;

import haxe.extern.EitherType;
import cc_basics.Side.getSideName;

@:native("redstone")
private extern class CC_redstone {
	static function setAnalogOutput(side:String, state:Int):Void;
	static function getAnalogOutput(side:String):Int;
	static function getAnalogInput(side:String):Int;
}

enum RedstoneMachine {
	local(side:cc_basics.Side.Side);
	relay(side:cc_basics.Side.Side, id:String);
}

class RedstonePin extends Peripheral {
	private var machine:RedstoneMachine;

	public function new(machineOrSide:EitherType<RedstoneMachine, Side>, state:Bool = false) {
		var machine:RedstoneMachine;
		if (Std.isOfType(machineOrSide, Side)) {
			machine = RedstoneMachine.local(machineOrSide);
		} else {
			machine = machineOrSide;
		}
		this.machine = machine;
		switch (machine) {
			case local(side):
				super("");

			case relay(side, id):
				super(id);
		}
		this.set(state);
	}

	public function set(state:EitherType<Int, Bool>) {
		if (Std.isOfType(state, Bool)) {
			state = if (state) 15 else 0;
		}
		switch (machine) {
			case local(side):
				CC_redstone.setAnalogOutput(getSideName(side), state);
			case relay(side, id):
				this.call("setAnalogOutput", getSideName(side), state);
		}
	}

	public function read():Bool {
		switch (machine) {
			case local(side):
				return CC_redstone.getAnalogInput(getSideName(side)) != 0;
			case relay(side, _):
				return this.call("getAnalogInput", getSideName(side)) != 0;
		}
	}

	public function readAnalog():Int {
		switch (machine) {
			case local(side):
				return CC_redstone.getAnalogInput(getSideName(side));
			case relay(side, _):
				return this.call("getAnalogInput", getSideName(side));
		}
	}

	public function getOutput():Bool {
		switch (machine) {
			case local(side):
				return CC_redstone.getAnalogOutput(getSideName(side)) != 0;
			case relay(side, _):
				return this.call("getAnalogOutput", getSideName(side)) != 0;
		}
	}

	public function pulse(time:Float = 0.1, force = false, reverse:Bool = false, waitAfterPulse:Bool = true):Void {
		if (this.getOutput() && !reverse && !force) {
			return;
		}
		this.set(!reverse);
		Base.sleep(time);
		this.set(reverse);
		if (waitAfterPulse) {
			Base.sleep(time);
		}
	}
}
