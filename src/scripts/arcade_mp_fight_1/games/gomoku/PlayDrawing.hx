package arcade_mp_fight_1.games.gomoku;

import haxe.macro.Expr.ImportExpr;
import utils.CMath.VecUtils;
import arcade_mp_fight_1.InputManager;
import arcade_mp_fight_1.games.gomoku.rulesets.Rulesets.getRuleset;
import arcade_mp_fight_1.games.gomoku.rulesets.IGomokuRuleset;
import utils.AdvancedDrawing;
import utils.CMath.Vec2i;
import cc_basics.Enums;
import arcade_mp_fight_1.games.gomoku.GGomoku.GomokuSettings;
import sgui.core.FrameBuffer;
import arcade_mp_fight_1.games.gomoku.GGomoku.GomokuResult;
import arcade_mp_fight_1.games.IGame.GameContext;

private enum PlayResult {
	NOT_DONE;
	DONE(result:GomokuResult, additionString:String);
}

class Checkerboard {
	private var size:Int;

	private var data:Array<Null<Bool>>;

	@:allow(PlayDrawing)
	public var waitForDraw:Array<{p:Vec2i, v:Null<Bool>}>;

	// 只能落棋，无法移除
	public function new(size:Int) {
		this.size = size;
		this.data = [for (_ in 0...size * size) null];
		this.waitForDraw = [];
	}

	public function get(pos:Vec2i):Null<Bool> {
		pos.x = pos.x > this.size ? this.size : pos.x;
		pos.y = pos.y > this.size ? this.size : pos.y;
		return this.data[pos.x * this.size + pos.y];
	}

	public function set(pos:Vec2i, t:Bool):Void {
		pos.x = pos.x > this.size ? this.size : pos.x;
		pos.y = pos.y > this.size ? this.size : pos.y;
		this.data[pos.x * this.size + pos.y] = t;
		this.waitForDraw.push({p: {x: pos.x, y: pos.y}, v: t});
	}

	public function getSize():Int {
		return this.size;
	}
}

class PlayDrawing {
	private var ctx:GameContext;

	private var settings:GomokuSettings;
	private var size:Int;

	private var cbFbuf:FrameBuffer;

	private var rule:IGomokuRuleset;
	private var checkerboard:Checkerboard;

	public function new(ctx:GameContext, settings:GomokuSettings) {
		this.ctx = ctx;
		this.settings = settings;
		this.size = switch (settings.size) {
			case Size13: 13;
			case Size15: 15;
			case Size19: 19;
			case _: 15;
		}
		this.cbFbuf = new FrameBuffer(this.size * 2 + 3, this.size * 2 + 3);
		this.composeX = Math.floor((64 - (this.size * 2 + 3)) * 0.5);

		this.drawCheckerboard();

		this.rule = getRuleset(settings.rule);
		this.checkerboard = new Checkerboard(this.size);
		this.rule.init(this.checkerboard);
	}

	public function drawCheckerboard() {
		this.cbFbuf.clear(Color.WHITE, Color.GRAY);
		// 边框
		var s:Int = this.size * 2 + 2;
		this.cbFbuf.fillRect(0, 0, s, 1, " ", Color.RED, Color.BROWN); // top
		this.cbFbuf.fillRect(0, 0, 1, s, " ", Color.RED, Color.BROWN); // left
		this.cbFbuf.fillRect(s, 0, 1, s, " ", Color.RED, Color.BROWN); // right
		this.cbFbuf.fillRect(0, s, s + 1, 1, " ", Color.RED, Color.BROWN); // bottom

		// 绘制网格
		for (n in 0...this.size) {
			this.cbFbuf.fillRect(1, 2 + n * 2, s - 1, 1, " ", Color.RED, Color.LIGHT_GRAY); // 水平
			this.cbFbuf.fillRect(2 + n * 2, 1, 1, s - 1, " ", Color.RED, Color.LIGHT_GRAY); // 垂直
		}

		// 绘制天元
		this.cbFbuf.setCell(Math.floor(s * 0.5), Math.floor(s * 0.5), " ", Color.RED, Color.LIGHT_BLUE);

		// 星位
		var star:Int = Math.floor(s * 0.25) + (this.size < 15 ? -1 : 0);
		this.cbFbuf.setCell(star, star, " ", Color.RED, Color.LIME); // 第二象限
		this.cbFbuf.setCell(star * 3, star, " ", Color.RED, Color.LIME); // 第一象限
		this.cbFbuf.setCell(star, star * 3, " ", Color.RED, Color.LIME); // 第三象限
		this.cbFbuf.setCell(star * 3, star * 3, " ", Color.RED, Color.LIME); // 第四象限

		// 变量
		this.cursor = {
			x: Math.floor(size * 0.5),
			y: Math.floor(size * 0.5)
		};
	}

	private var composeX:Int = 0;

	private var cursor:Vec2i;

	private var next:NextAction = null;
	private var lastPlace:Vec2i = null;
	private var olderLastPlace:Vec2i = null;
	private var turns:Int = 0;

