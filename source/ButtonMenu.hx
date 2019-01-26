package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.*;
import openfl.display.*;
import flixel.*;
import openfl.display.BitmapData;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import haxe.ds.Vector;
import flixel.ui.FlxButton;

class ButtonMenu extends FlxTypedGroup<FlxSprite> {
	var selector:FlxSprite;
	var buttons:Array<FlxButton>;
	var selected:Int = 0;
	var delay:Float = 0;

	public static function scaleButton(button:FlxButton) {
		button.scale.set(2, 2);
		button.label.scale.set(2, 2);
		button.width *= 2;
		button.height *= 2;
	}

	public function new() {
		super();
		buttons = new Array<FlxButton>();
		selector = new FlxSprite(10, 10);
		selector.makeGraphic(16, 16);
		add(selector);
		selector.scrollFactor.set(0, 0);
		selector.kill();
	}

	public function updateInput(input:Input) {
		if (delay <= 0) {
			var pressed:Bool = false;
			if (buttons.length > 0) {
				if (input.directionDown || input.directionRight) {
					selected += 1;
					pressed = true;
				} else if (input.directionUp || input.directionLeft) {
					selected -= 1;
					pressed = true;
				}
				if (selected < 0) {
					selected = buttons.length - 1;
				} else if (selected >= buttons.length) {
					selected = 0;
				}
				if (!pressed && input.confirmPressed) {
					buttons[selected].onUp.fire();
					pressed = true;
				}
				if (!selector.alive) {
					selector.revive();
					pressed = true;
				}
				if (pressed) {
					selector.y = buttons[selected].y;
					selector.x = buttons[selected].x - 64;
				}
			}
			if (pressed) {
				delay = 0.1;
			}
		}
	}

	override public function update(diff:Float) {
		if (delay > 0) {
			delay -= diff;
		}
		super.update(diff);
	}

	public function addButton(button:FlxButton) {
		add(button);
		buttons.push(button);
	}
}
