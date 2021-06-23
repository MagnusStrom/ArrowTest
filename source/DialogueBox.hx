package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;


	public var finishThing:Void->Void;

	var portraitSpider:FlxSprite;
	var portraitLeft:FlxSprite;
	var portraitLeftMad:FlxSprite;
	var portraitLeftScared:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 1;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 1;
			if (bgFade.alpha > 1)
				bgFade.alpha = 1;
		}, 5);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'berzerker', 'possession', 'takeover':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);//speech bubble normal
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		// this shouldnt be too laggy
		portraitSpider = new FlxSprite(125, 170);
		portraitSpider.loadGraphic(Paths.image("demontext"));
		portraitSpider.setGraphicSize(Std.int(portraitSpider.width * PlayState.daPixelZoom * 0.145));
		portraitSpider.updateHitbox();
		portraitSpider.scrollFactor.set();
		add(portraitSpider);
		portraitSpider.visible = false;

		portraitLeft = new FlxSprite(-50, 50);
		portraitLeft.loadGraphic(Paths.image('casstext'));
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.2));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;
	
		portraitLeftMad = new FlxSprite(-50, 50);
		portraitLeftMad.loadGraphic(Paths.image('casstextMAD'));
		portraitLeftMad.setGraphicSize(Std.int(portraitLeftMad.width * PlayState.daPixelZoom * 0.2));
		portraitLeftMad.updateHitbox();
		portraitLeftMad.scrollFactor.set();
		add(portraitLeftMad);
		portraitLeftMad.visible = false;

		portraitLeftScared = new FlxSprite(-50, 50);
		portraitLeftScared.loadGraphic(Paths.image('casstextOHSHIT'));
		portraitLeftScared.setGraphicSize(Std.int(portraitLeftScared.width * PlayState.daPixelZoom * 0.2));
		portraitLeftScared.updateHitbox();
		portraitLeftScared.scrollFactor.set();
		add(portraitLeftScared);
		portraitLeftScared.visible = false;

		portraitRight = new FlxSprite(750, 250);
		portraitRight.loadGraphic(Paths.image('bftext'));
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.08));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.15));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		box.y += 400;
		//portraitLeft.screenCenter(X);

	//	handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
//		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}


		swagDialogue = new FlxTypeText(240, 550, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.setFormat(Paths.font("Party-Crasherz-PG.otf"), 32, FlxColor.BLACK);
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
		}


		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		portraitLeft.visible = false;
		portraitLeftMad.visible = false;
		portraitLeftScared.visible = false;
		portraitRight.visible = false;
		portraitSpider.visible = false;
		switch (curCharacter)
		{
			case 'cass':
				box.flipX = true;
				portraitLeft.visible = true;
			case 'bf':
				box.flipX = false;
				portraitRight.visible = true;
			case 'spider':
				box.flipX = true;
				portraitSpider.visible = true;
			case 'cass-angry':
				box.flipX = true;
				portraitLeftMad.visible = true;
			case 'cass-scared':
				box.flipX = true;
				portraitLeftScared.visible = true;
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
