package cc_basics.peripherals;

import cc_basics.Enums;
import haxe.extern.EitherType;

class Speaker extends Peripheral {
	public function new(id:EitherType<Side, String>) {
		super(id);
	}

	public function playNote(instrument:Instrument = Instrument.pling, pitch:EitherType<Note, Int> = Note.C4, volume:Float = 1.0) {
		if (!this.isPresent()) {
			return;
		}
		var pitchr:Int = 0;
		if (Std.isOfType(pitch, Note)) {
			pitchr = Type.enumIndex(pitch);
		} else {
			pitchr = pitch;
		};
		this.call("playNote", Type.enumConstructor(instrument), volume, pitchr);
	}

	public function playSound(sound:String, pitch:EitherType<Note, Int> = Note.C4, volume:Float = 1.0) {
		if (!this.isPresent()) {
			return;
		}
		var pitchr:Int = 0;
		if (Std.isOfType(pitch, Note)) {
			pitchr = Type.enumIndex(pitch);
		} else {
			pitchr = pitch;
		};
		this.call("playSound", sound, volume, pitchr);
	}
}
