package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.input.mouse.FlxMouseButton;
import flixel.input.mouse.FlxMouse;


using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var menuItem:FlxSprite;	
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var hoverSelected:Int;
	var computerArea:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = true;

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var computerArea = new FlxSprite(-200,-260);
		computerArea.makeGraphic(400, 430, FlxColor.WHITE);
		add(computerArea);
		computerArea.updateHitbox();

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.scale.set(0.5, 0.5);
		bg.y -= 90;
		bg.updateHitbox();
		bg.screenCenter(X);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.7;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			switch(i) {
				case 0:
					menuItem.setPosition(473, 246); //story
				case 1:
					menuItem.setPosition(853, 160); //freeplay
				case 2:
					menuItem.setPosition(930, 303); //awards
				case 3:
					menuItem.setPosition(60, 434); //credits
				case 4:
					menuItem.setPosition(37.5, 185); //options
			}
		}
		
		var optText:FlxSprite;
		
		switch(FlxG.random.int(0, 4)) {
    		case 0:
        		optText = new FlxSprite(-650, -150).loadGraphic(Paths.image('optText1'));
				add(optText);
				optText.scale.x = 0.45;
				optText.scale.y = 0.45;
    		case 1:
        		optText = new FlxSprite(-650, -150).loadGraphic(Paths.image('optText2'));
				add(optText);
				optText.scale.x = 0.45;
				optText.scale.y = 0.45;
			case 2:
				optText = new FlxSprite(-650, -150).loadGraphic(Paths.image('optText3'));
				add(optText);
				optText.scale.x = 0.45;
				optText.scale.y = 0.45;
			case 3:
				optText = new FlxSprite(-650, -150).loadGraphic(Paths.image('optText4'));
				add(optText);
				optText.scale.x = 0.45;
				optText.scale.y = 0.45;
			case 4:
				optText = new FlxSprite(-560, -90).loadGraphic(Paths.image('optText5'));
				add(optText);
				optText.scale.x = 0.45;
				optText.scale.y = 0.45;
				//37.5, 230
			optText.updateHitbox();
			//optText.screenCenter(XY);
			}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		//var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		//camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else if (curSelected != -1)
				{	
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							// FlxTween.tween(spr, {alpha: 0}, 0.4, {
							// 	ease: FlxEase.quadOut,
							// 	onComplete: function(twn:FlxTween)
							// 	{
							// 		spr.kill();
							// 	}
							// });
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
	
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (FlxG.mouse.overlaps(spr)) {
				hoverSelected = spr.ID;
				curSelected = -1;

				spr.animation.play('selected');
				
				if (!selectedSomethin)
				{		

					if (FlxG.mouse.justPressed) {
							
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						switch (hoverSelected) {						
							case 0:
								MusicBeatState.switchState(new StoryMenuState());
							case 1:
								MusicBeatState.switchState(new FreeplayState());
							case 2:
								MusicBeatState.switchState(new AchievementsMenuState());
							case 3:
								MusicBeatState.switchState(new CreditsState());
							case 4:
								LoadingState.loadAndSwitchState(new options.OptionsState());
						}
					}
				}
			}
			else if (!FlxG.mouse.overlaps(spr) && spr.ID != curSelected) {
				spr.animation.play('idle');
			}
		});

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			//spr.updateHitbox();
			spr.scale.x = 0.5;
			spr.scale.y = 0.5;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				// var add:Float = 0;
				// if(menuItems.length > 4) {
				// 	add = menuItems.length * 8;
				// }
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				// spr.centerOffsets();
			}
		});
	}
}
