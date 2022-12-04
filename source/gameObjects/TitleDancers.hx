package gameObjects;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class TitleDancers extends FlxSprite
{
	public function new(xPos, yPos)
	{
		super(xPos, yPos);

		// loading sprites
		loadGraphic(AssetPaths.title__png, true, 240, 180);
		animation.add("idle", [0, 1, 2], 6);
		animation.play("idle");

		// spinning lol
		FlxTween.tween(this, {y: y + 10}, 1, {ease: FlxEase.quartInOut, type: PINGPONG});
		FlxTween.tween(scale, {x: -1}, 1, {ease: FlxEase.quartInOut, type: PINGPONG, loopDelay: 0.8});

		visible = false;
	}
}
