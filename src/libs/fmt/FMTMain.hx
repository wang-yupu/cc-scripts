package fmt;

import haxe.macro.Expr;
import fmt.FMTMacro;
import fmt.Manager;

class FMTMain {
	public static function main() {
		new ThreadManager(FMTMacro.generate());
	}
}
