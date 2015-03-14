/**
 * User: booster
 * Date: 14/03/15
 * Time: 14:33
 */
package drive.components {
import plugs.IProvider;
import plugs.outputs.NumberOutput;

public interface ITimeStep extends IProvider {
    function get timeStepOutput():NumberOutput

    function pushTimeStep(dt:Number):void
}
}
