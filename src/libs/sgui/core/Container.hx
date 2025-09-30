package sgui.core;

import sgui.core.FrameBuffer;
import sgui.core.Widget;

class Container extends Widget {
	public var children(default, null):Array<Widget>;
	public var clipContent:Bool = false;

	public function new(width:Int = 0, height:Int = 0) {
		super(width, height);
		children = [];
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
		if (!visible || !hitTest(globalX, globalY)) {
			return null;
		}
		var i = children.length - 1;
		while (i >= 0) {
			var child = children[i];
			i--;
			if (!child.visible) {
				continue;
			}
			var leaf:Widget = null;
			if (Std.isOfType(child, Container)) {
				leaf = cast(child, Container).findLeaf(globalX, globalY);
			} else if (child.hitTest(globalX, globalY)) {
				leaf = child;
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
