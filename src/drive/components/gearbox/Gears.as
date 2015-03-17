/**
 * User: booster
 * Date: 15/03/15
 * Time: 11:03
 */
package drive.components.gearbox {
import plugs.Connection;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class Gears extends AbstractProcessor implements IGears {
    protected var _gearInertiaOutput:NumberOutput;
    protected var _gearRatioOutput:NumberOutput;

    protected var _neutralGearRatio:Number;
    protected var _neutralGearInertia:Number;
    protected var _forwardGearRatios:Vector.<Number>    = new <Number>[];
    protected var _forwardGearInertias:Vector.<Number>  = new <Number>[];
    protected var _reverseGearRatios:Vector.<Number>    = new <Number>[];
    protected var _reverseGearInertias:Vector.<Number>  = new <Number>[];

    private var _gear:int;

    public function Gears(neutralGearRatio:Number, neutralGearInertia:Number,
                          forwardGearRatios:Vector.<Number>, forwardGearInertias:Vector.<Number>,
                          reverseGearRatios:Vector.<Number>, reverseGearInertias:Vector.<Number>,
                          name:String = null) {
        super(name);

        if(forwardGearRatios.length != forwardGearInertias.length)
            throw new ArgumentError("there has to be an inertia value for each forward gear ratio value");

        if(reverseGearRatios.length != reverseGearInertias.length)
            throw new ArgumentError("there has to be an inertia value for each reverse gear ratio value");

        _neutralGearRatio   = neutralGearRatio;
        _neutralGearInertia = neutralGearInertia;

        var i:int, count:int;

        count = _forwardGearRatios.length = _forwardGearInertias.length = forwardGearRatios.length;
        for(i = 0; i < count; ++i) {
            _forwardGearRatios[i]   = forwardGearRatios[i];
            _forwardGearInertias[i] = forwardGearInertias[i];
        }

        count = _reverseGearRatios.length = _reverseGearInertias.length = reverseGearRatios.length;
        for(i = 0; i < count; ++i) {
            _reverseGearRatios[i]   = reverseGearRatios[i];
            _reverseGearInertias[i] = reverseGearInertias[i];
        }

        _gearInertiaOutput  = new NumberOutput("GearInertia");
        _gearRatioOutput    = new NumberOutput("GearRatio");

        addOutput(_gearInertiaOutput);
        addOutput(_gearRatioOutput);
    }

    public function get gearInertiaOutput():NumberOutput { return _gearInertiaOutput; }
    public function get gearRatioOutput():NumberOutput { return _gearRatioOutput; }

    public function get gear():int { return _gear; }
    public function set gear(value:int):void { _gear = value; }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _gearRatioOutput)
            return getGearRatio(_gear);
        else if(outputConnection.output == _gearInertiaOutput)
            return getGearInertia(_gear);

        return super.requestPullData(outputConnection);
    }

    protected function getGearRatio(gear:int):Number {
        if(gear == 0)
            return _neutralGearRatio;

        return _gear > 0
            ? _forwardGearRatios[gear - 1]
            : _reverseGearRatios[-gear - 1]
        ;
    }

    protected function getGearInertia(gear:int):Number {
        if(gear == 0)
            return _neutralGearInertia;

        return _gear > 0
            ? _forwardGearInertias[gear - 1]
            : _reverseGearInertias[-gear - 1]
        ;
    }
}
}
