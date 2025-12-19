package arcade_mp_fight_1.games;

import utils.CMath.Vec2i;
import sgui.core.FrameBuffer;

typedef GameContext = {
	sound:SoundManager,
	input:InputManager,
	lifecycle:LifecycleManager,
	fbufSize:Vec2i
}

interface Game {
	function update():FrameBuffer;
}
