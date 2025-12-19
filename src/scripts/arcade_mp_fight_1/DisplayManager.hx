package arcade_mp_fight_1;

import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import cc_basics.peripherals.Monitor;
import utils.CMath;

class DisplayManager {
	private final MONITOR_START:Vec2i = {x: 18, y: 12};
	private final MONITOR_SINGLE_BLOCK_SIZE:Vec2i = {x: 22, y: 14};
	private final BUFFER_SIZE:Vec2i;

	private var monitor:Monitor;

	private var outBuffer:FrameBuffer;
	private var buffer:FrameBuffer;

	public function new(monitor:Monitor) {
		this.monitor = monitor;

		this.BUFFER_SIZE = {x: MONITOR_SINGLE_BLOCK_SIZE.x * 3 - 2, y: MONITOR_SINGLE_BLOCK_SIZE.y * 3 + 1};
		this.buffer = new FrameBuffer(this.BUFFER_SIZE.x, this.BUFFER_SIZE.y);
		this.outBuffer = new FrameBuffer(this.monitor.getSize()[0], this.monitor.getSize()[1]);
		this.outBuffer.clear(null, Color.BLACK);
	}

	public function draw() {
		this.outBuffer.compose(this.buffer, this.MONITOR_START.x, this.MONITOR_START.y);
		this.outBuffer.syncToMonitor(this.monitor);
	}

	public function compose(buf:FrameBuffer) {
		if (buf == null) {
			return;
		}
		this.buffer.compose(buf, 0, 0);
	}

	public function displayText(text:String) {
		this.buffer.writeText(0, 0, text, Color.WHITE, Color.PURPLE);
	}

	public function getSize():Vec2i {
		return this.BUFFER_SIZE;
	}
}
