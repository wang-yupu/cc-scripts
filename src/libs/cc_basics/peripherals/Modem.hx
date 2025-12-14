package cc_basics.peripherals;

import haxe.Rest;
import haxe.ds.IntMap;
import cc_basics.Enums;
import haxe.extern.EitherType;
import cc_basics.Logger;
import cc_basics.Base;

inline final MAX_CHANNEL = 65535;
inline final GPS_CHANNEL = 65534;
inline final MAX_CHANNEL_COUNT = 127;

typedef NetworkData = {
	payload:Dynamic,
	replyChannel:Int,
	distance:Int
};

class Channel {
	public var isOpen(get, never):Bool;
	public var channel(get, never):Int;

	private var parent:Modem;
	private var rChannel:Int;

	public function new(parent:Modem, channel:Int) {
		this.parent = parent;
		this.rChannel = channel;
	}

	public function transmit(payload:Dynamic, replyChannel:Int = 0) {
		if (this.isOpen) {}
	}

	public function close() {
		if (this.isOpen) {
			this.parent.close(this.rChannel);
		}
	}

	public function recv():Null<NetworkData> {
		var i:Array<Dynamic> = null;
		while (true) {
			i = Base.pullEvent("modem_message");
			if (i[1] != this.parent.getID()) {
				continue;
			}
			if (i[2] == this.rChannel) {
				break;
			}
		}
		return {
			payload: i[4],
			replyChannel: i[3],
			distance: i[5]
		}
	}

	private function get_isOpen():Bool {
		return this.parent.isOpen(this.rChannel);
	}

	private function get_channel():Int {
		return this.rChannel;
	}
}

class Modem extends Peripheral {
	private var opened:IntMap<Channel>;
	private var openedChannelCount:Int;

	public function new(id:EitherType<Side, String>) {
		super(id);
		if (this.getType() != "modem") {
			Logger.error("[Lib warning] The peripheral is not a modem periheral.");
		}
		this.opened = new IntMap<Channel>();
		this.openedChannelCount = 0;
	}

	public function open(channel:Int):Null<Channel> {
		if (channel > MAX_CHANNEL) {
			Logger.warning("Bad channel");
			return null;
		}
		if (this.opened.exists(channel)) {
			return this.opened.get(channel);
		}
		if (this.openedChannelCount >= MAX_CHANNEL_COUNT) {
			return null;
		}
		this.call("open", channel);
		var r:Channel = new Channel(this, channel);
		this.opened.set(channel, r);
		return r;
	}

	public function closeAll() {
		this.opened.clear();
		this.openedChannelCount = 0;
		this.call("closeAll");
	}

	public function get(channel:Int):Null<Channel> {
		return this.opened.get(channel);
	}

	public function close(channel:Int):Bool {
		try {
			this.call("close", channel);
			this.openedChannelCount--;
			this.opened.remove(channel);
			return true;
		} catch (e:Dynamic) {
			return false;
		}
	}

	public function isWireless():Bool {
		return this.call("isWireless");
	}

	public function isOpen(channel:Int):Bool {
		return this.call("isOpen", channel);
	}

	public function transmit(channel:Int, replyChannel:Int, payload:Dynamic) {
		this.call("transmit", channel, replyChannel, payload);
	}

	public function getNameLocal():String {
		return this.call("getNameLocal");
	}

	public function getNamesRemote():Array<String> {
		return this.call("getNamesRemote");
	}

	public function isPresentRemote(name:String):Bool {
		return this.call("isPresentRemote", name);
	}

	public function getTypeRemote(name:String):Null<String> {
		return this.call("getTypeRemote", name);
	}

	public function hasTypeRemote(name:String, typ:String):Null<Bool> {
		return this.call("hasTypeRemote", name, typ);
	}

	public function getMethodsRemote(name:String):Null<Array<String>> {
		return this.call("getMethodsRemote", name);
	}

	public function callRemote(name:String, method:String, ...args:Any):Null<String> {
		return this.call("callRemote", name, method, args);
	}
}
