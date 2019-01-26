package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

enum PickedObject {
	NONE;
	CARPET;
	MAIN_CARPET;
	SPECIAL_CARPET;
	WALL;
}

class PlayState extends FlxState {
	public var level:TiledLevel;
	public var score:FlxText;
	public var status:FlxText;
	public var coins:FlxGroup;
	public var player:Player;
	public var floor:FlxObject;
	public var exit:FlxSprite;
	public var input:Input = new Input();

	static var pickedObject:PickedObject = NONE;
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

		if (input.directionLeft) {
			player.setMove(Player.Direction.Left);
		}
		if (input.directionRight) {
			player.setMove(Player.Direction.Right);
		}
		if (input.directionUp) {
			player.setMove(Player.Direction.Up);
		}
		if (input.directionDown) {
			player.setMove(Player.Direction.Down);
		}

		if (input.confirmPressed) {
			var p = player.getMidpoint();
			var x:Int = Math.floor(p.x / 32);
			var y:Int = Math.floor(p.y / 32);
			if (pickedObject == NONE) {
				if (input.directionDown ||
					input.directionUp ||
					input.directionLeft ||
					input.directionRight) {
					// Player wants to pick a wall in that direction
					if (input.directionUp)
						y--;
					else if (input.directionDown)
						y++;
					else if (input.directionLeft)
						x--;
					else
						x++;

					if (level.wallTiles.getTile(x, y) == level.nameToIdMap.get("wall")) {
						trace("Picked wall");
						level.wallTiles.setTile(x, y, 0);
						pickedObject = WALL;
					}
				} else {
					// Player wants to pick carpet
					if (level.foldedCarpetTiles.getTile(x, y) == level.nameToIdMap.get("main_carpet_folded")) {
						level.foldedCarpetTiles.setTile(x, y, 0);
						pickedObject = MAIN_CARPET;
					} else if (level.foldedCarpetTiles.getTile(x, y) == level.nameToIdMap.get("special_carpet_folded")) {
						level.foldedCarpetTiles.setTile(x, y, 0);
						pickedObject = SPECIAL_CARPET;
					} else if (level.carpetTiles.getTile(x, y) == level.nameToIdMap.get("carpet")) {
						trace("Picked carpet");
						level.carpetTiles.setTile(x, y, 0);
						pickedObject = CARPET;
					} else if (level.carpetTiles.getTile(x, y) == level.nameToIdMap.get("main_carpet")) {
						trace("Main carpet picked");
						level.carpetTiles.setTile(x, y, 0);
						pickedObject = MAIN_CARPET;
					} else if (level.carpetTiles.getTile(x, y) == level.nameToIdMap.get("special_carpet")) {
						trace("Special carpet picked");
						level.carpetTiles.setTile(x, y, 0);
						pickedObject = SPECIAL_CARPET;
					}
				}
			} else {
				if (pickedObject == CARPET || pickedObject == SPECIAL_CARPET || pickedObject == MAIN_CARPET) {
					if (level.carpetTiles.getTile(x, y) == 0) {
						trace("Put carpet");
						var setTo:Int;
						if (pickedObject == CARPET)
							setTo = level.nameToIdMap.get("carpet");
						else if (pickedObject == SPECIAL_CARPET)
							setTo = level.nameToIdMap.get("special_carpet");
						else
							setTo = level.nameToIdMap.get("main_carpet");
						level.carpetTiles.setTile(x, y, setTo);
						pickedObject = NONE;
					}
				} else if (pickedObject == WALL) {
					// REWORK CHECKING WHERE TO PLACE WALLS
					y += 2;
					if (level.wallTiles.getTile(x, y) == 0) {
						trace("Put wall");
						level.wallTiles.setTile(x, y, level.nameToIdMap.get("wall"));
						pickedObject = NONE;
					}
				}
			}
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
