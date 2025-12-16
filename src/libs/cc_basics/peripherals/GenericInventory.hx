package cc_basics.peripherals;

import haxe.Rest;
import cc_basics.peripherals.advanced.BlockReader;
import haxe.extern.EitherType;
import cc_basics.Base;
import cc_basics.Enums;

typedef ItemDetail = {
	var count:Int;
	var name:String;
	@:optional var maxCount:Int;
	@:optional var damage:Int;
	@:optional var durability:Int;
	@:optional var maxDamage:Int;
	@:optional var nbt:String;
}

enum SlotMovingResult {
	Success(count:Int);
	Failed;
}

class Slot {
	private var parent:GenericInventory;
	private var slot:Int;
	private var item:ItemDetail;

	public function new(slotOf:GenericInventory, item:ItemDetail, num:Int) {
		this.parent = slotOf;
		this.item = item;
		this.slot = num;
	}

	public function getItem(update:Bool = true):ItemDetail {
		if (update) {
			this.update();
		}
		return this.item;
	}

	public function getSlot():Int {
		return this.slot;
	}

	public function update() {
		this.parent.trigSync();
	}

	public function pushTo(to:Slot, limit:Int = 64):SlotMovingResult {
		if (to.getItem().name != null || this.item.name == null) {
			return SlotMovingResult.Failed;
		}
		var movedCount = this.parent.pushItems(to.parent.getID(), this.slot + 1, limit, to.slot + 1);
		return SlotMovingResult.Success(movedCount);
	}

	public function pushToInventory(to:GenericInventory, limit:Int = 64):SlotMovingResult {
		if (this.item.name == null) {
			return SlotMovingResult.Failed;
		}
		var movedCount = this.parent.pushItems(to.getID(), this.slot + 1, limit);
		return SlotMovingResult.Success(movedCount);
	}

	public function pullFrom(from:Slot, limit:Int = 64):SlotMovingResult {
		if (from.getItem().name != null || this.item.name != null) {
			return SlotMovingResult.Failed;
		}
		var movedCount = this.parent.pullItems(from.parent.getID(), from.slot + 1, limit, this.slot + 1);
		return SlotMovingResult.Success(movedCount);
	}

	public function overrideItem(item:ItemDetail) {
		this.item = item;
	}

	public inline function isEmpty():Bool {
		return this.item.count == 0 && this.item.name == null;
	}

	public function tryReadNBT() {}
}

class GenericInventory extends Peripheral {
	private var slots:Array<Slot>;
	private var blockReader:BlockReader;
	private var lastSync:Float;

	public function new(id:EitherType<Side, String>) {
		super(id);
		var size:Int = this.getSize();
		this.slots = new Array<Slot>();
		for (i in 0...size) {
			this.slots.push(new Slot(this, {name: null, count: 0}, i));
		}
		this.lastSync = -10;
	}

	private function getRawList():Array<ItemDetail> {
		return this.call("list");
	}

	public function getSize():Int {
		return this.call("size");
	}

	public inline function sync() {
		this.lastSync = Base.clock();
		if (!this.isPresent()) {
			Logger.warning("[Lib warning] [GenericInventory] The peripheral is not exists: ", this.id);
			return;
		}
		for (i in 0...this.slots.length) {
			this.slots[i] = new Slot(this, {name: null, count: 0}, i);
		}
		var raw:Array<ItemDetail> = this.getRawList();
		for (key in Reflect.fields(raw)) {
			var value = Reflect.field(raw, key);
			this.slots[Std.parseInt(key) - 1] = new Slot(this, value, Std.parseInt(key) - 1);
		}
	}

	public function trigSync() {
		if (Base.clock() - this.lastSync > 3) {
			this.sync();
		}
	}

	public function connectAPBlockReader(blockReader:BlockReader) {}

	public function slotAt(slot:Int) {
		return this.slots[slot];
	}

	public inline function pushItems(args:Rest<Any>) {
		return this.call("pushItems", ...args);
	}

	public inline function pullItems(args:Rest<Any>) {
		return this.call("pullItems", ...args);
	}

	public function printItemList() {
		for (slot in this.slots) {
			if (slot.getItem(false).name != null) {
				Base.print("Slot ", slot.getSlot(), " :: ", slot.getItem(false));
			}
		}
	}

	public function iterator():Iterator<Slot> {
		return this.slots.iterator();
	}
}
