package arcade_mp_fight_1;

import arcade_mp_fight_1.games.gomoku.GGomoku;
import cc_basics.Logger;
import cc_basics.peripherals.Redstone.RedstonePin;
import utils.CMath;
import arcade_mp_fight_1.games.Menu;
import arcade_mp_fight_1.games.IGame;

enum GameEnum {
	Menu;
	Gomoku;
}

class LifecycleManager {
	private var current:Game;
	private var ctx:GameContext;
	private var cm:CoinManager;
	private var restartKey:RedstonePin;

	public function new(input:InputManager, fbufSize:Vec2i, cm:CoinManager, spk:SoundManager, rst:RedstonePin) {
		this.current = null;
		this.ctx = {
			input: input,
			fbufSize: fbufSize,
			sound: spk,
			lifecycle: this
		}
		this.cm = cm;
		this.restartKey = rst;

		this.restart();
	}

	public function goMenu() {
		this.current = new Menu(this.ctx, cm);
	}

	public function restart() {
		Logger.info("[Lifecycle] Restarting");

		this.goMenu();
	}

	public function update() {
		static var lastKeyState:Bool = false;
		if (lastKeyState != this.restartKey.read() && lastKeyState == false) {
			this.restart();
		}
		lastKeyState = this.restartKey.read();
	}

	public function toGame(name:GameEnum) {
		switch (name) {
			case Gomoku:
				this.current = new GGomoku(this.ctx);
			default:
				this.current = new Menu(this.ctx, cm);
		}
	}

	public function getCurrent():Game {
		return this.current;
	}

	public function currentRunning():Bool {
		return this.current != null;
	}
}
