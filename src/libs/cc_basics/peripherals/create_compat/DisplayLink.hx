package cc_basics.peripherals.create_compat;

import utils.CMath.Vec2i;

class DisplayLink extends Peripheral {
	public function write(s:String, update:Bool = true) {
		this.call("write", s);
		update ? this.update() : 0;
	}

	public function wpos(s:String, pos:Vec2i, update:Bool = true) {
		this.setCursorPos(pos);
		this.write(s, update);
	}

	public function setCursorPos(pos:Vec2i) {
		this.call("setCursorPos", pos.x, pos.y);
	}

	public function getCursorPos():Vec2i {
		var ret:Array<Int> = this.call("getCursorPos");
		return {x: ret[0], y: ret[1]};
	}

	public function clear(update:Bool = true) {
		this.call("clear");
		update ? this.update() : 0;
	}

	public function update() {
		this.call("update");
	}
}
