package cc_basics.peripherals.advanced;

import cc_basics.Enums;
import haxe.extern.EitherType;
import cc_basics.peripherals.GenericInventory;

typedef MEItemDetail = {
	name:String,
	count:Int,
	craftable:Bool
}

class MEBridge extends Peripheral {
	// 与1.21.1 - 0.7.57b兼容
	public function new(id:EitherType<Side, String>) {
		super(id);
	}

	public function exportItem(item:ItemDetail, side:Side) {
		this.call("exportItem", {"name": item.name, "count": item.count}, getSideName(side));
	}

	public function exportItemTo(item:ItemDetail, to:GenericInventory) {
		this.call("exportItem", {"name": item.name, "count": item.count}, to.getID());
	}

	public function getItemDetail(i:EitherType<String, ItemDetail>):Null<MEItemDetail> {
		var r:Dynamic;
		if (Std.isOfType(i, String)) {
			r = this.call("getItem", {"name": i});
		} else {
			var it:ItemDetail = i;
			r = this.call("getItem", {"name": it.name});
		}
		if (r == null) {
			return null;
		}
		return {
			name: r.name,
			craftable: r.isCraftable,
			count: r.count
		};
	}

	public function craft(i:EitherType<String, MEItemDetail>, count:Int, force:Bool = false):Null<AutocraftPromise> {
		if (Std.isOfType(i, String)) {
			return new AutocraftPromise(this.call("craftItem", {"name": i, "count": count}));
		} else {
			var it:MEItemDetail = i;
			if (!(it.craftable || force)) {
				return null;
			}
			return new AutocraftPromise(this.call("craftItem", {"name": it.name, "count": count}));
		}
	}
}

enum AutocraftStatus {
	NotStarted;
	Caculating;
	Crafting(progress:Int);
	Done;
	Canceled;
	CaculationFailed;
}

class AutocraftPromise {
	private var raw:Dynamic;

	@:allow(MEBridge)
	public function new(raw:Dynamic) {
		this.raw = raw;
	}

	public function cancel() {}

	public function status():AutocraftStatus {
		if (this.raw.isDone()) {
			return AutocraftStatus.Done;
		}
		if (this.raw.isCanceled()) {
			return AutocraftStatus.Canceled;
		}
		if (this.raw.isCaculationStarted()) {
			return AutocraftStatus.Caculating;
		}
		if (this.raw.isCaculationNotSuccessful()) {
			return AutocraftStatus.CaculationFailed;
		}
		if (this.raw.isCraftStarted()) {
			return AutocraftStatus.Crafting(0);
		}
		return AutocraftStatus.NotStarted;
	}
}
