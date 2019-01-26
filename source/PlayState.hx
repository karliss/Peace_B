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
	public var resources:Vec2I;
	public var input:Input = new Input();
	public var helpers:FlxTypedGroup<Helper> = new FlxTypedGroup<Helper>();
	public var enemies:FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();
	public var paused:Bool = false;

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

	private function enemyCollisionCallback(a:FlxObject, b:FlxObject):Bool {
		var found:Bool = false;
		for (e in enemies) {
			if (e.overlapsPoint(b.getMidpoint()) && e.isFleeting == false) {
				e.handleCollision();
				found = true;
				break;
			}
		}

		if (found == false)
			return false;

		var id = level.wallTiles.getTileIndexByCoords(a.getMidpoint());
		level.wallTiles.setTileByIndex(id, 0);

		return false;
	}

	private function enemyOnCarpetCallback(a:FlxObject, b:FlxObject):Bool {
		var makeSlow:Bool = false;
		var id = level.carpetTiles.getTileIndexByCoords(a.getMidpoint());
		var props:TiledLevel.PickableProperties = level.idToPropertiesMap.get(level.carpetTiles.getTileByIndex(id));
		if (props.carpetType == "NORMAL") {
			makeSlow = true;
		}

		var found:Bool = false;
		for (e in enemies) {
			if (e.overlapsPoint(b.getMidpoint())) {
				if (e.isFleeting == false)
					found = true;
				if (makeSlow) {
					e.slow = true;
				}
			}
		}

		if (found && props.carpetType == "MAIN") {
			level.carpetTiles.setTileByIndex(id, 0);
		}

		return false;
	}

	override public function update(elapsed:Float):Void {
		input.update();
		if (input.backPressed) {
			fpause();
		}
		if (paused) {
			return;
		}

		checkGameOver();

		applyControls(player);

		for (helper in helpers) {
			// applyControls(helper);
		}

		for (helper in helpers) {
			helper.walkToTarget();
		}

		for (enemy in enemies) {
			enemy.addMove(enemy.getNextMove(level));
		}

		if (FlxG.keys.anyPressed([F])) {
			for (helper in helpers) {
				var path = helper.setTarget(new Vec2I(Std.int(player.x / 32), Std.int(player.y / 32)));
				trace("finding path", path);
			}
		}

		super.update(elapsed);

		FlxG.overlap(coins, player, getCoin);

		// Collide with foreground tile layer
		level.collideWithLevel(player);
		for (helper in helpers) {
			level.collideWithLevel(helper);
		}

		// destroy block
		for (enemy in enemies) {
			level.wallTiles.overlapsWithCallback(enemy, enemyCollisionCallback);
		}

		// handle carpets: destroy main carpets, get slow on normal carpets
		for (enemy in enemies) {
			enemy.slow = false;
			level.carpetTiles.overlapsWithCallback(enemy, enemyOnCarpetCallback);
		}

		for (enemy in enemies) {
			level.collideWithLevel(enemy);
		}

		// FlxG.overlap(exit, player, win);
	}

	public function pickup(x:Int, y:Int):TiledLevel.PickableProperties {
		var p = player.getMidpoint();
		var pickedObject:TiledLevel.PickableProperties = null;
		if (level.wallTiles.getTile(x, y) != 0) {
			pickedObject = level.idToPropertiesMap.get(level.wallTiles.getTile(x, y));
			level.wallTiles.setTile(x, y, 0);
		} else if (level.foldedCarpetTiles.getTile(x, y) != 0) {
			pickedObject = level.idToPropertiesMap.get(level.foldedCarpetTiles.getTile(x, y));
			level.foldedCarpetTiles.setTile(x, y, 0);
		} else if (level.carpetTiles.getTile(x, y) != 0) {
			pickedObject = level.idToPropertiesMap.get(level.carpetTiles.getTile(x, y));
			level.carpetTiles.setTile(x, y, 0);
		}
		return pickedObject;
	}

	public function canPutObject(x:Int, y:Int):Bool {
		return level.foldedCarpetTiles.getTile(x, y) == 0 && level.wallTiles.getTile(x, y) == 0;
	}

	public function place(x:Int, y:Int, object:TiledLevel.PickableProperties):Bool {
		if (object.isWall) {
			if (level.wallTiles.getTile(x, y) == 0 && level.foldedCarpetTiles.getTile(x, y) == 0) {
				level.wallTiles.setTile(x, y, object.id);
				return true;
			}
		} else if (object.isCarpet) {
			if (level.carpetTiles.getTile(x, y) == 0) {
				level.carpetTiles.setTile(x, y, object.idUnfolded);
				return true;
			}
			if (canPutObject(x, y)) {
				level.foldedCarpetTiles.setTile(x, y, object.idFolded);
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

	function checkGameOver() {
		var mainCarpets = level.carpetTiles.getTileInstances(level.nameToIdMap["main_carpet"]);
		if (mainCarpets == null || mainCarpets.length == 0) {
			openSubState(new GameOver());
		}
	}

	override function onFocusLost() {
		fpause();
	}

	public function fpause() {
		if (this.subState == null) {
			// FlxNapeSpace.paused = true;
			openSubState(new EscMenu(this));
			paused = true;
		}
	}

	public function unpause() {
		paused = false;
	}
}
