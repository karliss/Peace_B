enum Direction {
	Left;
	Up;
	Right;
	Down;
	Here;
}

class Player extends AnimatedSprite {
	public var moveDirection:Direction = Direction.Here;

	public function new() {
		super("assets/images/player.json");
		this.animation.play("idle");
		maxVelocity.x = 160;
		maxVelocity.y = 160;
		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
	}

	public function setMove(d:Direction) {
		this.moveDirection = d;
	}

	override public function update(d:Float) {
		acceleration.x = 0;
		acceleration.y = 0;
		switch (moveDirection) {
			case Left:
				acceleration.x -= maxVelocity.x * 4;
			case Up:
				acceleration.y -= maxVelocity.y * 4;
			case Right:
				acceleration.x += maxVelocity.x * 4;
			case Down:
				acceleration.y += maxVelocity.y * 4;
			case Here:
		}
		moveDirection = Here;
		super.update(d);
	}
}
