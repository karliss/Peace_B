package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

class PlayState extends FlxState {
	public var level:TiledLevel;
	public var score:FlxText;
	public var status:FlxText;
	public var coins:FlxGroup;
	public var player:Player;
	public var floor:FlxObject;
	public var exit:FlxSprite;
	public var input:Input = new Input();
	public var helpers:FlxTypedGroup<Player> = new FlxTypedGroup<Player>();

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

	function applyControls(player:Player) {
		if (input.directionLeft) {
			player.addMove(Player.Direction.Left);
		}
		if (input.directionRight) {
			player.addMove(Player.Direction.Right);
		}
		if (input.directionUp) {
			player.addMove(Player.Direction.Up);
		}
		if (input.directionDown) {
			player.addMove(Player.Direction.Down);
		}

		if (input.confirmPressed) {
			if (player.object == null) {
				player.pickupPlayer(this);
			} else {
				player.placePlayer(this);
			}
		}
	}

	override public function update(elapsed:Float):Void {
		input.update();

		applyControls(player);
		for (helper in helpers) {
			// applyControls(helper);
		}

		super.update(elapsed);

		FlxG.overlap(coins, player, getCoin);

		// Collide with foreground tile layer
		level.collideWithLevel(player);
		for (helper in helpers) {
			level.collideWithLevel(helper);
		}

		// FlxG.overlap(exit, player, win);
	}

	public function pickup(x:Int, y:Int):TiledLevel.PickableProperties {
		trace("doing pickup");
		var p = player.getMidpoint();
		var pickedObject:TiledLevel.PickableProperties = null;
		if (level.wallTiles.getTile(x, y) != 0) {
			trace("picked wall");
			pickedObject = level.idToPropertiesMap.get(level.wallTiles.getTile(x, y));
			level.wallTiles.setTile(x, y, 0);
		} else if (level.foldedCarpetTiles.getTile(x, y) != 0) {
			trace("picked folded carpet");
			pickedObject = level.idToPropertiesMap.get(level.foldedCarpetTiles.getTile(x, y));
			level.foldedCarpetTiles.setTile(x, y, 0);
		} else if (level.carpetTiles.getTile(x, y) != 0) {
			trace("picked carpet");
			pickedObject = level.idToPropertiesMap.get(level.carpetTiles.getTile(x, y));
			trace(pickedObject);
			level.carpetTiles.setTile(x, y, 0);
		}
		return pickedObject;
	}

	public function place(x:Int, y:Int, object:TiledLevel.PickableProperties):Bool {
		if (object.isWall) {
			if (level.wallTiles.getTile(x, y) == 0) {
				trace("put wall");
				level.wallTiles.setTile(x, y, object.idOnPickup);
				return true;
			}
		} else if (object.isCarpet || object.isFoldedCarpet) {
			if (level.carpetTiles.getTile(x, y) == 0) {
				trace("put carpet");
				level.carpetTiles.setTile(x, y, object.idOnPickup);
				return true;
			}
		}
		return false;
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
