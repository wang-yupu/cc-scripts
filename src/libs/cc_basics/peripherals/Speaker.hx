package cc_basics.peripherals;

import haxe.extern.EitherType;

enum Instrument {
	harp;
	basedrum;
	snare;
	hat;
	bass;
	flute;
	bell;
	guitar;
	chime;
	xylophone;
	iron_xylophone;
	cow_bell;
	didgeridoo;
	bit;
	banjo;
	pling;
}

enum Note {
	Fs3;
	G3;
	Gs3;
	A3;
	As3;
	B3;
	C4;
	Cs4;
	D4;
	Ds4;
	E4;
	F4;
	Fs4;
	G4;
	Gs4;
	A4;
	As4;
	B4;
	C5;
	Cs5;
	D5;
	Ds5;
	E5;
	F5;
	Fs5;
}

class Speaker extends Peripheral {
	public function new(id:EitherType<cc_basics.Side.Side, String>) {
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
