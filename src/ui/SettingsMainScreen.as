/**
 * User: booster
 * Date: 05/03/15
 * Time: 15:38
 */
package ui {
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.StandardIcons;

import starling.events.Event;
import starling.textures.Texture;

public class SettingsMainScreen extends PanelScreen {
    public static const WHEEL_SCREEN_ID:String      = "wheel";
    public static const WORLD_SCREEN_ID:String      = "world";
    public static const CONTROLS_SCREEN_ID:String   = "controls";

    private var _list:List;

    public var savedVerticalScrollPosition:Number = 0;
    public var savedSelectedIndex:int = -1;

    public function SettingsMainScreen() {
    }

    override protected function initialize():void
    {
        //never forget to call super.initialize()
        super.initialize();

        this.title = "Settings";

        this.layout = new AnchorLayout();

        this._list = new List();
        this._list.dataProvider = new ListCollection(
            [
                { label: "Controls", event: CONTROLS_SCREEN_ID },
                { label: "Wheel settings", event: WHEEL_SCREEN_ID },
                { label: "World settings", event: WORLD_SCREEN_ID },
            ]);
        this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        this._list.clipContent = false;
        this._list.autoHideBackground = true;
        this._list.verticalScrollPosition = this.savedVerticalScrollPosition;
        this._list.selectedIndex = this.savedSelectedIndex;

        this._list.itemRendererFactory = function():IListItemRenderer
        {
            var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();

            //enable the quick hit area to optimize hit tests when an item
            //is only selectable and doesn't have interactive children.
            renderer.isQuickHitAreaEnabled = true;

            renderer.labelField = "label";
            renderer.accessorySourceFunction = accessorySourceFunction;
            return renderer;
        };

        this._list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
        this.addChild(this._list);

        this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
    }

    private function accessorySourceFunction(item:Object):Texture
    {
        return StandardIcons.listDrillDownAccessoryTexture;
    }

    private function transitionInCompleteHandler(event:Event):void
    {
        this._list.selectedIndex = -1;
        this._list.revealScrollBars();
    }

    private function list_triggeredHandler(event:Event, item:Object):void
    {
        var eventType:String = item.event as String;
        this.dispatchEventWith(eventType, false,
            {
                //we're going to save the position of the list so that when the user
                //navigates back to this screen, they won't need to scroll back to
                //the same position manually
                savedVerticalScrollPosition: this._list.verticalScrollPosition,
                //we'll also save the selected index to temporarily highlight
                //the previously selected item when transitioning back
                savedSelectedIndex: this._list.selectedIndex
            });
    }
}
}
