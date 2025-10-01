package gui_settings;

import cc_basics.Logger;
import sgui.widgets.Input;
import sgui.core.UtilChars;
import sgui.widgets.Button;
import sgui.containers.HorizontalContainer;
import cc_basics.Enums;
import sgui.widgets.Label;
import sgui.containers.VerticalContainer;
import haxe.io.Path;

class FileManagerPage {
	private var layout:VerticalContainer;
	private var currentPath:Path;

	private var pathInput:Input;
	private var statLabel:Label;
	private var operationsContainer:HorizontalContainer;

	public function new(layout:VerticalContainer) {
		this.layout = layout;
		this.currentPath = new Path("/");

		this.pathInput = new Input(20);
		this.pathInput.text = "123123";

		this.pathInput.background = Color.CYAN;
		this.layout.add(this.pathInput);
		this.pathInput.placeholder = this.currentPath.toString();

		this.statLabel = new Label('[ ${this.currentPath.toString()} ] N/A of N/A available', LabelWidth.block);
		this.statLabel.background = Color.PURPLE;
		this.layout.add(this.statLabel);

		this.operationsContainer = new HorizontalContainer();
		this.operationsContainer.spacing = 1;
		this.operationsContainer.add(new Button(String.fromCharCode(UtilChars.LEFT_ARROW), 3));
		this.layout.add(operationsContainer);
	}

	public function update() {}
}
