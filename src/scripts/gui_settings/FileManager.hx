package gui_settings;

import haxe.Exception;
import cc_basics.Base;
import sgui.SGUI;
import cc_basics.Logger;
import sgui.widgets.Input;
import sgui.core.UtilChars;
import sgui.widgets.Button;
import sgui.containers.HorizontalContainer;
import cc_basics.Enums;
import sgui.widgets.Label;
import sgui.containers.VerticalContainer;
import haxe.io.Path;
import cc_basics.fio.FIO;
import cc_basics.Shell;

class FileManagerPage {
	private var layout:VerticalContainer;
	private var disp:SGUI;
	private var currentPath:Path;

	private var pathInputContainer:HorizontalContainer;
	private var pathInput:Input;
	private var pathInputErrorHighlightTime:Int = 0;
	private var statLabel:Label;
	private var operationsContainer:HorizontalContainer;

	private var mainView:HorizontalContainer;
	private var fileDisplay:VerticalContainer;
	private var fileOperationsContainer:VerticalContainer;

	private var selectedFileLabel:Label;
	private var selectedFileStatLabel:Label;

	private var selectedFile:String = null;

	private var delete:Button;

	public function new(layout:VerticalContainer, disp:SGUI) {
		this.layout = layout;
		this.disp = disp;
		this.currentPath = new Path("/");

		// 路径输入
		this.pathInputContainer = new HorizontalContainer();
		this.pathInput = new Input();
		this.pathInput.background = Color.CYAN;
		this.pathInput.placeholder = this.currentPath.toString();
		this.pathInput.text = this.currentPath.toString();
		this.pathInput.onSubmit = this.onSubmitPath;

		var toParentButton = new Button(String.fromCharCode(UtilChars.LEFT_FILLED_ARROW), 3);
		toParentButton.onClick = this.toParent;
		this.pathInputContainer.add(toParentButton);
		this.pathInputContainer.add(this.pathInput);

		this.layout.add(pathInputContainer);
		// 操作栏
		this.operationsContainer = new HorizontalContainer();
		this.operationsContainer.spacing = 0;

		this.statLabel = new Label('[ N/A ] N/A of N/A available', LabelWidth.block);
		this.statLabel.background = Color.PURPLE;
		this.operationsContainer.add(this.statLabel);

		this.layout.add(operationsContainer);

		this.mainView = new HorizontalContainer(this.layout.getActualWidth());

		var focWidth = 20;
		this.fileDisplay = new VerticalContainer(this.layout.getActualWidth() - focWidth, null, true);
		this.fileOperationsContainer = new VerticalContainer(focWidth);

		// 文件操作
		this.selectedFileLabel = new Label("N/A", LabelWidth.block, WrapMode.Char);
		this.selectedFileLabel.background = Color.LIME;
		this.fileOperationsContainer.add(selectedFileLabel);

		var access = new Button("Access", focWidth);
		access.background = Color.LIGHT_BLUE;
		access.onClick = this.aceessCurrentFile;

		var open = new Button("run edit", focWidth);
		open.background = Color.BLUE;
		open.onClick = this.runEditWithCurrentFile;

		this.delete = new Button("Delete", focWidth);
		this.delete.background = Color.RED;
		this.delete.onClick = this.deleteCurrentFile;

		this.fileOperationsContainer.add(access);
		this.fileOperationsContainer.add(open);
		this.fileOperationsContainer.add(this.delete);

		this.selectedFileStatLabel = new Label("Select a file");
		this.fileOperationsContainer.add(selectedFileStatLabel);

		this.layout.add(this.mainView);

		this.mainView.add(this.fileDisplay);
		this.mainView.add(this.fileOperationsContainer);

		this.lazyUpdate();
	}

	private function resetSelect() {
		this.firstClickDelete = false;
		this.selectedFile = null;
		this.selectedFileLabel.text = "N/A";
		this.selectedFileStatLabel.text = "Select a file";
		this.delete.text = "Delete";
	}

	private function toParent() {
		Logger.info("123123");
		var dir = Path.directory(this.currentPath.toString());

		if (dir == "") {
			dir = "/";
		}
		this.currentPath = new Path(dir);
		this.resetSelect();
		this.lazyUpdate();
	}

