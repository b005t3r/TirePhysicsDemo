/**
 * User: booster
 * Date: 14/03/15
 * Time: 14:36
 */
package drive.components.engine {
import plugs.Connection;
import plugs.outputs.NumberOutput;
import plugs.providers.AbstractProvider;

public class Throttle extends AbstractProvider implements IThrottle {
    protected var _throttleOutput:NumberOutput;

    private var _throttle:Number = 0;

    public function Throttle(name:String = null) {
        super(name);

        _throttleOutput = new NumberOutput("Throttle");
        addOutput(_throttleOutput);
    }

    public function get throttleOutput():NumberOutput { return _throttleOutput; }

    public function get throttle():Number { return _throttle; }
    public function set throttle(value:Number):void { _throttle = value; }

    override public function requestPullData(outputConnection:Connection):* {
        if(outputConnection.output == _throttleOutput)
            return _throttle;

        throw new Error("invalid connection");
    }
}
}
