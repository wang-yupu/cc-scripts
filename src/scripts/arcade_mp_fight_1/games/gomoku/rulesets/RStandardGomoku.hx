package arcade_mp_fight_1.games.gomoku.rulesets;

import cc_basics.Logger;
import arcade_mp_fight_1.games.gomoku.PlayDrawing.Checkerboard;
import utils.CMath;
import arcade_mp_fight_1.games.gomoku.rulesets.IGomokuRuleset;

class RStandardGomoku implements IGomokuRuleset {
	public function new() {}

	private var cb:Checkerboard;

	public function init(checkerboard:Checkerboard) {
		this.cb = checkerboard;
	}

	private final directions:Array<Vec2i> = [{x: 1, y: 0}, {x: 0, y: 1}, {x: 1, y: -1}, {x: 1, y: 1}];

	public function check(player:Bool, start:Vec2i):Bool {
		if (this.cb.get(start) != player) {
			Logger.info("[Standard Gomoku] Checker failed :: unexpected start data");
			return false;
		}

		var count:Int = 0;
		for (dir in directions) {
			count = 1;

			// +
			var i:Int = 1;
			while (this.cb.get({x: start.x + i * dir.x, y: start.y + i * dir.y}) == player) {
				count++;
				i++;
			}
			// -
			var i:Int = 1;
			while (this.cb.get({x: start.x - i * dir.x, y: start.y - i * dir.y}) == player) {
				count++;
				i++;
			}

			if (count == 5) {
				return true;
			}
		}
		return false;
	}

	private var current:Bool = true;

	public function step(choice:PlayerChoice):NextAction {
		if (choice == null) {
			return {
				player: true,
				action: Place(true),
			};
		}
		switch (choice.result) {
			case Place(pos):
				this.cb.set(pos, current);
				if (this.check(current, pos)) {
					Logger.info("[Standard Gomoku] Win! Winner: " + current);
					return {
						player: current,
						action: Win("")
					};
				}
			case MakeChoose(index):
				null;
		}
		this.current = !current;
		return {
			player: current,
			action: Place(current),
		};
	}

	public function canPlace(pos:Vec2i):Bool {
		return this.cb.get(pos) == null;
	}
}
