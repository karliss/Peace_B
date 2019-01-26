class Vec2I {
	public var x:Int;
	public var y:Int;

	public function new(x:Int = 0, y:Int = 0) {
		this.x = x;
		this.y = y;
	}

	public function set(?x:Int = null, ?y:Int = null) {
		if (x != null) {
			this.x = x;
		}
		if (y != null) {
			this.y = y;
		}
	}

	public inline function add(x:Int, y:Int) {
		this.x += x;
		this.y += y;
	}

	public inline function addVec(t:Vec2I) {
		this.add(t.x, t.y);
	}

	public inline function sub(x:Int, y:Int) {
		this.x -= x;
		this.y -= y;
	}

	public inline function subVec(t:Vec2I) {
		this.sub(t.x, t.y);
	}

	public inline function asInt():Int {
		return (x << 16) + y;
	}

	static public function fromInt(v:Int):Vec2I {
		return new Vec2I(v >> 16, v & 0xffff);
	}

	public function clone():Vec2I {
		return new Vec2I(x, y);
	}

	public function addDir(dir:Player.Direction, shiftHere:Bool = false):Vec2I {
		var result = this.clone();
		switch (dir) {
			case Left:
				result.x--;
			case Right:
				result.x++;
			case Up:
				result.y--;
			case Down:
				result.y++;
			case Here:
				if (shiftHere)
					result.x++;
		}
		return result;
	}

	public static function opositeDir(dir:Player.Direction):Player.Direction {
		switch (dir) {
			case Left:
				return Right;
			case Right:
				return Left;
			case Up:
				return Down;
			case Down:
				return Up;
			case Here:
				return Here;
		}
	}

	public inline function equal(other:Vec2I):Bool {
		if (other == null) {
			return false;
		}
		return x == other.x && y == other.y;
	}
}
