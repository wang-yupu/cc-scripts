package sgui.events;

import sgui.core.Keys;

typedef TouchHandler = (x:Int, y:Int) -> Void;
typedef ScrollHandler = (direction:Int, x:Int, y:Int) -> Void;
typedef KeyHandler = (keyCode:KeyEvent) -> Void;
typedef CharHandler = (ch:String) -> Void;
typedef ResizeHandler = (width:Int, height:Int) -> Void;
typedef PasteHandler = (content:String) -> Void;

typedef KeyEvent = {
	ctrl:Bool,
	alt:Bool,
	shift:Bool,
	keys:Array<Keys>,
}
