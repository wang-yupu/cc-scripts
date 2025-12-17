package ae2_createcpb_takeout;

import cc_basics.Enums.Note;
import cc_basics.Enums.Instrument;
import cc_basics.peripherals.Speaker;
import sgui.core.FrameBuffer;
import cc_basics.Enums.Color;

class DrawUtils {
	public static function writeTextParts(fbuf:FrameBuffer, x:Int, y:Int, texts:Array<String>, colors:Array<Color>) {
		if (texts.length != colors.length) {
			return;
		}
		var index:Int = 0;
		var cursor:Int = 0;
		for (str in texts) {
			fbuf.writeText(x + cursor, y, str, colors[index]);
			cursor += str.length;

			index++;
		}
	}
}

class NamespaceUtils {
	public static function toShortNamespace(itemName:String):{s:String, c:Color} {
		switch (itemName.split(":")[0]) {
			case "minecraft":
				return {s: "V", c: Color.GREEN};
			case "create":
				return {s: "Cr", c: Color.ORANGE};
			case "computercraft":
				return {s: "CC", c: Color.YELLOW};
			case "fluxnetworks":
				return {s: "Fn", c: Color.CYAN};
			case "ae2":
				return {s: "AE", c: Color.CYAN};
			case "farmersdelight":
				return {s: "Fd", c: Color.ORANGE};
			case "advancedperipherals":
				return {s: "AP", c: Color.YELLOW};

			default:
				return {s: itemName.split(":")[0].substr(0, 3), c: Color.BLUE};
		}
	}
}

class SpeakerUtils {
	private var spk:Speaker = null;

	public function new(spk:Speaker) {
		this.spk = spk;
	}

	public function ring() {
		if (this.spk == null) {
			return;
		};
		this.spk.playNote(Instrument.bell, Note.D4, 2);
	}

	public function boom() {
		if (this.spk == null) {
			return;
		};
		this.spk.playSound("minecraft:entity.generic.explode");
	}

	public function wrong() {
		if (this.spk == null) {
			return;
		};
		this.spk.playNote(Instrument.didgeridoo, Note.C4, 2);
	}
}
