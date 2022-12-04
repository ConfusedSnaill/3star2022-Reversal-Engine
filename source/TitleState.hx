package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.TitleDancers;

class TitleState extends FlxState
{
	// if the intro is playing or not
	var canSwitch:Bool = false;

	// for the "skipIntro" function
	var logo:FlxSprite;
	var txt:FlxBitmapText;
	var chars:TitleDancers;
	var bg:FlxSprite;
	var introTween:FlxTween;

	override function create()
	{
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.visible = false;
		add(bg);

		chars = new TitleDancers(30, 0);
		add(chars);

		logo = new FlxSprite(125.5, -65).loadGraphic(AssetPaths.logo__png);
		add(logo);

		FlxG.mouse.visible = false;

		var txtLetters:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var fontMonospace = FlxBitmapFont.fromMonospace(AssetPaths.font__png, txtLetters, FlxPoint.get(30, 30));

		FlxG.sound.play(AssetPaths.sfx_rats__ogg);

		var gameCredits:String = "game by\ndigimin\npankakidaan\nninjamuffin99\nr3tronaut";

		introTween = FlxTween.tween(logo, {y: (FlxG.height / 2) - (logo.height / 2), angle: 360 * 2}, 6, {
			onComplete: _ ->
			{
				if (canSwitch == false)
				{
					bg.visible = true;
					logo.visible = false;

					txt = new FlxBitmapText(fontMonospace);
					txt.letterSpacing = -9;

					txt.setGraphicSize(Std.int(txt.width * 0.5));
					txt.updateHitbox();

					txt.autoUpperCase = true;

					txt.text = gameCredits;

					txt.alignment = CENTER;
					txt.screenCenter();
					txt.color = 0xFF0000FF;
					add(txt);

					FlxG.sound.play(AssetPaths.sfx_kiss_headding__ogg);

					new FlxTimer().start(0.9, _ ->
					{
						skipIntro();
					});
				}
			}
		});

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		// starting the game
		if ((FlxG.keys.anyJustPressed(ReversalTools.accept) || FlxG.mouse.justPressed) && canSwitch)
		{
			canSwitch = false;
			ReversalTools.startGame();
		}
		else if ((FlxG.keys.anyJustPressed(ReversalTools.accept) || FlxG.mouse.justPressed) && !canSwitch && txt == null)
		{
			skipIntro();
		}

		// closing the game
		if (FlxG.keys.justPressed.ESCAPE)
		{
			ReversalTools.closeGame();
		}

		// resetting
		if (FlxG.keys.anyJustPressed(ReversalTools.reset))
			FlxG.resetGame();

		super.update(elapsed);
	}

	function skipIntro()
	{
		remove(txt);

		introTween.cancel();
		canSwitch = true;
		logo.visible = true;
		bg.visible = true;

		logo.y = (FlxG.height / 2) - (logo.height / 2);

		FlxG.sound.play(AssetPaths.sfx_kiss_onlips__ogg);
		FlxG.sound.playMusic(AssetPaths.kissykiss__ogg, 0);
		FlxG.sound.music.fadeIn(3, 0, 0.9);

		FlxG.camera.flash(FlxColor.WHITE, 4);
		logo.setGraphicSize(Std.int(logo.width * 2));
		logo.updateHitbox();
		logo.setPosition(101, 3.4);
		logo.angle = -30;

		FlxTween.tween(logo, {angle: 30}, 0.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		chars.visible = true;
	}
}
