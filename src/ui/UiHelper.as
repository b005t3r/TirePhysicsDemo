/**
 * User: booster
 * Date: 06/03/15
 * Time: 13:46
 */
package ui {
import feathers.controls.Button;
import feathers.controls.Slider;
import feathers.skins.AddOnFunctionStyleProvider;

import starling.events.Event;

public class UiHelper {
    public static function setupSlider(slider:Slider):void {
        slider.thumbFactory = function ():Button {
            var thumb:Button = new Button();
            thumb.styleProvider = new AddOnFunctionStyleProvider(thumb.styleProvider, function (button:Button):void {
                button.hasLabelTextRenderer = true;
                button.width = 32;
                button.height = 16;
            });

            thumb.label = "" + (slider.step < 1 ? int(slider.value * 10) / 10 : int(slider.value));
            slider.addEventListener(Event.CHANGE, function (e:Event):void {
                thumb.label = "" + (slider.step < 1 ? int(slider.value * 10) / 10 : int(slider.value));
            });

            return thumb;
        };
        slider.width = 128;
    }
}
}
