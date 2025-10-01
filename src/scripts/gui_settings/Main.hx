package gui_settings;

import gui_settings.FileManager.FileManagerPage;
import cc_basics.Enums;
import sgui.containers.VerticalContainer;
import sgui.containers.TabContainer;
import cc_basics.Base;
import sgui.SGUI;
import cc_basics.peripherals.Monitor;
import cc_basics.Logger;
import gui_settings.Pages;

class Main {
	public static function main() {
		init();
	}

	public static function asInstaller() {}

	private static function init() {
		var lgm = new Monitor(MonitorTarget.remote(Side.RIGHT));
		lgm.setScale(0.5);
		Logger.setTarget(LoggerTarget.monitor(lgm));
		var monitor = new Monitor();
		var display = new SGUI(monitor);

		var mainLayout = new TabContainer();
		display.root.add(mainLayout);

		var configPageLayout = new VerticalContainer();
		var autoPageLayout = new VerticalContainer();
		var fileManagerLayout = new VerticalContainer();
		var aboutPageLayout = new VerticalContainer();

		mainLayout.addTab("Config", configPageLayout);
		mainLayout.addTab("Auto Completion", autoPageLayout);
		mainLayout.addTab("File Manager", fileManagerLayout);
		mainLayout.addTab("About", aboutPageLayout);
		mainLayout.inactiveColor = Color.LIGHT_BLUE;

		var aboutPage = new AboutPage(aboutPageLayout);
		var fileManagerPage = new FileManagerPage(fileManagerLayout);

		display.startBackgroundUpdate();
		while (true) {
			switch mainLayout.getActiveTabIndex() {
				case 0:

				case 1:

				case 2:
					fileManagerPage.update();

				case 3:
					aboutPage.update();

				case _:
					aboutPage.update();
			}
			Base.sleep0();
		}
	}
}
