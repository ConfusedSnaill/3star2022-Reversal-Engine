package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import gameObjects.Kisser;
import gameObjects.Kissing;
import gameObjects.Obstacle;

class PlayState extends FlxState
{
	var obstacleGrp:FlxTypedGroup<Obstacle>;

	var personL:Kisser;
	var personR:Kisser;
	var kissing:Kissing;

	var sndStretch:FlxSound;
	var txtScore:FlxBitmapText;
	var score:Int = 0;

	// health (default = 3)
	var heartGroup:FlxTypedGroup<FlxSprite>;
	var health:Int = 3;

	override public function create()
	{
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(AssetPaths.kissykiss__ogg, 0.5);

		var bg:RandomBG = new RandomBG(0, 0);
		add(bg);

		heartGroup = new FlxTypedGroup<FlxSprite>();
		add(heartGroup);

		obstacleGrp = new FlxTypedGroup<Obstacle>();
		add(obstacleGrp);

		personL = new Kisser(LEFT);
		personR = new Kisser(RIGHT);
		kissing = new Kissing();

		add(personL);
		add(personR);
		add(kissing);

		FlxG.camera.followLerp = 0.02;

		if (health < 1)
			health = 1;

		// setting up the hearts
		for (i in 0...health)
		{
			var heartSprite:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.heart__png, true, 27, 24);

			// sets animations
			heartSprite.animation.add('idle', [0], 1);
			heartSprite.animation.add('broken', [1], 1);
			heartSprite.animation.play('idle');

			// gives every heart a seperate ID to mess with them individually
			heartSprite.ID = i;

			// moves the current one right beside the last one
			heartSprite.setPosition((28 * i), 3);

			// gives them all a tween effect
			FlxTween.tween(heartSprite.scale, {y: 1.1}, 0.7, {ease: FlxEase.quartInOut, type: PINGPONG});

			// adds them to the group
			heartGroup.add(heartSprite);
		}

		var txtLetters:String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var fontMonospace = FlxBitmapFont.fromMonospace(AssetPaths.font__png, txtLetters, FlxPoint.get(30, 30));

		txtScore = new FlxBitmapText(fontMonospace);
		txtScore.letterSpacing = -8;
		txtScore.autoUpperCase = true;
		txtScore.text = "";
		txtScore.alignment = RIGHT;
		txtScore.x = FlxG.width - 100;
		txtScore.setGraphicSize(Std.int(txtScore.width / 2));
		txtScore.updateHitbox();
		add(txtScore);

