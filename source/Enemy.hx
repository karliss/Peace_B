import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Enemy extends Player {
	public var isFleeting:Bool = false;

	private var fleetingDirection:Player.Direction;

	public function getNextMove(level:TiledLevel):Player.Direction {
		if (isFleeting) {
			return fleetingDirection;
		}

		var X:Int;
		var Y:Int;

		X = -1;
		Y = -1;

		var w:Int = level.carpetTiles.widthInTiles;
		var h:Int = level.carpetTiles.heightInTiles;
		for (x in 0...w) {
			for (y in 0...h) {
				if (level.carpetTiles.getTile(x, y) > 0) {
					var prop:TiledLevel.PickableProperties = level.idToPropertiesMap.get(level.carpetTiles.getTile(x, y));
					if (prop.carpetType == "MAIN") {
						X = x * 32 + 16;
						Y = y * 32 + 16;
					}
				}
			}
		}

		if (X == -1)
			return Player.Direction.Down;

		if (Math.abs(x - X) > 10) {
			if (x < X)
				return Player.Direction.Right;
			if (x > X)
				return Player.Direction.Left;
		}
		if (y < Y)
			return Player.Direction.Down;
		return Player.Direction.Up;
	}

	public function handleCollision():Void {
		if (isFleeting)
			return;
		trace(this);

		switch (Std.random(4)) {
			case 0:
				fleetingDirection = Player.Direction.Left;
			case 1:
				fleetingDirection = Player.Direction.Right;
			case 2:
				fleetingDirection = Player.Direction.Down;
			case 3:
				fleetingDirection = Player.Direction.Up;
		}

		isFleeting = true;
	}
}
