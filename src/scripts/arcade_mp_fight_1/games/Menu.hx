package arcade_mp_fight_1.games;

import haxe.Exception;
import arcade_mp_fight_1.InputManager;
import arcade_mp_fight_1.LifecycleManager.GameEnum;
import utils.AdvancedDrawing;
import arcade_mp_fight_1.games.IGame.GameContext;
import arcade_mp_fight_1.CoinManager.CoinStatus;
import cc_basics.Enums.Color;
import arcade_mp_fight_1.games.IGame.Game;
import utils.CMath;
import sgui.core.FrameBuffer;

typedef GameEntry = {
	name:String,
	i:GameEnum
}

class Menu implements Game {
	private var fbuf:FrameBuffer;

	private var input:InputManager;
	private var cm:CoinManager;
	private var sound:SoundManager;
	private var lc:LifecycleManager;

	public function new(ctx:GameContext, cm:CoinManager) {
		this.fbuf = new FrameBuffer(ctx.fbufSize.x, ctx.fbufSize.y);
		this.cm = cm;
		this.sound = ctx.sound;
		this.input = ctx.input;
		this.lc = ctx.lifecycle;
	}

	private var frameNum:Int = 0;

	private var coinGot:Bool = false;
	private var lastCoinNum:Int = null;
	private var selectedGame:Int = 0;
	private var selectOverflowCount:Int = 0;
	private final games:Array<GameEntry> = [
		{
			name: "CC Fighting",
			i: null
		},
		{
			name: "Gomoku",
			i: GameEnum.Gomoku
		},
		{
			name: "CCMania",
			i: null
		}
	];

	private var waveRadius:Int = 0;

	public inline function update():FrameBuffer {
		this.fbuf.clear(Color.WHITE, Color.GRAY);
		if (waveRadius != 0) {
			AdvancedDrawing.drawCircle(this.fbuf, {x: 32, y: 15}, 63 - waveRadius, " ", Color.WHITE, Color.LIGHT_GRAY);
			AdvancedDrawing.drawCircle(this.fbuf, {x: 32, y: 15}, 60 - waveRadius, " ", Color.WHITE, Color.LIGHT_BLUE);
			waveRadius--;
		} else if (this.frameNum % 65 == 0) {
			waveRadius = 64;
		}

		var rainbowColor:Color = [
			Color.RED,
			Color.ORANGE,
			Color.YELLOW,
			Color.LIME,
			Color.GREEN,
			Color.CYAN,
			Color.BLUE,
			Color.PURPLE
		][Math.floor(this.frameNum / 4) % 8];
		this.fbuf.fillRect(22, 14, 20, 3, " ", Color.WHITE, Color.LIGHT_BLUE);
		AdvancedDrawing.alignedText(this.fbuf, 15, 0.5, "CC Arcade", rainbowColor);
		AdvancedDrawing.alignedText(this.fbuf, coinGot ? 38 : 34, 0.5, "Copyright (c) wangyupu", Color.WHITE);

		if (!coinGot) {
			var coinStatus:CoinStatus = this.cm.take();
			switch (coinStatus) {
				case NotEnough(count):
					AdvancedDrawing.alignedText(this.fbuf, 20, 0.5, 'INSERT ${count} COIN', Math.floor(frameNum / 8) % 2 == 0 ? Color.WHITE : Color.LIGHT_GRAY);
					AdvancedDrawing.drawSimpleTriangle(this.fbuf, {x: 32, y: (Math.floor((frameNum + 3) / 4) % 2 == 0 ? 40 : 41)}, 7, 3, Direction.Down, " ",
						rainbowColor, rainbowColor);
					if (this.lastCoinNum != count && this.lastCoinNum != null) {
						this.sound.uiFeedback();
					}
					this.lastCoinNum = count;
				case OK:
					coinGot = true;
					this.sound.ring();
			}
		} else {
			// drawing menu
			if (this.input.P1.keyState(Key.Up) == KeyState.Falling) {
				this.selectedGame = Math.floor(Math.max(0, this.selectedGame - 1));
				this.sound.uiFeedback();
				this.selectOverflowCount = Math.floor(Math.max(0, this.selectOverflowCount)) + 1;
			}
			if (this.input.P1.keyState(Key.Down) == KeyState.Falling) {
				this.selectedGame = Math.floor(Math.min(2, this.selectedGame + 1));
				this.sound.uiFeedback();
				this.selectOverflowCount = Math.floor(Math.min(0, this.selectOverflowCount)) - 1;
			}
			if (Math.abs(this.selectOverflowCount) >= 24) {
				this.sound.boom();
				throw new Exception("STOP!!! (no refund available)");
			}
			if (this.input.P1.keyState(Key.A) == KeyState.Falling) {
				if (this.games[this.selectedGame].i != null) {
					this.lc.toGame(this.games[this.selectedGame].i);
				}
			}
			var index:Int = 0;
			for (g in games) {
				if (selectedGame == index) {
					this.fbuf.fillRect(24, 20 + 4 * index - 1, 16, 3, " ", Color.WHITE, Color.LIME);
				}
				AdvancedDrawing.alignedText(this.fbuf, 20 + 4 * index, 0.5, g.name, selectedGame == index ? rainbowColor : Color.WHITE);
				index++;
			}
		}
		this.frameNum++;
		return this.fbuf;
	}
}
