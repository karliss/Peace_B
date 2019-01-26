import flixel.FlxG;
import flixel.input.gamepad.*;
import flixel.input.gamepad.FlxGamepad;

class Input {
	public var backPressed:Bool = false;
	public var confirmPressed:Bool = false;
	public var directionUp:Bool = false;
	public var directionLeft:Bool = false;
	public var directionRight:Bool = false;
	public var directionDown:Bool = false;
	public var pickItem:Bool = false;

	public function new() {}

	public function update() {
		backPressed = false;
		confirmPressed = false;
		directionUp = false;
		directionLeft = false;
		directionRight = false;
		directionDown = false;

		if (FlxG.keys.anyPressed([UP, W, K])) {
			directionUp = true;
		}
		if (FlxG.keys.anyPressed([DOWN, S, J])) {
			directionDown = true;
		}
		if (FlxG.keys.anyPressed([LEFT, A, H])) {
			directionLeft = true;
		}
		if (FlxG.keys.anyPressed([RIGHT, D, L])) {
			directionRight = true;
		}
		if (FlxG.keys.anyJustReleased([ESCAPE, BACKSPACE])) {
			backPressed = true;
		}
		if (FlxG.keys.anyJustReleased([SPACE, ENTER])) {
			confirmPressed = true;
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			// gamepad.deadZone = 0.15;
			// gamepad.deadZoneMode = FlxGamepadDeadZoneMode.INDEPENDENT_AXES;

			if (gamepad.anyPressed([DPAD_UP])) {
				directionUp = true;
			}
			if (gamepad.anyPressed([DPAD_DOWN])) {
				directionDown = true;
			}
			if (gamepad.anyPressed([DPAD_LEFT])) {
				directionLeft = true;
			}
			if (gamepad.anyPressed([DPAD_RIGHT])) {
				directionRight = true;
			}

			var analog = gamepad.analog.value;
			var dx = analog.LEFT_STICK_X;
			var dy = analog.LEFT_STICK_Y;
			var adx = Math.abs(dx);
			var ady = Math.abs(dy);
			var LEVEL = 0.5;

			if (adx > LEVEL) {
				if (dx > 0) {
					directionRight = true;
				} else {
					directionLeft = true;
				}
			}
			if (ady > LEVEL) {
				if (dy > 0) {
					directionDown = true;
				} else {
					directionUp = true;
				}
			}

			if (gamepad.anyJustReleased([BACK, X])) {
				backPressed = true;
			}
			if (gamepad.anyJustReleased([START, A])) {
				confirmPressed = true;
			}
		}
	}
}
