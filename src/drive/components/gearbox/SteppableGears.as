/**
 * User: booster
 * Date: 15/03/15
 * Time: 11:25
 */
package drive.components.gearbox {
import drive.components.util.ISteppable;

import plugs.Connection;

import plugs.inputs.NumberInput;

public class SteppableGears extends Gears implements ISteppable {
    private var _upShiftTime:Number       = 0.2;
    private var _downShiftTime:Number     = 0.2;
    private var _neutralShiftTime:Number  = 0.1;

    private var _timeStepInput:NumberInput;

    private var _timeLeft:Number;
    private var _prevGear:int;
    private var _nextGear:int;

    public function SteppableGears(neutralGearRatio:Number, neutralGearInertia:Number, forwardGearRatios:Vector.<Number>, forwardGearInertias:Vector.<Number>, reverseGearRatios:Vector.<Number>, reverseGearInertias:Vector.<Number>, name:String = null) {
        super(neutralGearRatio, neutralGearInertia, forwardGearRatios, forwardGearInertias, reverseGearRatios, reverseGearInertias, name);

        _timeStepInput = new NumberInput("dt");

        addInput(_timeStepInput);
    }

    public function get upShiftTime():Number { return _upShiftTime; }
    public function set upShiftTime(value:Number):void { _upShiftTime = value; }

    public function get downShiftTime():Number { return _downShiftTime; }
    public function set downShiftTime(value:Number):void { _downShiftTime = value; }

    public function get neutralShiftTime():Number { return _neutralShiftTime; }
    public function set neutralShiftTime(value:Number):void { _neutralShiftTime = value; }

    public function get timeStepInput():NumberInput { return _timeStepInput; }

    override public function receivePushData(data:*, inputConnection:Connection):void {
        if(inputConnection.input == _timeStepInput) {
            step(data);
            return;
        }

        super.receivePushData(data, inputConnection);
    }

    override public function set gear(value:int):void {
        // isNaN - not changing gear currently
        if(_timeLeft != _timeLeft) {
            _prevGear   = gear;
            _nextGear   = value;
            _timeLeft   = getShiftTime(_prevGear, _nextGear);

            super.gear  = 0;
        }
        else {
            var currShiftTime:Number    = getShiftTime(_prevGear, _nextGear);
            var newShiftTime:Number     = getShiftTime(_prevGear, value);
            var diff:Number             = newShiftTime - currShiftTime;

            if(diff > 0)
                _timeLeft += diff;

            _nextGear = value;
        }
    }

    private function step(dt:Number):void {
        _timeLeft -= dt;

        if(_timeLeft > 0)
            return;

        _timeLeft   = NaN;
        super.gear  = _nextGear;
    }

    private function getShiftTime(currGear:int, newGear:int):Number {
        if(newGear == currGear)
            return 0;

        if(newGear == 0)
            return _neutralShiftTime;

        return newGear > currGear ? _upShiftTime : _downShiftTime;
    }
}
}
