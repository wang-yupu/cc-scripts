package arcade_mp_fight_1.games.gomoku.rulesets;

import arcade_mp_fight_1.games.gomoku.PlayDrawing.Checkerboard;
import utils.CMath.Vec2i;

enum PlayerAction {
	Place(c:Bool); // Black(T) || White(F)
	MakeChoose(choice:Array<String>);
	Win(s:String);
}

enum PlayerActionResult {
	Place(pos:Vec2i);
	MakeChoose(index:Int);
}

typedef NextAction = {
	player:Bool, // Black(T) || White(F)
	action:PlayerAction
}

typedef PlayerChoice = {
	player:Bool,
	result:PlayerActionResult
}

interface IGomokuRuleset {
	public function init(checkerboard:Checkerboard):Void;
	public function canPlace(pos:Vec2i):Bool; // Red(F) || Green(T)
	public function step(choice:PlayerChoice):NextAction;
}
