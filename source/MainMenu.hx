package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import openfl.system.System;

class MainMenu extends FlxState {
	private var _btnFullScreen:FlxButton;
	private var buttons:ButtonMenu;
	private var input:Input = new Input();

	override public function create():Void {
		FlxG.mouse.visible = true;

		// FlxG.console.autoPause = false;
		// FlxG.autoPause = false;

		var t1:FlxText = new FlxText(FlxG.width / 2, 10, 200, "Global Game Jam 2019");
		t1.x -= t1.width / 2;
		add(t1);

		var t1:FlxText = new FlxText(800, 10, 300, "Authors:\nKarlis, Kristaps");
		t1.x -= t1.width / 2;
		add(t1);

		buttons = new ButtonMenu();
		add(buttons);

		var b1:FlxButton = new FlxButton(FlxG.width / 2, FlxG.height / 2, "Start", function() {
			FlxG.switchState(new PlayState());
		});
		b1.x -= b1.width / 2;
		buttons.addButton(b1);
		ButtonMenu.scaleButton(b1);

		#if desktop
		_btnFullScreen = new FlxButton(FlxG.width / 2, FlxG.height / 2 + 30, FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", function() {
			FlxG.fullscreen = !FlxG.fullscreen;
			_btnFullScreen.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
		});

		_btnFullScreen.x -= _btnFullScreen.width / 2;
		ButtonMenu.scaleButton(_btnFullScreen);
		buttons.addButton(_btnFullScreen);

		var _btnExit = new FlxButton(FlxG.width / 2, FlxG.height / 2 + 70, "Exit", function() {
			System.exit(0);
		});
		_btnExit.x -= _btnExit.width / 2;
		ButtonMenu.scaleButton(_btnExit);
		buttons.addButton(_btnExit);
		#end

		var t2:FlxText = new FlxText(10, 110, FlxG.width - 20,
			"Controls: Gamepad may work (preferably turn on before game)\nArrows/WASD/HJKL - move\nSPACE,ENTER - pickup,put down block");
		add(t2);
	}

	override public function update(diff:Float) {
		input.update();
		buttons.updateInput(input);
		super.update(diff);
	}
}
