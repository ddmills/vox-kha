package;

import kha.Window;
import kha.Assets;
import kha.Scheduler;
import kha.System;

class Main
{
	static function update():Void
	{
		trace('meeep');
	}

	public static function main()
	{
		System.start({title: "Project", width: 1024, height: 768}, init);
	}

	static function init(window:Window)
	{
		var game = new Game();

		Assets.loadEverything(() ->
		{
			trace('Assets loaded.');
			Scheduler.addTimeTask(game.update, 0, 1 / 60);
			System.notifyOnFrames(game.render);
		});
	}
}
