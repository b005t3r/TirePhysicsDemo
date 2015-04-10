/**
 * User: booster
 * Date: 02/04/15
 * Time: 17:05
 */
package drive.components.wheel {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class WheelModel extends AbstractProcessor {
    private var _staticFrictionCoefficient:Number;
    private var _kineticFrictionCoefficient:Number;
    private var _rollingFrictionCoefficient:Number;

    private var _longitudinalSlipRatios:Vector.<Number>;
    private var _longitudinalForceRatios:Vector.<Number>;

    private var _staticFrictionCoefficientOutput:NumberOutput;
    private var _kineticFrictionCoefficientOutput:NumberOutput;
    private var _rollingFrictionCoefficientOutput:NumberOutput;

    private var _slipRatioInput:NumberInput;
    private var _longitudinalForceRatioOutput:NumberOutput;

    public function WheelModel(name:String = null) {
        super(name);
        
        _staticFrictionCoefficientOutput    = new NumberOutput("StaticFrictionCoefficient");
        _kineticFrictionCoefficientOutput   = new NumberOutput("KineticFrictionCoefficient");
        _rollingFrictionCoefficientOutput   = new NumberOutput("RollingFrictionCoefficient");

        addOutput(_staticFrictionCoefficientOutput);
        addOutput(_kineticFrictionCoefficientOutput);
        addOutput(_rollingFrictionCoefficientOutput);

        _slipRatioInput                     = new NumberInput("SlipRatio");
        _longitudinalForceRatioOutput       = new NumberOutput("LongitudinalForceRatio");

        addInput(_slipRatioInput);
        addOutput(_longitudinalForceRatioOutput);
    }

    public function get staticFrictionCoefficient():Number { return _staticFrictionCoefficient; }
    public function set staticFrictionCoefficient(value:Number):void { _staticFrictionCoefficient = value; }

    public function get kineticFrictionCoefficient():Number { return _kineticFrictionCoefficient; }
    public function set kineticFrictionCoefficient(value:Number):void { _kineticFrictionCoefficient = value; }

    public function get rollingFrictionCoefficient():Number { return _rollingFrictionCoefficient; }
    public function set rollingFrictionCoefficient(value:Number):void { _rollingFrictionCoefficient = value; }

    public function get longitudinalSlipRatios():Vector.<Number> { return _longitudinalSlipRatios; }
    public function set longitudinalSlipRatios(value:Vector.<Number>):void { _longitudinalSlipRatios = value; }

    public function get longitudinalForceRatios():Vector.<Number> { return _longitudinalForceRatios; }
    public function set longitudinalForceRatios(value:Vector.<Number>):void { _longitudinalForceRatios = value; }

    public function get staticFrictionCoefficientOutput():NumberOutput { return _staticFrictionCoefficientOutput; }
    public function get kineticFrictionCoefficientOutput():NumberOutput { return _kineticFrictionCoefficientOutput; }
    public function get rollingFrictionCoefficientOutput():NumberOutput { return _rollingFrictionCoefficientOutput; }

    public function get slipRatioInput():NumberInput { return _slipRatioInput; }
    public function get longitudinalForceRatioOutput():NumberOutput { return _longitudinalForceRatioOutput; }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _staticFrictionCoefficientOutput)
            return _staticFrictionCoefficient;
        else if(outputConnection.output == _kineticFrictionCoefficientOutput)
            return _kineticFrictionCoefficient;
        else if(outputConnection.output == _rollingFrictionCoefficientOutput)
            return _rollingFrictionCoefficient;
        else if(outputConnection.output == _longitudinalForceRatioOutput)
            return getLongitudinalForceRatio(pullSlipRatio());
        else
            return super.requestPullData(outputConnection);
    }

    private function pullSlipRatio():Number {
        return _slipRatioInput.connections.get(0).pullData();
    }

    private function getLongitudinalForceRatio(slipRatio:Number):Number {
        if(slipRatio < _longitudinalSlipRatios[0])                                  return _longitudinalForceRatios[0];
        if(slipRatio > _longitudinalSlipRatios[_longitudinalSlipRatios.length - 1]) return _longitudinalForceRatios[_longitudinalForceRatios.length - 1];

        var count:int = _longitudinalSlipRatios.length;
        for(var i:int = 0; i < count; ++i) {
            var maxSlipRatio:Number = _longitudinalSlipRatios[i];

            if(maxSlipRatio == slipRatio)       return _longitudinalForceRatios[i];
            else if (maxSlipRatio < slipRatio)  continue;

            var minSlipRatio:Number     = _longitudinalSlipRatios[i - 1];
            var ratio:Number            = (slipRatio - minSlipRatio) / (maxSlipRatio - minSlipRatio);

            var maxForceRatio:Number    = _longitudinalForceRatios[i];
            var minForceRatio:Number    = _longitudinalForceRatios[i - 1];

            return minForceRatio + (maxForceRatio - minForceRatio) * ratio;
        }

        throw new Error("slip ratio not found?");
    }

}
}
