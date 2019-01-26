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
	var pathList:Array<Vec2I>;
	var targetCell:Vec2I;
	var playState:PlayState;

	public function new(tileset:TiledLevel, playState:PlayState, descr:String = "assets/images/player.json") {
		super(descr);
		this.animation.play("idle");
		maxVelocity.x = 160;
		maxVelocity.y = 160;
		drag.x = maxVelocity.x * 4;
		drag.y = maxVelocity.y * 4;
		this.tileset = tileset;
		blockSprite = new FlxSprite();
		blockSprite.loadGraphic("assets/images/tileset.png", true, 32, 32);
		blockSprite.kill();
		this.playState = playState;
	}

	public function setTarget(target:Vec2I, force:Bool = false):Bool {
		if (targetCell != target || force) {
			targetCell = target;
			return calculatePath();
		}
		return true;
	}

	static var DV:Array<Vec2I> = [new Vec2I(1, 0), new Vec2I(-1, 0), new Vec2I(0, -1), new Vec2I(0, 1)];

	public function calculatePath():Bool {
		pathList = new Array<Vec2I>();
		var walls = playState.level.wallTiles;
		var prev:Map<Int, Vec2I> = new Map<Int, Vec2I>();
		var queue:Array<Int> = new Array<Int>();
		var back:Int = 0;

		var cx:Int = Std.int(x / 32);
		var cy:Int = Std.int(y / 32);
		var id0 = (new Vec2I(cx, cy)).asInt();
		prev.set(id0, null);
		queue.push(id0);
		while (back < queue.length) {
			var pnow = queue[back];
			back++;
			var vnow = Vec2I.fromInt(pnow);

			for (d in DV) {
				var tp = new Vec2I(d.x, d.y);
				tp.addVec(vnow);
				if (tp.x < 0 ||
					tp.y < 0 ||
					tp.x >= walls.widthInTiles ||
					tp.y >= walls.heightInTiles) {
					continue;
				}

				if (walls.getTile(tp.x, tp.y) > 0) {
					continue;
				}
				var tid = tp.asInt();
				if (prev.exists(tid)) {
					continue;
				}
				prev.set(tid, vnow);
				queue.push(tid);
			}
		}
		var targetId = targetCell.asInt();
		if (!prev.exists(targetId)) {
			return false;
		}
		var p = targetCell;
		while (p != null) {
			pathList.push(p);
			p = prev.get(p.asInt());
		}
		return true;
	}

	public function walkToTarget():Bool {
		if (pathList != null && pathList.length > 0) {
			var target = pathList[pathList.length - 1];
			var walls = playState.level.wallTiles;
			if (walls.getTile(target.x, target.y) > 0) {
				if (!setTarget(targetCell, true)) {
					return false;
				}
			}
			if (walkNear(target.x, target.y)) {
				return true;
			} else {
				pathList.pop();
				return pathList.length > 0;
			}
		} else {
			return false;
		}
	}

	public function walkNear(tx:Int, ty:Int):Bool {
		var px:Float = tx * 32 + 4;
		var py:Float = ty * 32 + 4;
		var dx = px - x;
		var dy = py - y;
		var done = true;
		if (Math.abs(dx) > 3) {
			done = false;
			if (dx > 0)
				addMove(Direction.Right)
			else
				addMove(Direction.Left);
		}
		if (Math.abs(dy) > 3) {
			done = false;
			if (dy > 0)
				addMove(Direction.Down)
			else
				addMove(Direction.Up);
		}
		return !done;
	}

	public function setcontainer(container:FlxGroup) {
		this.container = container;
		container.add(blockSprite);
	}

	function updateCarriedBlock() {
		if (object != null) {
			var gid = object.idUnfolded;
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
				moveDirection.x -= maxVelocity.x;
			case Up:
				moveDirection.y -= maxVelocity.y;
			case Right:
				moveDirection.x += maxVelocity.x;
			case Down:
				moveDirection.y += maxVelocity.y;
			case Here:
		}
	}

	override public function update(d:Float) {
		velocity.set(moveDirection.x, moveDirection.y);
		currentDir = Here;
		super.update(d);
		// this.velocity.set(0, 0);
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
