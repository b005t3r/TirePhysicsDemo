/**
 * User: booster
 * Date: 08/03/15
 * Time: 9:46
 */
package tire.ui {
import feathers.controls.LayoutGroup;
import feathers.controls.PanelScreen;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Quad;
import starling.display.graphicsEx.GraphicsEx;
import starling.display.graphicsEx.ShapeEx;
import starling.events.EnterFrameEvent;
import starling.events.Event;

import tire.TirePhysics;

public class AnimationScreen extends PanelScreen {
    private static const WHEEL_BORDER_COLOR:uint    = 0xFF8F00;
    private static const LOAD_BORDER_COLOR:uint     = 0x5A8F29;
    private static const SURFACE_BORDER_COLOR:uint  = 0x3C7DC4;
    private static const FILL_COLOR:uint            = 0x333333;

    private var _animationSprite:LayoutGroup;
    private var _canvas:ShapeEx;

    private var _tirePhysics:TirePhysics;

    public function AnimationScreen() {
        super();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }

    public function get tirePhysics():TirePhysics { return _tirePhysics; }
    public function set tirePhysics(value:TirePhysics):void { _tirePhysics = value; }

    override protected function initialize():void {
        super.initialize();

        title = "Animation";

        layout = new AnchorLayout();

        _animationSprite = new LayoutGroup();
        _animationSprite.layoutData = new AnchorLayoutData(0, 0, 0, 0);
        _animationSprite.clipContent = true;
        _animationSprite.backgroundSkin = new Quad(1, 1, 0x888888);
        addChild(_animationSprite);

        _canvas = new ShapeEx();
        _animationSprite.addChild(_canvas);
    }

    private function onAddedToStage(event:Event):void {
        stage.addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
    }

    private function onRemovedFromStage(event:Event):void {
        stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
    }

    private function onFrame(event:EnterFrameEvent):void {
        const lineThickness:Number  = 4;
        const surfaceHeight:Number  = 30;
        var wheelRadius:Number      = _tirePhysics.wheelRadius * 100;
        var wheelX:Number           = _animationSprite.width / 2;
        var wheelY:Number           = _animationSprite.height - wheelRadius - lineThickness / 2 - surfaceHeight;
        var wheelAngle:Number       = (-_tirePhysics.wheelAngle % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI);
        var distanceUnit:Number     = wheelRadius * 2 * Math.PI;
        var wheelDistance:Number    = (((_tirePhysics.wheelPos * 100) % distanceUnit) + distanceUnit) % distanceUnit;
        var loadSize:Number         = Math.sqrt(_tirePhysics.carMass) * 10;

        var graphics:GraphicsEx = _canvas.graphics;
        graphics.clear();

        // surface
        graphics.lineStyle(lineThickness, SURFACE_BORDER_COLOR);
        graphics.beginFill(FILL_COLOR);
        graphics.drawRect(-_animationSprite.width, _animationSprite.height - surfaceHeight, 3 * _animationSprite.width, 2 * surfaceHeight);
        graphics.endFill();

        for(var x:Number = wheelX + wheelDistance - int(_animationSprite.width / distanceUnit) * distanceUnit; x < 3 * _animationSprite.width; x += distanceUnit) {
            graphics.moveTo(x, _animationSprite.height - surfaceHeight);
            graphics.lineTo(x, _animationSprite.height + surfaceHeight)
        }

        // wheel
        graphics.lineStyle(lineThickness, WHEEL_BORDER_COLOR);

        graphics.beginFill(FILL_COLOR);
        graphics.drawCircle(wheelX, wheelY, wheelRadius);
        graphics.endFill();

        var lineBeginX:Number       = wheelX + Math.sin(wheelAngle) * (lineThickness * 2);
        var lineBeginY:Number       = wheelY + Math.cos(wheelAngle) * (lineThickness * 2);
        var lineEndX:Number         = wheelX + Math.sin(wheelAngle) * (wheelRadius - lineThickness * 2);
        var lineEndY:Number         = wheelY + Math.cos(wheelAngle) * (wheelRadius - lineThickness * 2);

        graphics.moveTo(lineBeginX, lineBeginY);
        graphics.lineTo(lineEndX, lineEndY);

        // load
        graphics.lineStyle(lineThickness, LOAD_BORDER_COLOR);

        graphics.beginFill(FILL_COLOR);
        graphics.drawRect(wheelX - loadSize / 2, wheelY - wheelRadius - loadSize - lineThickness, loadSize, loadSize);
        graphics.endFill();
    }
}
}
