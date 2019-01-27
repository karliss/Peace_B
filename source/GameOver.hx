package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class GameOver extends FlxSubState {
	private var buttons:ButtonMenu;
	private var btnRestart:flixel.ui.FlxButton;
	private var btnExit:FlxButton;
	private var btnContinue:FlxButton;
	private var survivalTime:Int;
	var input:Input;

	public function new(survivalTime:Int) {
		this.survivalTime = survivalTime;
		super();
		input = new Input();
	}

	public override function create() {
		super.create();
		FlxG.mouse.visible = true;
		buttons = new ButtonMenu();
		add(buttons);

		btnExit = new FlxButton(0, 210, "Exit", function() {
			FlxG.switchState(new MainMenu());
		});
		buttons.addButton(btnExit);
		btnExit.x = FlxG.width / 2 - btnExit.width / 2;
		ButtonMenu.scaleButton(btnExit);

		var t2:FlxText = new FlxText(FlxG.width / 2, FlxG.height / 2, 200, "Game Over", 20);
		t2.scrollFactor.set(0, 0);
		t2.x -= t2.width / 2;
		t2.color = FlxColor.fromRGB(0, 0, 0);
		add(t2);
		var t3:FlxText = new FlxText(FlxG.width / 2, FlxG.height / 2, 250, "Survival time: " + survivalTime, 20);
		t3.scrollFactor.set(0, 0);
		t3.x -= t3.width / 2;
		t3.y += 40;
		t3.color = FlxColor.fromRGB(0, 0, 0);
		add(t3);
		// t2.x = FlxG.width / 2 - t2.width / 2;
		// t2.y = FlxG.height / 2 - t2.height / 2;
	}

	public override function update(elapsed:Float) {
		input.update();
		buttons.updateInput(input);
		super.update(elapsed);
	}
}