		sndStretch = new FlxSound().loadEmbedded(AssetPaths.stretch__ogg);
		FlxG.sound.defaultSoundGroup.add(sndStretch);
		super.create();
	}

	var kissTmr:Float = 0;
	var isKissing:Bool = false;

	var obstacleTmr:Float = 0;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		txtScore.text = Std.string(score);

		// returns to the titlescreen if you die or press the reset button
		if (FlxG.keys.anyJustPressed(ReversalTools.reset) || FlxG.keys.justPressed.ESCAPE || health <= 0)
		{
			FlxG.resetGame();
		}

		// heart animations
		heartGroup.forEach(function(heart:FlxSprite)
		{
			// health - 1 because it starts at 0
			if (heart.ID > (health - 1))
				heart.animation.play('broken');
			else
				heart.animation.play('idle');
		});

		obstacleUpdate();

		var tchBtn:Bool = false;
		var tchP:Bool = false;

		for (tch in FlxG.touches.list)
		{
			if (tch.pressed)
				tchBtn = true;

			if (tch.justPressed)
				tchP = true;
		}

		var btnKiss:Bool = FlxG.keys.pressed.SPACE || FlxG.mouse.pressed || tchBtn;
		var btnKissP:Bool = FlxG.keys.justPressed.SPACE || FlxG.mouse.justPressed || tchP;

		if (btnKissP)
		{
			if (!isKissing)
				sndStretch.play(true, FlxG.random.float(0, 0.2));
		}

		if (btnKiss)
		{
			kissTmr += elapsed;
			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX() + 20, 0.09);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX() - 20, 0.09);
			FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 0.04, 0.09);
		}
		else
		{
			if (sndStretch.playing)
				sndStretch.pause();

			if (kissTmr > 0 && !isKissing)
				kissTmr -= elapsed;

			personL.x = FlxMath.lerp(personL.x, personL.getDefaultX(), 0.7);
			personR.x = FlxMath.lerp(personR.x, personL.getDefaultX(), 0.7);

			if (!isKissing)
				FlxG.sound.music.volume = FlxMath.lerp(FlxG.sound.music.volume, 0.5, 0.4);

			FlxG.camera.scroll.set(0, 0);
		}

		if (kissTmr > 0)
		{
			if (kissTmr > 0.6 || isKissing)
			{
				sndStretch.pause();

				kissing.screenCenter(X);

				FlxG.camera.scroll.y = kissing.y + 20;

				if (!isKissing)
				{
					kissing.y = personL.y;

					var obstacleIsKissed:Bool = false;
					var daObstacle:Obstacle = null;
					var endTimer:Float = 0.9;

					obstacleGrp.forEachAlive(function(obstacle)
					{
						// only get the first one?
						if (daObstacle == null)
							daObstacle = obstacle;
					});

					// if the obstacle is in the middle of the screen when you kiss
					if (daObstacle != null
						&& daObstacle.getGraphicMidpoint().x > FlxG.width * 0.35
						&& daObstacle.getGraphicMidpoint().x < FlxG.width * 0.65)
						obstacleIsKissed = true;

					if (obstacleIsKissed)
					{
						// what each obstacle does
						switch (daObstacle.obType)
						{
							case FULP:
								score += 100;
								kissing.animation.play("tom");
								daObstacle.kill();
								FlxG.sound.play(AssetPaths.sfx_TOMFULP__ogg);
								endTimer = 1.7;

							case CHEESE:
								health -= 1;

								heartGroup.forEach(function(heart:FlxSprite)
								{
									if (heart.ID >= health)
										flixel.effects.FlxFlicker.flicker(heart, 2, 0.02, true);
								});

								FlxG.sound.play(AssetPaths.sfx_rats__ogg);
								kissing.animation.play("cheese");
								daObstacle.kill();

							case BOMB:
								health -= 1;

								heartGroup.forEach(function(heart:FlxSprite)
								{
									if (heart.ID >= health)
										flixel.effects.FlxFlicker.flicker(heart, 2, 0.02, true);
								});

								FlxG.sound.play(AssetPaths.sfx_bombxplode__ogg);
								kissing.animation.play("bomb");
								daObstacle.kill();
						}
					}
					else
					{
						if (personL.y < personR.y - 20)
						{
							score += 100;

							kissing.animation.play("head");
							FlxG.sound.play(AssetPaths.sfx_kiss_headding__ogg);
							FlxG.sound.play(AssetPaths.sfx_kiss_default__ogg);
						}
						else if (personL.y > personR.y + 20)
						{
							score += 500;

							kissing.animation.play("body");
							FlxG.sound.play(AssetPaths.sfx_kiss_default__ogg);
							FlxG.sound.play(AssetPaths.sfx_kiss_neckscream__ogg);
						}
						else
						{
							score += 1000;

							kissing.animation.play("idle");
							FlxG.sound.play(AssetPaths.sfx_kiss_onlips__ogg);
						}
					}

					new FlxTimer().start(endTimer, function(_)
					{
						isKissing = false;
						kissTmr = 0;

						personL.regenTween();
						personR.regenTween();
					});
				}

				isKissing = true;
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, isKissing ? 1.3 : 1, 0.1);

		personL.visible = personR.visible = !isKissing;
		kissing.visible = isKissing;
	}

	function obstacleShit() {}

	var rndObCheck:Float = 10;

	function obstacleUpdate()
	{
		obstacleTmr += FlxG.elapsed;

		if (obstacleTmr >= rndObCheck)
		{
			var obstacle:Obstacle = new Obstacle();
			obstacleGrp.add(obstacle);

			obstacleTmr = 0;
			rndObCheck = FlxG.random.float(8, 13);
		}
	}
}

class RandomBG extends FlxSprite
{
	public function new(xPos, yPos)
	{
		super(xPos, yPos);
		loadGraphic("assets/images/backgrounds/bg" + FlxG.random.int(1, 3) + ".png", true, 300, 177);
		animation.add("idle", [0, 1, 2], 6);
		animation.play("idle");
		scrollFactor.set();

		FlxTween.tween(this, {y: -7}, 1.6, {ease: FlxEase.circInOut, type: PINGPONG});
	}
}
