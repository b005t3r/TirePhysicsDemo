/**
 * User: booster
 * Date: 14/03/15
 * Time: 18:46
 */
package drive.components.engine {

public class LimitedTorqueCurve extends TorqueCurve {
    protected var _negativeTorqueRatio:Number   = 0.1;
    protected var _torqueDecayRatio:Number      = 0.075;
    protected var _minRpm:Number;
    protected var _maxRpm:Number;

    public function LimitedTorqueCurve(rpms:Vector.<Number>, torques:Vector.<Number>, minRpm:Number, maxRpm:Number, name:String = null) {
        super(rpms, torques, name);

        if(minRpm >= maxRpm)
            throw new ArgumentError("minRpm has to be lower than maxRpm");

        _minRpm = minRpm;
        _maxRpm = maxRpm;
    }

    override protected function getTorque(rpm:Number, throttle:Number):Number {
        var maxTorque:Number    = getMaxTorque(rpm);
        var minTorque:Number    = _negativeTorqueRatio * -maxTorque;
        var rpmRange:Number     = throttle * (_maxRpm - _minRpm);
        var currMaxRpm:Number   = _minRpm + rpmRange;
        var maxDecayRpm:Number  = _minRpm + rpmRange * (1 + _torqueDecayRatio);

        if(rpm <= currMaxRpm) {
            return minTorque + throttle * (maxTorque - minTorque);
        }
        else {
            var decayRatio:Number = currMaxRpm == maxDecayRpm ? 0 : 1 - (currMaxRpm - rpm) / (currMaxRpm - maxDecayRpm);

            if(decayRatio < 0)
                decayRatio = 0;

            return minTorque + throttle * (maxTorque - minTorque) * decayRatio;
        }
    }
}
}
