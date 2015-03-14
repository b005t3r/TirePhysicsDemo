/**
 * User: booster
 * Date: 14/03/15
 * Time: 16:46
 */
package drive.components.engine {
import plugs.Connection;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.processors.AbstractProcessor;

public class TorqueCurve extends AbstractProcessor implements ITorqueCurve {
    protected var _rpmInput:NumberInput;
    protected var _throttleInput:NumberInput;
    protected var _torqueOutput:NumberOutput;

    protected var _rpms:Vector.<Number>     = new <Number>[];
    protected var _torques:Vector.<Number>  = new <Number>[];

    public function TorqueCurve(rpms:Vector.<Number>, torques:Vector.<Number>, name:String = null) {
        super(name);

        if(rpms.length != torques.length)
            throw new ArgumentError("there has to be a torque value for each rpm");

        var count:int = _rpms.length = _torques.length = rpms.length;
        for(var i:int = 0; i < count; ++i) {
            _rpms[i]    = rpms[i];
            _torques[i] = torques[i];
        }

        _rpmInput = new NumberInput("RPM");
        _throttleInput = new NumberInput("Throttle");
        _torqueOutput = new NumberOutput("Torque");

        addInput(_rpmInput);
        addInput(_throttleInput);
        addOutput(_torqueOutput);
    }

    public function get rpmInput():NumberInput { return _rpmInput; }
    public function get throttleInput():NumberInput { return _throttleInput; }
    public function get torqueOutput():NumberOutput { return _torqueOutput; }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _torqueOutput)
            return getTorque(getInputRPM(), getInputThrottle());

        return super.requestPullData(outputConnection);
    }

    protected function getInputRPM():Number {
        return _rpmInput.connections.get(0).pullData();
    }

    protected function getInputThrottle():Number {
        return _throttleInput.connections.get(0).pullData();
    }

    protected function getTorque(rpm:Number, throttle:Number):Number {
        return getMaxTorque(rpm) * throttle;
    }

    protected function getMaxTorque(rpm:Number):Number {
        if(rpm < _rpms[0])                  return _torques[0];
        if(rpm > _rpms[_rpms.length - 1])   return _torques[_torques.length - 1];

        var count:int = _rpms.length;
        for(var i:int = 0; i < count; ++i) {
            var maxRpm:Number = _rpms[i];

            if(maxRpm == rpm)       return _torques[i];
            else if (maxRpm < rpm)  continue;

            var minRpm:Number = _rpms[i - 1];
            var ratio:Number = (rpm - minRpm) / (maxRpm - minRpm);

            var maxTorque:Number = _torques[i];
            var minTorque:Number = _torques[i - 1];

            return minTorque + (maxTorque - minTorque) * ratio;
        }

        throw new Error("RPM not found?");
    }
}
}
