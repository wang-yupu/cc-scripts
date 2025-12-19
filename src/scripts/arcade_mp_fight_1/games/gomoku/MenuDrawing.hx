package arcade_mp_fight_1.games.gomoku;

import haxe.Exception;
import utils.AdvancedDrawing;
import arcade_mp_fight_1.InputManager;
import cc_basics.Enums;
import sgui.core.FrameBuffer;
import utils.CMath;
import arcade_mp_fight_1.games.IGame.GameContext;
import arcade_mp_fight_1.games.gomoku.GGomoku;

enum MenuResult {
	NOT_OK;
	OK(settings:GomokuSettings);
}

private final rulesetList:Array<{name:String, i:GomokuRuleset}> = [
	{name: "Standard", i: GomokuRuleset.Standard},
	{name: "Freestyle", i: GomokuRuleset.Freestyle},
	{name: "[WIP] Swap", i: GomokuRuleset.Standard},
	{name: "[WIP] Swap2", i: GomokuRuleset.Standard},
	{name: "[WIP] Gomoku Pro", i: GomokuRuleset.Standard},
	{name: "[WIP] Renju", i: GomokuRuleset.Standard},
];

private final checkerboardSizeList:Array<{name:String, i:CheckerboardSize}> = [
	{name: "15 * 15", i: CheckerboardSize.Size15},
	// {name: "13 * 13", i: CheckerboardSize.Size13},
	// {name: "19 * 19", i: CheckerboardSize.Size19},
];

private final spOrMpSelectList:Array<{name:String, i:Bool}> = [{name: "Multiplayer", i: false}, {name: "Singleplayer", i: true},];

class GomokuMenu {
	private var ctx:GameContext;

	public function new(ctx:GameContext) {
		this.ctx = ctx;
	}

	private var selected:Vec2i = {x: 0, y: 0};
	private var needRedrawing:Bool = true;

	private var sizeSelect:Int = 0;
	private var rulesetSelect:Int = 0;
	private var mpspSelect:Int = 0;

	public function update(fbuf:FrameBuffer):MenuResult {
		if (ctx.input.P1.keyState(Key.B) == KeyState.Falling) {}
		// 1. Input
		if (ctx.input.P1.keyState(Key.Up) == KeyState.Falling) {
			this.selected.y -= 1;
			this.needRedrawing = true;
			this.ctx.sound.uiFeedback();
		}
		if (ctx.input.P1.keyState(Key.Down) == KeyState.Falling) {
			this.selected.y += 1;
			this.needRedrawing = true;
			this.ctx.sound.uiFeedback();
		}

		if (ctx.input.P1.keyState(Key.Left) == KeyState.Falling) {
			this.selected.x -= 1;
			this.needRedrawing = true;
			this.ctx.sound.uiFeedback();
		}

		if (ctx.input.P1.keyState(Key.Right) == KeyState.Falling) {
			this.selected.x += 1;
			this.needRedrawing = true;
			this.ctx.sound.uiFeedback();
		}

		this.selected.x = Math.floor(Math.max(0, Math.min(2, this.selected.x)));
		this.selected.y = Math.floor(Math.max(0, Math.min(switch (this.selected.x) {
			case 0: checkerboardSizeList.length - 1;
			case 1: rulesetList.length - 1;
			case 2: spOrMpSelectList.length - 1;
			case _: 0;
		}, this.selected.y)));

		if (ctx.input.P1.keyState(Key.A) == KeyState.Falling) {
			switch (this.selected.x) {
				case 0:
					this.sizeSelect = this.selected.y;
				case 1:
					this.rulesetSelect = this.selected.y;
				case 2:
					this.mpspSelect = this.selected.y;
				case _:
					null;
			}
			this.ctx.sound.uiFeedback();
		}
		if (ctx.input.P1.keyState(Key.B) == KeyState.Falling) {
			if (this.rulesetSelect > 1) {
				throw new Exception("You choice a WIP ruleset!");
			}
			this.ctx.sound.ring();
			return OK({
				rule: rulesetList[this.rulesetSelect].i,
				size: checkerboardSizeList[this.sizeSelect].i,
				singlePlayer: spOrMpSelectList[this.mpspSelect].i
			});
		}

		// 2. Redraw
		if (this.needRedrawing) {
			fbuf.clear(Color.WHITE, Color.GRAY);
			// 0. Decoration
			fbuf.writeText(3, 3, "GOMOKU :: Start new game", Color.YELLOW);
			fbuf.writeText(36, 3, "P1: [A] Select [B] Start", Color.LIGHT_GRAY);

			// 1. Checkerboard Size
			this.drawList(fbuf, "Checkerboard Size", checkerboardSizeList, {x: 3, y: 5}, this.selected.x == 0 ? this.selected.y : null, this.sizeSelect);

			// 2. Ruleset
			this.drawList(fbuf, "Ruleset", rulesetList, {x: 23, y: 5}, this.selected.x == 1 ? this.selected.y : null, this.rulesetSelect);

			// 3. MP / SP
			this.drawList(fbuf, "Player Count", spOrMpSelectList, {x: 42, y: 5}, this.selected.x == 2 ? this.selected.y : null, this.mpspSelect);
		}
		return NOT_OK;
	}

	private function drawList(fbuf:FrameBuffer, title:String, list:Array<{name:String, i:Dynamic}>, pos:Vec2i, select:Int = null, current:Int = null) {
		AdvancedDrawing.alignedTextWithX(fbuf, pos, 18, 0.5, title, Color.LIGHT_BLUE, select != null ? Color.LIGHT_GRAY : Color.GRAY);

		var index:Int = 0;
		for (i in list) {
			AdvancedDrawing.alignedTextWithX(fbuf, {x: pos.x, y: pos.y + 3 + 3 * index}, 18, 0.5, (current == index ? "[*] " : "") + i.name, Color.WHITE,
				select == index ? Color.LIME : current == index ? Color.CYAN : Color.GRAY);
			index++;
		}
	}
}
