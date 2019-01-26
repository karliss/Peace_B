import flixel.math.FlxPoint;

enum Direction {
	Left;
	Up;
	Right;
	Down;
	Here;
}

class Player extends AnimatedSprite {
	public var moveDirection:FlxPoint = new FlxPoint(0, 0);
	public var lastDir:Direction = Direction.Here;
	public var object:TiledLevel.PickableProperties;

	public function new() {
		super("assets/images/player.json");
		this.animation.play("idle");
		maxVelocity.x = 160;
		maxVelocity.y = 160;
		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
	}

	public function addMove(d:Direction) {
		this.lastDir = d;
		switch (d) {
			case Left:
				moveDirection.x -= maxVelocity.x * 4;
			case Up:
				moveDirection.y -= maxVelocity.y * 4;
			case Right:
				moveDirection.x += maxVelocity.x * 4;
			case Down:
				moveDirection.y += maxVelocity.y * 4;
			case Here:
		}
	}

	override public function update(d:Float) {
		acceleration.set(moveDirection.x, moveDirection.y);
		lastDir = Here;
		super.update(d);
		this.moveDirection.set(0, 0);
	}

	public function pickupPlayer(state:PlayState) {
		pickup(lastDir, state);
	}

	public function pickup(direction:Direction, state:PlayState) {
		trace("foo1");
		if (object != null) {
			return;
		}
		trace("foo2");
		var pos = this.getMidpoint();
		var x:Int = Math.floor(pos.x / 32);
		var y:Int = Math.floor(pos.y / 32);
		switch (direction) {
			case Left:
				x--;
			case Right:
				x++;
			case Up:
				y--;
			case Down:
				y++;
			case Here:
		}
		this.object = state.pickup(x, y);
	}

	public function placePlayer(state:PlayState) {
		return this.place(lastDir, state);
	}

	public function place(direction:Direction, state:PlayState) {
		if (object == null) {
			return;
		}
		var pos = this.getMidpoint();
		var x:Int = Math.floor(pos.x / 32);
		var y:Int = Math.floor(pos.y / 32);
		if (object.isWall) {
			switch (direction) {
				case Left:
					x--;
				case Right:
					x++;
				case Up:
					y--;
				case Down:
					y++;
				case Here:
					x++;
			}
		}
		if (state.place(x, y, object)) {
			this.object = null;
		}
	}
}
