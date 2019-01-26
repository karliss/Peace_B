package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import openfl.Assets;
import openfl.display.BitmapData;
import flixel.system.FlxAssets;
import haxe.Json;

class AnimatedSprite extends FlxSprite {
	// var image: FlxSprite;
	public function new(asset:FlxGraphicAsset, width:Int = 32, height:Int = 32) {
		super(0, 0);
		if (Std.is(asset, FlxSprite)) {
			var reference:FlxSprite = cast asset;
			loadGraphicFromSprite(reference);
		} else if (Std.is(asset, BitmapData)) {
			var reference:BitmapData = cast asset;
			loadGraphic(reference, false, width, height);
		} else {
			var path:String = cast asset;
			if (!StringTools.endsWith(path, ".json")) {
				loadGraphic(path, false, width, height);
			} else {
				var jsondata = Json.parse(openfl.Assets.getText(path));
				var width = Std.parseInt(jsondata.width);
				var height = Std.parseInt(jsondata.height);
				loadGraphic(jsondata.image, true, width, height);
				// centerOffsets();
				var bodyDesc = Reflect.field(jsondata, "collision");
				if (bodyDesc != null) {
					var w:Float = Std.parseFloat(bodyDesc[2]);
					var h:Float = Std.parseFloat(bodyDesc[3]);
					this.width = w;
					this.height = h;
					offset = new FlxPoint(Std.parseInt(bodyDesc[0]), Std.parseInt(bodyDesc[1]));
				}

				for (anim in Reflect.fields(jsondata.animation)) {
					var d = Reflect.field(jsondata.animation, anim);
					var speed:Int = Std.parseInt(d.speed);
					var looped = d.looped == "true";
					animation.add(anim, d.f, speed, looped);
				}
			}
		}
		// body.allowRotation = false;
		// setDrag(0.98, 0.98);
		// body.userData.sprite = this;
	}
}
