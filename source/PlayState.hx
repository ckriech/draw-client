package;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.net.WebSocket;
import haxe.Utf8;
import UnicodeString;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState {
	var background: FlxSprite;
	var ws: WebSocket = WebSocket.create("wss://fun.krie.ch:8777/game", false);
	var ereg:EReg = ~/x(\d+)y(\d+)r(\d+)g(\d+)b(\d+)/;
	var myColor: FlxColor;

	override public function create():Void {
		super.create();
		myColor = FlxColor.fromRGB(
			FlxG.random.int(0,255),
			FlxG.random.int(0,255),
			FlxG.random.int(0,255)
		);
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(background);
		ws.onmessageString = function(message) {
			// var decoded = new UnicodeString(message);
			var split = message.split(',');
			for (msg in split) {
				if (ereg.match(msg)) {
					processMessage(msg);
				} else {
					trace("bad message: " + message);
				}
			}
		}
	}

	private function processMessage(msg: String): Void {
		trace("received message part: " + msg);
		//0 is whole matched text???
	
		var x: String = ereg.matched(1);
		var y: String = ereg.matched(2);
		var r: String = ereg.matched(3);
		var g: String = ereg.matched(4);
		var b: String = ereg.matched(5);

		trace('$x $y $r $g $b');
		background.drawRect(
			Std.parseFloat(x), 
			Std.parseFloat(y), 
			10, 
			10,
			FlxColor.fromRGB(
				Std.parseInt(r), 
				Std.parseInt(g), 
				Std.parseInt(b)));
	}
	 
	var oldSpot: FlxPoint = new FlxPoint(-1, -1);
	override public function update(elapsed:Float):Void
	{
		if(FlxG.mouse.pressed) {
			var point: FlxPoint = FlxG.mouse.getWorldPosition();

			if (!oldSpot.equals(point)) {
				oldSpot = point;
				var message = (
				'{
					\"point\": {
						\"x\": ${point.x},
						\"y\": ${point.y}
					},
					\"color\": {
						\"r\": ${myColor.red},
						\"g\": ${myColor.green},
						\"b\": ${myColor.blue}
					}
				}');
				trace("sending message:" + message);
				ws.sendString(message);
				super.update(elapsed);
			}
		}
	}
}
