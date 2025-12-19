package arcade_mp_fight_1.games.gomoku.rulesets;

import arcade_mp_fight_1.games.gomoku.GGomoku.GomokuRuleset;

function getRuleset(e:GomokuRuleset):IGomokuRuleset {
	return switch (e) {
		default:
			return new RStandardGomoku();
	}
}
