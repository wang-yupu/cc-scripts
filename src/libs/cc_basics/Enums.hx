package cc_basics;

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

enum Side {
	TOP;
	BOTTOM;
	LEFT;
	RIGHT;
	FRONT;
	BACK;
}

function getSideName(side:Side) {
	return switch (side) {
		case TOP: 'top';
		case BOTTOM: 'bottom';
		case LEFT: 'left';
		case RIGHT: 'right';
		case FRONT: 'front';
		case BACK: 'back';
	}
}
