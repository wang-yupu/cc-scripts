package arcade_mp_fight_1;

import cc_basics.Enums;
import cc_basics.peripherals.Speaker;

class SoundManager {
	private var spk:Speaker;

	public function new(speaker:Speaker) {
		this.spk = speaker;
	}

	public function ring() {
		if (this.spk == null) {
			return;
		};
		this.spk.playNote(Instrument.bell, Note.D4, 2);
	}

	public function boom() {
		if (this.spk == null) {
			return;
		};
		this.spk.playSound("minecraft:entity.generic.explode", Note.C4, 2);
	}

	public function wrong() {
		if (this.spk == null) {
			return;
		};
		this.spk.playNote(Instrument.didgeridoo, Note.C4, 2);
	}

	public function uiFeedback() {
		if (this.spk == null) {
			return;
		};
		this.spk.playNote(Instrument.hat, Note.Gs4, 2);
	}
}
