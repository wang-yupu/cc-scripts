package fmt;

import haxe.macro.Expr;
import haxe.macro.Context;

class FMTMacro {
	macro static public function generate():Expr {
		var mainClass = Context.definedValue("fmtmain");
		if (mainClass == null) {
			Context.error("no fmtmain macro defined", Context.currentPos());
		}
		var cls = macro $p{mainClass.split(".")};
		return macro $cls.main;
	}
}
