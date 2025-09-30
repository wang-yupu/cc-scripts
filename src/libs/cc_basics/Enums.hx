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

enum Color {
	WHITE;
	ORANGE;
	MAGENTA;
	LIGHT_BLUE;
	YELLOW;
	LIME;
	PINK;
	GRAY;
	LIGHT_GRAY;
	CYAN;
	PURPLE;
	BLUE;
	BROWN;
	GREEN;
	RED;
	BLACK;
}

function asBlitColor(color:Color):String {
	var v:Int = Type.enumIndex(color);
	return StringTools.hex(v);
}

function asCCColor(color:Color):Int {
	var v:Int = Type.enumIndex(color);
	return 1 << v;
}

function parseCCColor(r:Int):Color {
	var msb = Std.int(Math.log(r) / Math.log(2));
	return Color.createByIndex(msb);
}

final revertColor:Map<Color, Color> = [
	WHITE => BLACK,
	ORANGE => BLUE,
	MAGENTA => LIME,
	LIGHT_BLUE => RED,
	YELLOW => PURPLE,
	LIME => MAGENTA,
	PINK => GRAY,
	GRAY => PINK,
	LIGHT_GRAY => CYAN,
	CYAN => LIGHT_GRAY,
	PURPLE => YELLOW,
	BLUE => ORANGE,
	BROWN => GREEN,
	GREEN => BROWN,
	RED => LIGHT_BLUE,
	BLACK => WHITE
];
