package cc_basics.peripherals;

import cc_basics.Enums.Side;
import haxe.Int32;
import haxe.Rest;
import haxe.extern.EitherType;

private typedef RawFluidTank = {
	var name:String;
	var amount:Int;
}

private class FluidTank {
	private var parent:GenericFluidStorage;
	private var name:String;
	private var amount:Int;
	private var slot:Int;

	public function new(parent:GenericFluidStorage, by:RawFluidTank, slot:Int) {
		this.name = by.name;
		this.amount = by.amount;
		this.parent = parent;
		this.slot = slot;
	}

	public function pushTo(to:FluidTank, limit:Int = null) {
		if (limit == null) {
			limit = 2147483640;
		}
		this.parent.pushFluid(to.parent.getID(), limit, this.name);
	}

	public function pushToFluidStorage(to:GenericFluidStorage, limit:Int = null) {
		if (limit == null) {
			limit = 2147483640;
		}
		this.parent.pushFluid(to.getID(), limit, this.name);
	}

	public function getSlot():Int {
		return this.slot;
	}

	public function getName():String {
		return this.name;
	}

	public function getCount():Int {
		return this.amount;
	}
}

class GenericFluidStorage extends Peripheral {
	private var tanks:Array<FluidTank>;

	public function new(id:EitherType<Side, String>) {
		super(id);
		this.tanks = new Array<FluidTank>();
		this.sync();
	}

	private function getRawTanks():Array<RawFluidTank> {
		return this.call("tanks");
	}

	private var lastSync:Float;

	private inline function sync():Void {
		this.lastSync = Base.clock();
		if (!this.isPresent()) {
			Logger.warning("[Lib warning] [GenericFluidStorage] The peripheral is not exists: ", this.id);
			return;
		}
		var raw:Array<RawFluidTank> = this.getRawTanks();
		this.tanks = new Array<FluidTank>();
		for (key in Reflect.fields(raw)) {
			var value = Reflect.field(raw, key);
			this.tanks[Std.parseInt(key) - 1] = new FluidTank(this, value, Std.parseInt(key));
		}
	}

	public function trigSync(force:Bool = false) {
		if (Base.clock() - this.lastSync > 3 || force) {
			this.sync();
		}
	}

	public function getTanks():Array<FluidTank> {
		this.trigSync();
		return this.tanks;
	}

	public function getTank(at:Int = 0):FluidTank {
		return this.tanks[at];
	}

	public inline function pushFluid(args:Rest<Any>) {
		return this.call("pushFluid", ...args);
	}

	public inline function pullFluid(args:Rest<Any>) {
		return this.call("pullFluid", ...args);
	}

	public function printTankList() {
		this.trigSync();
		for (tank in this.tanks) {
			if (tank != null) {
				Base.print("Tank ", tank.getSlot(), " :: ", tank.getCount(), "mB ", tank.getName());
			}
		}
	}

	public function iterator():Iterator<FluidTank> {
		return this.tanks.iterator();
	}
}
