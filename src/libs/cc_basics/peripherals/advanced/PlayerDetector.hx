package cc_basics.peripherals.advanced;

import utils.CMath.Vec2f;
import utils.CMath.Vec3i;

enum PlayerFilter {
	Every;
	Range(range:Int);
	Cubic(size:Vec3i);
	Coords(a:Vec3i, b:Vec3i);
}

typedef PlayerDetail = {
	dim:String,
	pos:Vec3i,
	facing:Vec2f,
	health:Int,
	maxHealth:Int,
	airSupply:Int,
}

class PlayerDetected {
	private var parent:PlayerDetector;
	private var name:String;

	@:allow("PlayerDetector")
	public function new(parent:PlayerDetector, name:String) {
		this.parent = parent;
		this.name = name;
	}

	public function getDetail():PlayerDetail {
		var raw:Dynamic = this.parent.getPlayerDetailRaw(this.name);
		return {
			dim: raw.dimension,
			pos: {
				x: raw.x,
				y: raw.y,
				z: raw.z
			},
			facing: {
				x: raw.yaw,
				y: raw.pitch
			},
			airSupply: raw.airSupply,
			health: raw.health,
			maxHealth: raw.maxHealth
		}
	}
}

class PlayerDetector extends Peripheral {
	public function detectPlayers(filter:PlayerFilter):Array<PlayerDetected> {
		var rList:Array<String> = switch filter {
			case Every:
				this.call("getOnlinePlayers");
			case Coords(a, b):
				this.call("getPlayersInCoords", [a.x, a.y, a.z], [b.x, b.y, b.z]);
			case Cubic(size):
				this.call("getPlayersInCubic", [size.x, size.y, size.z]);
			case Range(range):
				this.call("getPlayersInRange", range);
		};

		return rList.map(this.wrapPlayer);
	}

	@:allow("PlayerDetected")
	public function getPlayerDetailRaw(name:String) {
		return this.call("getPlayer", name);
	}

	private function wrapPlayer(name:String):PlayerDetected {
		return new PlayerDetected(this, name);
	}
}
