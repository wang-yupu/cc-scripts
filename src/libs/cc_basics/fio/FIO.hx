package cc_basics.fio;

import haxe.Exception;
import cc_basics.Enums;
import haxe.extern.EitherType;
import haxe.io.Path;
import lua.Table;

enum FileMode {
	read;
	write;
	append;
	updateKeep;
	updateErase;

	binaryRead;
	binaryWrite;
	binaryAppend;
	binaryUpdateKeep;
	binaryUpdateErase;
}

private final fileModeToStringMap:Map<FileMode, String> = [
	read => "r",
	write => "w",
	append => "a",
	updateKeep => "r+",
	updateErase => "w+",
	binaryRead => "rb",
	binaryWrite => "wb",
	binaryAppend => "ab",
	binaryUpdateKeep => "rb+",
	binaryUpdateErase => "wb+"
];

function toReadableSize(bytes:Int):String {
	var units = ["B", "KB", "MB", "GB"];
	var value = bytes * 1.0;
	var i = 0;

	while (value >= 1000 && i < units.length - 1) {
		value /= 1000;
		i++;
	}

	var s = StringTools.trim(StringTools.replace(Std.string(Math.round(value * 100) / 100), " ", ""));
	return s + units[i];
}

@:native("io")
private extern class CC_io {
	public static function open(path:String, mode:String):CC_io_file;
}

private extern class CC_io_file {
	public function read(?mode:EitherType<Int, String>):Dynamic;
	public function write(str:String):Void;
	public function close():Void;
	public function seek(whence:String, offset:Int):Int;
	public function lines(?mode:String):Null<String>;
}

@:native("fs")
extern class CC_fs {
	public static function exists(path:String):Bool;
	public static function isDir(path:String):Bool;
	public static function list(path:String):Dynamic;
	public static function getDrive(path:String):String;
	public static function getFreeSpace(path:String):EitherType<Int, String>;
	public static function getCapacity(path:String):Null<Int>;
	public static function getSize(path:String):Int;
	public static function isReadOnly(path:String):Bool;
	public static function delete(path:String):Void;
	public static function attributes(path:String):CC_fs_attrs;
}

@:native("disk")
extern class CC_disk {}

typedef SpaceStatus = {
	var available:Int;
	var total:Int;
}

typedef CC_fs_attrs = {
	var size:Int;
	var isDir:Bool;
	var isReadOnly:Bool;
	var created:Int;
	var modified:Int;
}

class FIO {
	private var path:Path;

	public function new(p:EitherType<Path, String>) {
		if (Std.isOfType(p, String)) {
			this.path = new Path(p);
		} else {
			this.path = p;
		}
	}

	public function exists():Bool {
		return CC_fs.exists(this.path.toString());
	}

	public function isDir():Bool {
		if (!this.exists()) {
			return null;
		}
		return CC_fs.isDir(this.path.toString());
	}

	public function ls():Array<FIO> {
		var tbl = CC_fs.list(this.path.toString());
		var children:Array<String> = Table.toArray(tbl);
		var result:Array<FIO> = [];
		for (child in children) {
			result.push(new FIO(Path.join([this.path.toString(), child])));
		}

		return result;
	}

	public function getName() {
		return this.path.file;
	}

	public function getExtension() {
		return this.path.ext;
	}

	public function getFile() {
		return Path.withoutDirectory(this.path.toString());
	}

	public function toString():String {
		return this.path.toString();
	}

	public function open(mode:FileMode):FIOFileOpHandler {
		return new FIOFileOpHandler(this, mode);
	}

	public function driveOf():String {
		return CC_fs.getDrive(this.path.toString());
	}

	public function size():Null<Int> {
		if (this.isDir()) {
			return null;
		}
		return CC_fs.getSize(this.path.toString());
	}

	public function spaceStatus():SpaceStatus {
		var t = CC_fs.getCapacity(this.path.toString());
		var a = CC_fs.getFreeSpace(this.path.toString());
		if (a == "unlimited") {
			a = 2 ^ 31;
		}
		if (t == null) {
			t = 0;
		}
		return {
			total: t,
			available: a
		}
	}

	public function isReadonly():Bool {
		return CC_fs.isReadOnly(this.path.toString());
	}

	public function attrs():CC_fs_attrs {
		return CC_fs.attributes(this.path.toString());
	}

	public function delete():Bool {
		try {
			CC_fs.delete(this.path.toString());
			return true;
		} catch (e:Dynamic) {
			return false;
		}
	}
}

private class FIOFileLinesIterator {
	private var f:CC_io_file;
	private var m:String;
	private var cached:Null<String>;
	private var done:Bool;

	public function new(p:CC_io_file, m) {
		this.f = p;
	}

	public function hasNext():Bool {
		return !done;
	}

	public function next():String {
		var result = cached;
		cached = this.f.lines(this.m);
		if (cached == null)
			done = true;
		return result;
	}
}

class FIOFileOpHandler {
	public var readLineWithEOL:Bool = false;

	private var lf:CC_io_file;

	@:allow(FIO)
	public function new(p:FIO, m:FileMode) {
		if ((!p.exists() || p.isDir()) && ([FileMode.read, FileMode.write, FileMode.updateKeep].contains(m))) {
			throw new Exception("File is not exists or is a dir");
		}
		this.lf = CC_io.open(p.toString(), fileModeToStringMap[m]);
	}

	public function close() {
		this.lf.close();
		this.lf = null;
	}

	public function seek(pos:Int = 0) {
		if (this.lf == null) {
			throw new Exception("File was closed");
		}
		this.lf.seek("set", pos + 1);
	}

	public function read(bufSize:Int = 1):String {
		if (this.lf == null) {
			throw new Exception("File was closed");
		}
		return this.lf.read(bufSize);
	}

	public function readLine():String {
		if (this.lf == null) {
			throw new Exception("File was closed");
		}
		return this.lf.read(this.readLineWithEOL ? '*L' : '*l');
	}

	public function readAll():String {
		if (this.lf == null) {
			throw new Exception("File was closed");
		}
		return this.lf.read("*a");
	}

	public function write(content:String) {
		if (this.lf == null) {
			throw new Exception("File was closed");
		}
	}

	public function iterator():FIOFileLinesIterator {
		return new FIOFileLinesIterator(this.lf, this.readLineWithEOL ? '*L' : '*l');
	}
}

class DiskIO extends Peripheral {
	public var fio(get, never):FIO;

	private var isDrive:Bool = false;

	public function new(id:EitherType<Side, String>) {
		super(id);
		if (this.getType() != "drive") {
			Logger.error("[Lib warning] The peripheral is not a drive periheral.");
		}
	}

	function get_fio():FIO {
		if (this.isDrive) {
			return null;
		}
		return null;
	}
}
