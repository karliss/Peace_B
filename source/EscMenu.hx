package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;

class EscMenu extends FlxSubState {
	private var game:PlayState;
	private var buttons:ButtonMenu;
	private var btnRestart:flixel.ui.FlxButton;
	private var btnExit:FlxButton;
	private var btnContinue:FlxButton;
	var input:Input;

	public function new(_game:PlayState) {
		super();
		game = _game;
		input = new Input();
	}

	function unpause() {
		game.closeSubState();
		game.unpause();
	}

	public override function create() {
		FlxG.mouse.visible = true;
		buttons = new ButtonMenu();
		add(buttons);

		btnContinue = new FlxButton(0, 110, "Continue", unpause);
		buttons.addButton(btnContinue);
		btnContinue.x = FlxG.width / 2 - btnContinue.width / 2;
		ButtonMenu.scaleButton(btnContinue);

		btnRestart = new FlxButton(0, 160, "Restart", function() {
			FlxG.switchState(new PlayState());
		});
		buttons.addButton(btnRestart);
		btnRestart.x = FlxG.width / 2 - btnRestart.width / 2;
		ButtonMenu.scaleButton(btnRestart);

		btnExit = new FlxButton(0, 210, "Exit", function() {
			FlxG.switchState(new MainMenu());
		});
		buttons.addButton(btnExit);
		btnExit.x = FlxG.width / 2 - btnExit.width / 2;
		ButtonMenu.scaleButton(btnExit);
	}

	public override function update(elapsed:Float) {
		input.update();
		buttons.updateInput(input);
		if (input.backPressed) {
			unpause();
		}
		super.update(elapsed);
	}
}
