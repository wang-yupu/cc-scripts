package meta;

import meta.MetaType;
import haxe.macro.Context;
import haxe.macro.Expr;

class MetaMacro {
	public static macro function get():ExprOf<meta.ScriptMetadata> {
		var mj:Null<Int> = Std.parseInt(Context.definedValue("version_major"));
		var mn:Null<Int> = Std.parseInt(Context.definedValue("version_minor"));
		var pt:Null<Int> = Std.parseInt(Context.definedValue("version_patch"));
		if (mj == null)
			mj = 0;
		if (mn == null)
			mn = 0;
		if (pt == null)
			pt = 0;

		return macro({
			version: ({major: $v{mj}, minor: $v{mn}, patch: $v{pt}} : haxe.display.Protocol.Version)
		} : meta.ScriptMetadata);
	}
}
