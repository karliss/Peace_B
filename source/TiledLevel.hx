package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import haxe.io.Path;

class PickableProperties {
	public var isCarpet:Bool;
	public var isWall:Bool;
	public var id:Int; // when isWall
	public var idFolded:Int; // when isCarpet
	public var idUnfolded:Int; // when isCarpet
	public var carpetType:String;

	public function new(isCarpet, isWall, id) {
		this.isCarpet = isCarpet;
		this.isWall = isWall;
		this.id = id;
		this.idFolded = id;
		this.idUnfolded = id;
	}
}

/**
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap {
	// For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image
	// used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/tiled/";

	// Array of tilemaps used for collision
	public var wallLayer:FlxGroup;
	public var objectsLayer:FlxGroup;
	public var carpetLayer:FlxGroup;
	public var foldedCarpetLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	// tilemaps
	public var wallTiles:FlxTilemap;
	public var carpetTiles:FlxTilemap;
	public var foldedCarpetTiles:FlxTilemap;
	// Sprites of images layers
	public var imagesLayer:FlxGroup;
	public var nameToIdMap:Map<String, Int>;
	// Pickable objects
	public var idToPropertiesMap:Map<Int, PickableProperties>;

	public function getLayerTileset(ly:TiledTileLayer):TiledTileSet {
		for (tile in ly.tileArray) {
			if (tile > 0) {
				return getGidOwner(tile);
			}
		}
		return null;
	}

	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState) {
		super(tiledLevel);

		nameToIdMap = new Map<String, Int>();
		imagesLayer = new FlxGroup();
		wallLayer = new FlxGroup();
		objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		carpetLayer = new FlxGroup();
		foldedCarpetLayer = new FlxGroup();
		idToPropertiesMap = new Map<Int, PickableProperties>();

		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);

		loadImages();
		loadObjects(state);

		for (tileset in tilesets) {
			for (i in tileset.firstGID...(tileset.firstGID + tileset.numTiles)) {
				nameToIdMap.set(tileset.tileTypes[i - tileset.firstGID], i);
			}

			for (i in tileset.firstGID...(tileset.firstGID + tileset.numTiles)) {
				var props:TiledPropertySet = tileset.getPropertiesByGid(i);

				if (props != null) {
					var isCarpet = props.contains("folded_carpet");
					var isWall = props.contains("wall");
					var pickableProps = new PickableProperties(isCarpet, isWall, i);

					if (isCarpet) {
						pickableProps.carpetType = props.get("carpet_type");
						if (props.contains("carpet")) {
							// adjust folded id
							pickableProps.idFolded = nameToIdMap[props.get("folded_carpet")];
						} else {
							// adjust unfolded id
							pickableProps.idUnfolded = nameToIdMap[props.get("unfolded_carpet")];
						}
					}

					idToPropertiesMap.set(i, pickableProps);
				}
				/*gidType[i] = MapType.Empty;
					var props:TiledPropertySet = tileset.getPropertiesByGid(i);
					if (props == null)
						continue;
					var type = props.get("type");
					if (type != null) {
						if (type == "water") {
							gidType[i] = MapType.Water;
						} else if (type == "block") {
							gidType[i] = MapType.Block;
						} else if (type == "object") {
							gidType[i] = MapType.Object;
							var tileId2 = tileset.fromGid(i);
							var objectType = props.get("objectType");
							objectGidMap.set(tileId2, objectType);
							objectStringMap.set(objectType, tileId2);
						}
				}*/
			}
		}

		// Load Tile Maps
		for (layer in layers) {
			if (layer.type != TiledLayerType.TILE)
				continue;
			var tileLayer:TiledTileLayer = cast layer;

			var tileSet:TiledTileSet = getLayerTileset(tileLayer);

			// if (tileSet == null)
			//	throw "Tileset '" + tileSheetName + " not found. Did you misspell the 'tilesheet' property in " + tileLayer.name + "' layer?";
			var imagePath = new Path(tileSet.imageSource);
			var processedPath = Path.join([c_PATH_LEVEL_TILESHEETS, tileSet.imageSource]);
			// var processedPath = new Path(c_PATH_LEVEL_TILESHEETS) +
			// var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath, tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

			if (tileLayer.properties.contains("animated")) {
				var tileset = tilesets["level"];
				var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
				for (tileProp in tileset.tileProps) {
					if (tileProp != null && tileProp.animationFrames.length > 0) {
						specialTiles[tileProp.tileID + tileset.firstGID] = tileProp;
					}
				}
				var tileLayer:TiledTileLayer = cast layer;
				tilemap.setSpecialTiles([
					for (tile in tileLayer.tiles)
						if (tile != null && specialTiles.exists(tile.tileID))
							getAnimatedTile(specialTiles[tile.tileID], tileset)
						else
							null]);
			}

			if (tileLayer.properties.contains("nocollide") || tileLayer.name == "background") {
				backgroundLayer.add(tilemap);
			} else if (tileLayer.name == "carpet") {
				carpetLayer.add(tilemap);
				carpetTiles = tilemap;
			} else if (tileLayer.name == "folded_carpet") {
				foldedCarpetLayer.add(tilemap);
				foldedCarpetTiles = tilemap;
			} else if (tileLayer.name == "wall") {
				wallLayer.add(tilemap);
				wallTiles = tilemap;
			}
		}
	}

	function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial {
		var special = new FlxTileSpecial(1, false, false, 0);
		var n:Int = props.animationFrames.length;
		var offset = Std.random(n);
		special.addAnimation([for (i in 0...n) props.animationFrames[(i + offset) % n].tileID + tileset.firstGID], (1000 / props.animationFrames[0].duration));
		return special;
	}

	public function loadObjects(state:PlayState) {
		for (layer in layers) {
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			// collection of images layer
			/*if (layer.name == "images") {
				for (o in objectLayer.objects) {
					loadImageObject(o);
				}
			}*/

			// objects layer
			if (layer.name == "marker") {
				for (o in objectLayer.objects) {
					loadObject(state, o, objectLayer, objectsLayer);
				}
			}
		}
	}

	function loadImageObject(object:TiledObject) {
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);

		// decorative sprites
		var levelsDir:String = "assets/tiled/";

		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width || decoSprite.height != object.height) {
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		if (object.flippedHorizontally) {
			decoSprite.flipX = true;
		}
		if (object.flippedVertically) {
			decoSprite.flipY = true;
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0) {
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}

		// Custom Properties
		if (object.properties.contains("depth")) {
			var depth = Std.parseFloat(object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth, depth);
		}

		backgroundLayer.add(decoSprite);
	}

	function loadObject(state:PlayState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup) {
		var x:Int = o.x;
		var y:Int = o.y;

		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;

		switch (o.type.toLowerCase()) {
			case "player":
				var player = new Player(this, state);
				player.setcontainer(group);
				player.x = x;
				player.y = y;

				FlxG.camera.follow(player);
				state.player = player;
				group.add(player);
			case "helper":
				var helper = new Helper(this, state);
				helper.setcontainer(group);
				helper.x = x;
				helper.y = y;

				state.helpers.add(helper);
				group.add(helper);
			case "resources":
				state.resources = new Vec2I(Std.int(x / 32), Std.int(y / 32));
			case "enemy":
				var enemy = new Enemy(this, state);
				enemy.setcontainer(group);
				enemy.x = x;
				enemy.y = y;

				state.enemies.add(enemy);
				group.add(enemy);
		}
	}

	public function loadImages() {
		for (layer in layers) {
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}

	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {
		// IMPORTANT: Always collide the map with objects, not the other way around.
		//            This prevents odd collision errors (collision separation code off by 1 px).
		if (FlxG.overlap(wallTiles, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate)) {
			return true;
		}
		return false;
	}
}