	private function aceessCurrentFile() {
		if (this.selectedFile == null) {
			return;
		}

		var p:FIO = new FIO(Path.join([Path.addTrailingSlash(this.currentPath.toString()), this.selectedFile]));
		if (!p.isDir() || !p.exists()) {
			return;
		}
		this.currentPath = new Path(p.toString());

		this.resetSelect();
		this.lazyUpdate();
	}

	private function runEditWithCurrentFile() {
		if (this.selectedFile == null) {
			return;
		}
		Shell.switchTab(Shell.openTab("edit", Path.join([this.currentPath.toString(), this.selectedFile]).toString()));
	}

	private var firstClickDelete:Bool = false;

	private function deleteCurrentFile() {
		if (this.selectedFile == null) {
			return;
		}
		var p:FIO = new FIO(Path.join([Path.addTrailingSlash(this.currentPath.toString()), this.selectedFile]));
		if (p.isReadonly()) {
			this.delete.text = "READONLY!";
			return;
		} else {
			if (this.firstClickDelete) {
				// delete
				var r = p.delete();
				if (!r) {
					this.delete.text = "Failed :(";
					return;
				}
				this.resetSelect();
				this.lazyUpdate();
			} else {
				this.delete.text = "Click again";
				this.firstClickDelete = true;
			}
		}
	}

	private function onSubmitPath(n:String) {
		var nf = new FIO(n);
		if (nf.exists() && nf.isDir()) {
			this.currentPath = new Path(n);
			Logger.info("Correct path: ", n);
			this.lazyUpdate();
		} else if (nf.exists() && !nf.isDir()) {
			this.pathInput.background = Color.ORANGE;
			this.pathInputErrorHighlightTime = 3;
			Logger.error("Not a dir!");
		} else {
			this.pathInput.background = Color.RED;
			this.pathInputErrorHighlightTime = 5;
			Logger.error("Bad path!");
		}
	}

	public function lazyUpdate() {
		var currentDir = new FIO(this.currentPath);
		this.pathInput.text = Path.addTrailingSlash(this.currentPath.toString());
		if (!currentDir.exists()) {
			return;
		}
		if (!currentDir.isDir()) {
			return;
		}
		var space = currentDir.spaceStatus();

		var usedPerctange = 1 - (space.available / space.total);

		this.statLabel.text = '[ ${currentDir.driveOf()} ] ${toReadableSize(space.available)} of ${toReadableSize(space.total)} used (${Std.int(usedPerctange * 100)}%) ${currentDir.isReadonly() ? "(READONLY)" : ""}';
		this.fileDisplay.clearChildren();
		var list = currentDir.ls();
		var drive = currentDir.driveOf();
		for (fod in list) {
			var l:Button = new Button(fod.getFile());
			l.align = 0;
			l.background = Color.BLACK;
			l.foreground = Color.WHITE;
			if (fod.isDir()) {
				l.foreground = Color.GREEN;
				if (fod.driveOf() != drive) {
					l.text = '${fod.getFile()} => ${fod.driveOf()}';
					l.foreground = Color.MAGENTA;
				}
			} else {
				if (fod.getExtension() == "lua") {
					l.foreground = Color.CYAN;
				}
			}

			var click = function() {
				if (this.selectedFile == fod.getFile() && fod.isDir()) {
					this.aceessCurrentFile();
				}
				this.selectedFile = fod.getFile();
				var attr = fod.attrs();
				if (!attr.isDir) {
					var sizeText = "";
					if (attr.size != null) {
						sizeText = toReadableSize(attr.size);
					} else {
						sizeText = "N/A";
					}
					var modified = Base.toReadableTime(Std.int(attr.modified / 1000));
					var created = Base.toReadableTime(Std.int(attr.created / 1000));
					this.selectedFileStatLabel.text = 'Size:\n${sizeText}\nModified:\n${modified}\nCreated:\n${created}\nReadonly:\n${attr.isReadOnly ? 'yes' : 'no'}';
				} else {
					this.selectedFileStatLabel.text = 'Readonly:\n${attr.isReadOnly ? 'yes' : 'no'}';
				}
				this.selectedFileLabel.text = this.selectedFile;
				this.firstClickDelete = false;
				this.delete.text = "Delete";
			}

			l.onClick = click;

			this.fileDisplay.add(l);
		}
	}

	public function update() {
		if (this.pathInputErrorHighlightTime != 0) {
			this.pathInputErrorHighlightTime--;
		} else {
			this.pathInput.background = Color.CYAN;
		}
	}
}
