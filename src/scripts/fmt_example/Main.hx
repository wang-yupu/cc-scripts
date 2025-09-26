package fmt_example;

import cc_basics.Base;
import fmt.Manager;

class Main {
	private static function task1() {
		Base.sleep(3);
		Base.print("Task 1 done", Base.clock());
	}

	private static function task2() {
		Base.sleep(5);
		Base.print("Task 2 done", Base.clock());
	}

	public static function main() {
		Base.print("Hello world!");
		ThreadManager.add(task1);
		ThreadManager.add(task2);
		ThreadManager.start();
		while (true) {
			Base.print("Main - doing something");
			Base.sleep(1);
		}
	}
}
