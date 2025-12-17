package ae2_createcpb_takeout;

import cc_basics.Logger;
import haxe.ds.StringMap;
import cc_basics.Base;
import cc_basics.peripherals.advanced.BlockReader;

typedef CraftStatus = {}

typedef Item = {
	id:String,
	amount:Int,
	skip:Bool,
	craftStatus:Null<CraftStatus>
}

typedef ItemList = {
	total:Int,
	list:Array<Item>
}

enum ClipboardValidState {
	NotDepot;
	NoItem;
	NotClipboard(id:String);
	ClipboardNotItemList;
	Valid(items:Null<ItemList>);
	FailedToParse(e:String);
}

class ClipboardReader {
	private var reader:BlockReader;

	public function new(reader:BlockReader) {
		this.reader = reader;
	}

	private function readI(parse:Bool):ClipboardValidState {
		if (this.reader.getBlockID() != "create:depot") {
			return NotDepot;
		}
		var raw:Dynamic = this.reader.getBlockData();
		if (!Reflect.hasField(raw, "HeldItem")) {
			return NoItem;
		}
		if (!Reflect.hasField(raw.HeldItem, "Item")) {
			return NoItem;
		}
		if (raw.HeldItem.Item.id != "create:clipboard") {
			return NotClipboard(raw.HeldItem.Item.id);
		}
		var item:Dynamic = raw.HeldItem.Item;
		if (!Reflect.hasField(item, "components")) {
			return ClipboardNotItemList;
		}

		var itemComponents = item.components;
		if (!(Reflect.hasField(itemComponents, "create:clipboard_pages")
			&& Reflect.hasField(itemComponents, "create:clipboard_read_only"))) {
			return ClipboardNotItemList;
		}
		var pages:Array<Array<Dynamic>> = Reflect.field(itemComponents, "create:clipboard_pages");
		var r:ItemList = {
			total: 0,
			list: new Array()
		};
		if (pages == null) {
			return ClipboardNotItemList;
		}

		if (!parse) {
			return Valid(null);
		}

		var map:StringMap<Item> = new StringMap();
		for (n in Reflect.fields(pages)) {
			var page:Array<Dynamic> = Reflect.field(pages, n);
			if (page == null) {
				continue;
			}
			for (entryN in Reflect.fields(page)) {
				var entry:Dynamic = Reflect.field(page, entryN);
				for (check in ['item_amount', 'checked', 'icon']) {
					if (!Reflect.hasField(entry, check)) {
						return FailedToParse('Missing a required field ${check} (${entry})');
					}
				}

				var amount:Int = entry.item_amount;
				if (amount == 0) {
					continue;
				}

				var ID:String = entry.icon.id;
				var skip:Bool = entry.checked == 1;

				r.total += amount;
				if (map.exists(ID)) {
					map.get(ID).amount += amount;
				} else {
					map.set(ID, {
						id: ID,
						skip: skip,
						amount: amount,
						craftStatus: null
					});
				}
			}
		}

		r.list = [for (_ => value in map.keyValueIterator()) value];
		r.list.sort((a, b) -> a.skip ? 1000000 : (b.skip ? -1000000 : b.amount - a.amount));

		return Valid(r);
	}

	public function read(parse:Bool = true):ClipboardValidState {
		try {
			return readI(parse);
		} catch (e:Dynamic) {
			return FailedToParse(e);
		}
	}
}
