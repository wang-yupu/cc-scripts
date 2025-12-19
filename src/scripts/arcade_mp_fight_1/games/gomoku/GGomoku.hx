package arcade_mp_fight_1.games.gomoku;

import arcade_mp_fight_1.games.gomoku.MenuDrawing.GomokuMenu;
import utils.AdvancedDrawing;
import cc_basics.Enums;
import arcade_mp_fight_1.InputManager;
import sgui.core.FrameBuffer;
import arcade_mp_fight_1.games.IGame;

private enum State {
	UNDEFINED;
	IntroCG;
	Menu;
	Playing(settings:GomokuSettings);
	Result(result:GomokuResult, s:String);
}

enum CheckerboardSize {
	Size13; // 13 x 13
	Size15; // 15 x 15
	Size19; // 19 x 19
}

enum GomokuRuleset {
	Freestyle;
	Standard;
}

typedef GomokuSettings = {
	size:CheckerboardSize,
	singlePlayer:Bool,
	rule:GomokuRuleset
}

typedef GomokuResult = {
	winner:Int,
	turns:Int
}

class GGomoku implements Game {
	private var fbuf:FrameBuffer;
	private var ctx:GameContext;

	public function new(ctx:GameContext) {
		this.fbuf = new FrameBuffer(ctx.fbufSize.x, ctx.fbufSize.y);
		this.ctx = ctx;
	}

	private var state:State = State.UNDEFINED;

	private var frameNum:Int = 0;
	private var introCGFnum:Int = 0;

	private var menu:GomokuMenu = null;
	private var playdraw:PlayDrawing = null;

	private inline function sm() {
		switch (this.state) {
			case IntroCG:
				if (this.introCGFnum < 74) {
					this.fbuf.fillRect(this.introCGFnum, 0, 1, this.ctx.fbufSize.y, " ", Color.WHITE, Color.ORANGE);
					this.fbuf.fillRect(this.introCGFnum - 10, 0, 1, this.ctx.fbufSize.y, " ", Color.WHITE, Color.YELLOW);
				} else if (this.introCGFnum < 84) { // 74 - 83 (10 frames)
					var sx:Int = (this.introCGFnum - 75) * 7;
					var ex:Int = (this.introCGFnum - 74) * 7;
					AdvancedDrawing.drawLine(this.fbuf, {x: sx, y: 19}, {x: ex, y: 19}, " ", Color.WHITE, Color.LIGHT_BLUE);
					AdvancedDrawing.drawLine(this.fbuf, {x: 63 - ex, y: 23}, {x: 63 - sx, y: 23}, " ", Color.WHITE, Color.LIGHT_BLUE);
				} else if (this.introCGFnum < 120) {
					var str:String = "CC Gomoku!".substr(0, Math.floor((this.introCGFnum - 84) / 35 * 10));
					AdvancedDrawing.alignedText(this.fbuf, 21, 0.5, str, Color.MAGENTA);
				} else if (this.introCGFnum > 160) {
					this.fbuf.clear(Color.WHITE, Color.GRAY);
					this.state = State.Menu;
				}
				this.introCGFnum++;
			case Menu:
				if (this.menu == null) {
					this.menu = new GomokuMenu(this.ctx);
				}
				switch (this.menu.update(this.fbuf)) {
					case NOT_OK:
						null;
					case OK(settings):
						this.state = State.Playing(settings);
						this.fbuf.clear(Color.WHITE, Color.BLACK);
				};
			case Playing(settings):
				if (this.playdraw == null) {
					this.playdraw = new PlayDrawing(this.ctx, settings);
				}

				switch (this.playdraw.update(this.fbuf)) {
					case NOT_DONE:
						null;
					case DONE(result, msg):
						this.state = Result(result, msg);
				};

			case Result(r, s):
				AdvancedDrawing.alignedText(this.fbuf, 39, 0.5, "~~ Game over! ~~", Color.LIME);
				AdvancedDrawing.alignedText(this.fbuf, 40, 0.5, "Winner: " + (r.winner == 0 ? "P1" : "P2"), Color.YELLOW);
				AdvancedDrawing.alignedText(this.fbuf, 41, 0.5, "Turns: " + r.turns, Color.YELLOW);
				AdvancedDrawing.alignedText(this.fbuf, 42, 0.5, s, Color.MAGENTA);

			default:
				if (this.frameNum > 30 && !this.ctx.input.P1.isPress(Key.B)) {
					this.state = State.IntroCG;
				} else {
					this.state = State.Menu;
				}
				this.state = State.Menu; // DEBUG
		}
	}

	public inline function update():FrameBuffer {
		this.sm();
		this.frameNum++;
		return this.fbuf;
	}
}
