package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class ReversalTools
{
	// controls
	public static var accept:Array<FlxKey> = [ENTER, SPACE];
	public static var reset:Array<FlxKey> = [R, BACKSPACE];

	public static function startGame()
	{
		FlxG.sound.music.fadeOut(0.5, 0.5);

		FlxG.camera.fade(0xffffff, 0.5, false, () ->
		{
			FlxG.switchState(new PlayState());
		});
	}

	public static function closeGame()
	{
		FlxG.camera.fade(0xffffff, 0.5, false, () ->
		{
			lime.system.System.exit(0);
		});
	}
}
