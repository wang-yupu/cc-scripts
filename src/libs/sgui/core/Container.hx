package sgui.core;

import cc_basics.Enums.Color;
import sgui.core.FrameBuffer;
import sgui.core.Widget;
import cc_basics.Logger;

class Container extends Widget {
	public var children(default, null):Array<Widget>;
	public var clipContent:Bool = false;
	public var background:Color = Color.BLACK;

	public function new(width:Null<Int> = null, height:Null<Int> = 1) {
		super(width, height);
		children = [];
	}

	override public inline function getActualWidth():Int {
		return width != null ? width : (parent != null ? parent.getActualWidth() : 0);
	}

	override public inline function getActualHeight():Int {
		return height != null ? height : (parent != null ? parent.getActualHeight() : 1);
	}

	public function add(child:Widget):Void {
		if (child == null) {
			return;
		}
		if (child.parent != null) {
			child.parent.remove(child);
		}
		child.parent = this;
		children.push(child);
		requestLayout();
		requestRender();
	}

	public function remove(child:Widget):Bool {
		if (child == null) {
			return false;
		}
		var idx = children.indexOf(child);
		if (idx == -1) {
			return false;
		}
		children.splice(idx, 1);
		child.parent = null;
		requestLayout();
		requestRender();
		return true;
	}

	public function clearChildren():Void {
		for (child in children) {
			child.parent = null;
			child.dispose();
		}
		children = [];
		requestLayout();
		requestRender();
	}

	override public function layout():Void {
		for (child in children) {
			if (!child.visible) {
				continue;
			}
			child.layout();
			child.markLaidOut();
		}
		markLaidOut();
	}

	override public function render(buffer:FrameBuffer):Void {
		if (!visible) {
			return;
		}

		var actualWidth = getActualWidth();
		var actualHeight = getActualHeight();
		if (actualWidth > 0 && actualHeight > 0) {
			buffer.fillRect(getGlobalX(), getGlobalY(), actualWidth, actualHeight, " ", Color.WHITE, background);
		}

		for (child in children) {
			if (!child.visible) {
				continue;
			}
			child.render(buffer);
			child.markRendered();
		}
		markRendered();
	}

	public function findLeaf(globalX:Int, globalY:Int):Widget {
		var mn = Type.getClassName(Type.getClass(this));
		Logger.debug('[SGUI] :: ${mn} container findLeaf: gx=$globalX, gy=$globalY');
		Logger.debug('[SGUI] :: ${mn} container bounds: ${getGlobalBounds()}');
		if (!visible || !hitTest(globalX, globalY)) {
			Logger.debug('[SGUI] :: ${mn} container findLeaf: Exited at branch 1 - visible=$visible, hitTest=${hitTest(globalX, globalY)}');
			return null;
		}
		var i = children.length - 1;
		Logger.debug('[SGUI] child count: ${children.length}');
		while (i >= 0) {
			var child = children[i];
			i--;
			if (!child.visible) {
				continue;
			}
			var leaf:Widget = null;
			if (Std.isOfType(child, Container)) {
				Logger.debug('[SGUI] :: ${mn} call child: ${Type.getClassName(Type.getClass(child))} at ${child.getGlobalBounds()}');
				leaf = cast(child, Container).findLeaf(globalX, globalY);
			} else if (child.hitTest(globalX, globalY)) {
				Logger.debug('[SGUI] :: ${mn} child hit: ${Type.getClassName(Type.getClass(child))} at ${child.getGlobalBounds()}');
				leaf = child;
			} else {
				Logger.debug('[SGUI] :: ${mn} child miss: ${Type.getClassName(Type.getClass(child))} at ${child.getGlobalBounds()}');
			}
			if (leaf != null) {
				return leaf;
			}
		}
		return this;
	}

	public function visit(visitor:Widget->Void):Void {
		visitor(this);
		for (child in children) {
			if (Std.isOfType(child, Container)) {
				cast(child, Container).visit(visitor);
			} else {
				visitor(child);
			}
		}
	}
}
