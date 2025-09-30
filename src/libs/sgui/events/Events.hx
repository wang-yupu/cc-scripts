package sgui.events;

typedef TouchHandler = (x:Int, y:Int) -> Void;
typedef ScrollHandler = (direction:Int, x:Int, y:Int) -> Void;
typedef KeyHandler = (keyCode:Int) -> Void;
typedef CharHandler = (ch:String) -> Void;
typedef ResizeHandler = (width:Int, height:Int) -> Void;
typedef PasteHandler = (content:String) -> Void;
