import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

enum Direction {
	Left;
	Up;
	Right;
	Down;
	Here;
}

class Player extends AnimatedSprite {
	public var moveDirection:FlxPoint = new FlxPoint(0, 0);
	public var lastMoveDir:Direction = Direction.Right;
	public var currentDir:Direction = Direction.Here;
	public var object:TiledLevel.PickableProperties;

	var container:FlxGroup;
	var blockSprite:FlxSprite;
	var tileset:TiledLevel;

	public function new(tileset:TiledLevel) {
		super("assets/images/player.json");
		this.animation.play("idle");
		maxVelocity.x = 160;
		maxVelocity.y = 160;
		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
		this.tileset = tileset;
		blockSprite = new FlxSprite();
		blockSprite.loadGraphic("assets/images/tileset.png", true, 32, 32);
		blockSprite.kill();
	}

	public function setcontainer(container:FlxGroup) {
		this.container = container;
		container.add(blockSprite);
	}

	function updateCarriedBlock() {
		if (object != null) {
			var gid = object.idOnPickup;
			trace(object);
			var frame = gid - tileset.getGidOwner(gid).firstGID;
			blockSprite.animation.frameIndex = frame;
			blockSprite.revive();
		} else {
			blockSprite.kill();
		}
	}

	public function addMove(d:Direction) {
		this.currentDir = d;
		if (d != Direction.Here) {
			lastMoveDir = d;
		}
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
		currentDir = Here;
		super.update(d);
		blockSprite.x = x + this.width / 2;
		blockSprite.y = y - this.height / 2;
		if (Math.abs(velocity.x) > 0.1 || Math.abs(velocity.y) > 0.1) {
			animation.play("walk");
		} else {
			animation.play("idle");
		}
		this.moveDirection.set(0, 0);
	}

	public function pickupPlayer(state:PlayState) {
		pickup(currentDir, state);
	}

	public function pickup(direction:Direction, state:PlayState) {
		if (object != null) {
			return;
		}
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
		updateCarriedBlock();
	}

	public function placePlayer(state:PlayState) {
		return this.place(lastMoveDir, state);
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
			updateCarriedBlock();
		}
	}
}
