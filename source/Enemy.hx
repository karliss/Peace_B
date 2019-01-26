import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class Enemy extends Player {
	public var isFleeting:Bool = false;

	private var fleetingDirection:Player.Direction;

	override public function new(tileset:TiledLevel, playState:PlayState, descr:String = "assets/images/enemy.json") {
		super(tileset, playState, descr);
		maxVelocity.x = 60;
		maxVelocity.y = 60;
	}

	public function walk(level:TiledLevel):Void {
		if (isFleeting) {
			if (walkToTarget() == false) {
				maxVelocity.x = 60;
				maxVelocity.y = 60;
				isFleeting = false;
			}
			return;
		}

		var X:Int = -1;
		var Y:Int = -1;

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

		if (X == -1) {
			addMove(Player.Direction.Down);
			return;
		}

		if (Math.abs(x - X) > 10) {
			if (x < X)
				addMove(Player.Direction.Right);
			else
				addMove(Player.Direction.Left);
		}
		if (Math.abs(y - Y) > 10) {
			if (y < Y)
				addMove(Player.Direction.Down);
			else
				addMove(Player.Direction.Up);
		}
	}

	public function handleCollision(level:TiledLevel):Void {
		if (isFleeting)
			return;

		setTarget(new Vec2I(Std.random(2) == 0 ? 0 : level.wallTiles.widthInTiles - 1, Std.random(2) == 0 ? 0 : level.wallTiles.heightInTiles - 1), true);

		maxVelocity.x = 200;
		maxVelocity.y = 200;

		isFleeting = true;
	}
}
