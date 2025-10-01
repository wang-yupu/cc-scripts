package gui_settings;

import sgui.widgets.Label;
import sgui.containers.VerticalContainer;
import meta.Meta;

class AboutPage {
	private var layout:VerticalContainer;

	public function new(layout:VerticalContainer) {
		this.layout = layout;
		this.layout.add(new Label('GUI-Settings script version ${Meta.getVersionString()}'));
	}

	public function update() {}
}
