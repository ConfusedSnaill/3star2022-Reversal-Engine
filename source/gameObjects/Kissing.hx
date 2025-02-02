package gameObjects;

import flixel.FlxSprite;

class Kissing extends FlxSprite
{
	public function new()
	{
		super();

		loadGraphic(AssetPaths.kissingSheet__png, true, Std.int(720 / 3), 180);
		animation.add("idle", [0, 1, 2], 12);
		animation.add("head", [3, 4, 5], 12);
		animation.add("tom", [6, 7, 8], 12);
		animation.add("body", [9, 10, 11], 12);
		animation.add("bomb", [12, 13, 14], 12);
		animation.add("cheese", [15, 16, 17], 12);
		animation.play("idle");
	}
}
