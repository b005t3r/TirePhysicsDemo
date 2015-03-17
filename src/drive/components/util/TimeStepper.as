/**
 * User: booster
 * Date: 17/03/15
 * Time: 16:28
 */
package drive.components.util {
import plugs.Connection;
import plugs.outputs.NumberOutput;
import plugs.providers.AbstractProvider;

public class TimeStepper extends AbstractProvider {
    protected var _timeStepOutput:NumberOutput;

    public function TimeStepper(name:String = null) {
        super(name);

        _timeStepOutput = new NumberOutput("dt");

        addOutput(_timeStepOutput);
    }

    public function get timeStepOutput():NumberOutput { return _timeStepOutput; }

    public function pushTimeStep(dt:Number):void {
        var count:int = _timeStepOutput.connections.size();
        for(var i:int = 0; i < count; ++i) {
            var conn:Connection = _timeStepOutput.connections.get(i);

            conn.pushData(dt);
        }
    }
}
}
