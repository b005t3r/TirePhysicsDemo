package {

import flash.display.Sprite;
import flash.events.Event;

import starling.core.Starling;

[SWF(width="720", height="480", backgroundColor="#333333", frameRate="60")]
public class Main extends Sprite {
    private var _starling:Starling;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        _starling = new Starling(RootDisplay, stage, null, null, "auto", "auto");
        _starling.start();
    }
}
}
