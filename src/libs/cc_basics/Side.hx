package cc_basics;

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
