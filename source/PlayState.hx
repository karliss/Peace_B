package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

class PlayState extends FlxState {
	public var level:TiledLevel;
	public var score:FlxText;
	public var status:FlxText;
	public var coins:FlxGroup;
	public var player:FlxSprite;
	public var floor:FlxObject;
	public var exit:FlxSprite;
	public var input:Input = new Input();

	static var youDied:Bool = false;

	override public function create():Void {
		FlxG.mouse.visible = false;

		bgColor = 0xffaaaaaa;

		// Load the level's tilemaps
		coins = new FlxGroup();
		level = new TiledLevel("assets/tiled/test_map.tmx", this);

		// Add backgrounds
		add(level.backgroundLayer);

		// Draw coins first
		add(coins);

		// Add static images
		add(level.imagesLayer);

		add(level.carpetLayer);
		add(level.foldedCarpetLayer);
		add(level.wallLayer);

		// Load player objects
		add(level.objectsLayer);

		// Create UI
		score = new FlxText(2, 2, 80);
		score.scrollFactor.set(0, 0);
		score.borderColor = 0xff000000;
		score.borderStyle = SHADOW;
		score.text = "SCORE: " + (coins.countDead() * 100);
		add(score);

		status = new FlxText(FlxG.width - 160 - 2, 2, 160);
		status.scrollFactor.set(0, 0);
		status.borderColor = 0xff000000;
		score.borderStyle = SHADOW;
		status.alignment = RIGHT;
		status.text = youDied ? "Aww, you died!" : "Collect coins.";
		add(status);
	}

	override public function update(elapsed:Float):Void {
		input.update();

		player.acceleration.x = 0;
		player.acceleration.y = 0;

		if (input.directionLeft) {
			player.acceleration.x -= player.maxVelocity.x * 4;
		}
		if (input.directionRight) {
			player.acceleration.x += player.maxVelocity.x * 4;
		}
		if (input.directionUp) {
			player.acceleration.y -= player.maxVelocity.y * 4;
		}
		if (input.directionDown) {
			player.acceleration.y += player.maxVelocity.y * 4;
		}
		super.update(elapsed);

		if (Math.abs(player.velocity.x) > 0.1 || Math.abs(player.velocity.y) > 0.1) {
			player.animation.play("walk");
		} else {
			player.animation.play("idle");
		}
		FlxG.overlap(coins, player, getCoin);

		// Collide with foreground tile layer
		level.collideWithLevel(player);

		// FlxG.overlap(exit, player, win);
	}

	public function win(Exit:FlxObject, Player:FlxObject):Void {
		status.text = "Yay, you won!";
		score.text = "SCORE: 5000";
		player.kill();
	}

	public function getCoin(Coin:FlxObject, Player:FlxObject):Void {
		Coin.kill();
		score.text = "SCORE: " + (coins.countDead() * 100);
		if (coins.countLiving() == 0) {
			status.text = "Find the exit";
			exit.exists = true;
		}
	}
}
