package fmt_example;

import cc_basics.Base;
import fmt.Manager;

class Main {
	private static var variable:Int = 0;

	private static function task1() {
		Base.sleep(3);
		Base.print("Task 1 done - ", Base.clock());
		variable *= 2;
	}

	private static function task2() {
		Base.sleep(5);
		Base.print("Task 2 done - ", Base.clock());
		variable *= 3;
	}

	public static function main() {
		Base.print("Hello world!");
		ThreadManager.add(task1);
		ThreadManager.add(task2);
		ThreadManager.start();
		while (true) {
			Base.print("Main - doing something - ", Base.clock(), " - ", variable);
			Base.sleep(1);
			variable++;
		}
	}
}