	private function updateUI(fbuf:FrameBuffer, pos:Vec2i):Bool {
		if (this.next == null) {
			this.next = this.rule.step(null);
		}

		switch (this.next.action) {
			case Place(c):
				// 读取输入
				var player:Player = this.next.player ? this.ctx.input.P1 : this.ctx.input.P2;
				if (player.keyState(Key.Up) == KeyState.Rasing) {
					this.cursor.y -= 1;
					this.ctx.sound.uiFeedback();
				}
				if (player.keyState(Key.Down) == KeyState.Rasing) {
					this.cursor.y += 1;
					this.ctx.sound.uiFeedback();
				}
				if (player.keyState(Key.Left) == KeyState.Rasing) {
					this.cursor.x -= 1;
					this.ctx.sound.uiFeedback();
				}
				if (player.keyState(Key.Right) == KeyState.Rasing) {
					this.cursor.x += 1;
					this.ctx.sound.uiFeedback();
				}

				this.cursor.x = Math.floor(Math.min(this.size - 1, Math.max(0, this.cursor.x)));
				this.cursor.y = Math.floor(Math.min(this.size - 1, Math.max(0, this.cursor.y)));

				if (player.keyState(Key.A) == KeyState.Falling) {
					if (!this.rule.canPlace(this.cursor)) {
						this.ctx.sound.wrong();
					} else {
						this.next = this.rule.step({
							player: this.next.player,
							result: Place(this.cursor),
						});
						this.olderLastPlace = VecUtils.copy(this.lastPlace);
						this.lastPlace = VecUtils.copy(this.cursor);
						this.turns++;

						return switch (this.next.action) {
							case Win(s): true;
							default: false;
						};
					}
					this.ctx.sound.uiFeedback();
				}

				// 提示文字
				fbuf.fillRect(0, 39, 64, 2, " ", Color.WHITE, Color.BLACK);
				if (this.next.player) {
					fbuf.writeText(1, 39, "<P1>", Color.LIGHT_BLUE);
					fbuf.writeText(1, 40, "[A] Place a " + (c ? "BLACK" : "WHITE"), Color.WHITE);
				} else {
					fbuf.writeText(59, 39, "<P2>", Color.YELLOW);
					fbuf.writeText(46, 40, "[A] Place a " + (c ? "BLACK" : "WHITE"), Color.WHITE);
				}
				// 绘制光标
				var cursorState:Bool = this.rule.canPlace(this.cursor);
				var cursorColor:Color = cursorState ? Color.GREEN : Color.RED;
				var cX:Int = pos.x + cursor.x * 2 + 2;
				var cY:Int = pos.y + cursor.y * 2 + 2;
				if (Math.floor(this.frameNum / 10) % 2 == 0) {
					fbuf.setCell(cX, cY - 1, " ", Color.RED, cursorColor);
					fbuf.setCell(cX - 1, cY, " ", Color.RED, cursorColor);
					fbuf.setCell(cX + 1, cY, " ", Color.RED, cursorColor);
					fbuf.setCell(cX, cY + 1, " ", Color.RED, cursorColor);
				} else {
					fbuf.setCell(cX - 1, cY - 1, " ", Color.RED, cursorColor);
					fbuf.setCell(cX + 1, cY - 1, " ", Color.RED, cursorColor);
					fbuf.setCell(cX - 1, cY + 1, " ", Color.RED, cursorColor);
					fbuf.setCell(cX + 1, cY + 1, " ", Color.RED, cursorColor);
				}
				if (cursorState && Math.floor(this.frameNum / 4) % 2 == 0) {
					fbuf.writeText(cX, cY, String.fromCharCode(127), c ? Color.BLACK : Color.WHITE);
				}
			case MakeChoose(choice):
				null;
			case Win(s):
				return true;
		}

		return false;
	}

	private var frameNum:Int = 0;

	public function update(fbuf:FrameBuffer, ret:Bool = false):PlayResult {
		// 棋子
		for (stone in this.checkerboard.waitForDraw) {
			this.cbFbuf.writeText(stone.p.x * 2 + 2, stone.p.y * 2 + 2, String.fromCharCode(7), stone.v ? Color.BLACK : Color.WHITE);
		}
		this.checkerboard.waitForDraw.resize(0);
		if (this.olderLastPlace != null) {
			this.cbFbuf.writeText(this.olderLastPlace.x * 2 + 2, this.olderLastPlace.y * 2 + 2, String.fromCharCode(7),
				this.checkerboard.get(this.olderLastPlace) ? Color.BLACK : Color.WHITE);
		}
		if (this.lastPlace != null) {
			this.cbFbuf.writeText(this.lastPlace.x * 2 + 2, this.lastPlace.y * 2 + 2, String.fromCharCode(8),
				this.checkerboard.get(this.lastPlace) ? Color.BLACK : Color.WHITE);
		}

		if (ret) {
			return DONE({
				winner: this.next.player ? 0 : 1,
				turns: this.turns
			}, switch (this.next.action) {
				case Win(s): s;
				default: "";
			});
		}

		//
		fbuf.compose(this.cbFbuf, this.composeX, 1);
		AdvancedDrawing.alignedText(fbuf, 0, 0.5, "Gomoku - Turn #" + (this.turns + 1), Color.MAGENTA, Color.BLACK);
		if (this.updateUI(fbuf, {x: this.composeX, y: 1})) {
			this.frameNum++;
			return this.update(fbuf, true); // 多刷一次
		};
		this.frameNum++;
		return NOT_DONE;
	}
}
