import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Achievement save tag, Hidden achievement
		//CC ACHIEVEMENTS
		["Employee of the Month",	"Beat the Cardboard Crusher week on Hard with no misses.",	'cc_hard_nomiss',	true],
		["Employee of the Year",	"Beat the Cardboard Crusher week on Erect with no misses.",	'cc_erect_nomiss',	true],
		["Overtime Aficionado",		"Beat the bonus week with no misses.",						'cc_bonus_nomiss',	true],
		["Shining Example",			"Fill every bean in 7 Pallet Load.",						'cc_allbeans',		true],
		["Pinnacle of Terrible",	"Miss every bean in 7 Pallet load.",						'cc_nobeans',		true],
		["Malfunction",				"Beat Fired.",												'cc_fired',			true],
		["Shoplifter",				"Destroy the Cardboard Crusher in Stick-Up.",				'cc_iskill',		true],
		["Pacifist",				"Don't harm the Cardboard Crusher in Stick-Up.",			'cc_islive',		true],
		["Bale'd",					"Die to a bale in either Bale or Fired.",					'cc_bale_1',		true],
		["Diagnosis: Skill Issue",	"Die to a bale 50 times in either Bale or Fired.",			'cc_bale_50',		true],
		["Please go outside.",		"Die to a bale 500 times in either Bale or Fired.",			'cc_bale_500',		true],
		["What.. even?",			"Discover the Baby",										'cc_baby',			true],

		["Freaky on a Friday Night",	"Play on a Friday... Night.",						'friday_night_play',	true],
		["She Calls Me Daddy Too",		"Beat Week 1 on Hard with no Misses.",				'week1_nomiss',			true],
		["No More Tricks",				"Beat Week 2 on Hard with no Misses.",				'week2_nomiss',			true],
		["Call Me The Hitman",			"Beat Week 3 on Hard with no Misses.",				'week3_nomiss',			true],
		["Lady Killer",					"Beat Week 4 on Hard with no Misses.",				'week4_nomiss',			true],
		["Missless Christmas",			"Beat Week 5 on Hard with no Misses.",				'week5_nomiss',			true],
		["Highscore!!",					"Beat Week 6 on Hard with no Misses.",				'week6_nomiss',			true],
		["God Effing Damn It!",			"Beat Week 7 on Hard with no Misses.",				'week7_nomiss',			true],
		["Roadkill Enthusiast",			"Watch the Henchmen die over 100 times.",			'roadkill_enthusiast',	true],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",	'debugger',				true],

		["What a Funkin' Disaster!",	"Complete a Song with a rating lower than 20%.",	'ur_bad',				false],
		["Perfectionist",				"Complete a Song with a rating of 100%.",			'ur_good',				false],
		["Oversinging Much...?",		"Hold down a note for 10 seconds.",					'oversinging',			false],
		["Hyperactive",					"Finish a Song without going Idle.",				'hype',					false],
		["Just the Two of Us",			"Finish a Song pressing only two keys.",			'two_keys',				false],
		["Toaster Gamer",				"Have you tried to run the game on a toaster?",		'toastie',				false]

	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static var henchmenDeath:Int = 0;

	// CC ACHIEVEMENT VARS
	public static var ccHardNoMiss:Bool = false;
	public static var ccErectNoMiss:Bool = false;
	public static var ccBonusNoMiss:Bool = false;
	public static var ccFiredWin:Bool = false;
	public static var ccAllBeans:Bool = false;
	public static var ccNoBeans:Bool = true;
	public static var ccCrusherHit:Bool = false;
	public static var ccCrusherKill:Bool = false;
	public static var ccBabyFind:Bool = false;
	public static var ccBalesHit:Int = 0;

	


	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String) {
		for (i in 0...achievementsStuff.length) {
			if(achievementsStuff[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsMap != null) {
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	private var tag:String;
	public function new(x:Float = 0, y:Float = 0, name:String) {
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String) {
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage() {
		if(Achievements.isAchievementUnlocked(tag)) {
			loadGraphic(Paths.image('achievements/' + tag));
		} else {
			loadGraphic(Paths.image('achievements/lockedachievement'));
		}
		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievements/' + name));
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
		achievementName.setFormat(Paths.font("calibri-regular.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
		achievementText.setFormat(Paths.font("calibri-regular.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}