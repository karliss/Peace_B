package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;

class GameOver extends FlxSubState {
	private var buttons:ButtonMenu;
	private var btnRestart:flixel.ui.FlxButton;
	private var btnExit:FlxButton;
	private var btnContinue:FlxButton;
	var input:Input;

	public function new() {
		super();
		input = new Input();
	}

	public override function create() {
		FlxG.mouse.visible = true;
		buttons = new ButtonMenu();
		add(buttons);

		btnExit = new FlxButton(0, 210, "Exit", function() {
			FlxG.switchState(new MainMenu());
		});
		buttons.addButton(btnExit);
		btnExit.x = FlxG.width / 2 - btnExit.width / 2;
		ButtonMenu.scaleButton(btnExit);

		var t2:FlxText = new FlxText(10, 110, FlxG.width - 20, "Game Over", 20);
		add(t2);
		t2.x = FlxG.width / 2 - t2.width;
		t2.y = FlxG.height / 2 - t2.height;
	}

	public override function update(elapsed:Float) {
		input.update();
		buttons.updateInput(input);
		super.update(elapsed);
	}
}
