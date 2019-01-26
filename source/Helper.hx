import Player.Direction;

class Helper extends Player {
	var placementTarget:Vec2I;
	var placementSource:Vec2I;
	var placmentDir:Player.Direction;

	function getObject():TiledLevel.PickableProperties {
		var result = new TiledLevel.PickableProperties(false, true, playState.level.nameToIdMap["wall"]);
		return result;
	}

	function choosePlacementTarget(object:TiledLevel.PickableProperties) {
		var stockPiles = playState.level.carpetTiles.getTileInstances(playState.level.nameToIdMap["special_carpet"]);
		var walls = playState.level.wallTiles;
		placementTarget = null;
		placementSource = null;
		var carpets = playState.level.carpetTiles;
		for (stockPile in stockPiles) {
			var x = stockPile % carpets.widthInTiles;
			var y = Std.int(stockPile / carpets.widthInTiles);
			if (!playState.canPutObject(x, y))
				continue;
			var pos = new Vec2I(x, y);
			var dir = Player.Direction.Here;
			var putInPlace = !object.isWall;
			if (!putInPlace) {
				var dirs:Array<Direction> = if (putInPlace) {
					[Direction.Here];
				} else {
					[Direction.Left, Direction.Up, Direction.Down, Direction.Right];
				};
				for (d in dirs) {
					var tp = pos.addDir(d);
					if (walls.getTile(tp.x, tp.y) == 0 && setTarget(tp, true)) {
						placementTarget = pos;
						placementSource = tp;
						placmentDir = Vec2I.opositeDir(d);
						break;
					}
				}
			}
			if (placementTarget != null) {
				break;
			}
		}
	}

	public override function update(d:Float) {
		if (this.object == null) {
			if (playState.resources != null) {
				if (this.middleCell().equal(playState.resources)) {
					setObject(getObject());
				} else if (setTarget(playState.resources)) {
					walkToTarget();
				}
			}
		} else {
			if (placementTarget == null) {
				choosePlacementTarget(this.object);
			}
			if (placementTarget != null && (playState.level.wallTiles.getTile(placementTarget.x, placementTarget.y) > 0 || playState.level.foldedCarpetTiles
				.getTile(placementTarget.x, placementTarget.y) > 0)) {
				choosePlacementTarget(this.object);
			}
			if (placementTarget != null) {
				if (setTarget(placementSource)) {
					walkToTarget();
				}
			}
			if (middleCell().equal(placementSource)) {
				this.place(placmentDir, playState);
			}
		}
		super.update(d);
	}
}
