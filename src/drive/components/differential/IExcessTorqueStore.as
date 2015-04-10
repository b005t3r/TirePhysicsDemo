/**
 * User: booster
 * Date: 13/03/15
 * Time: 15:39
 */
package drive.components.differential {
import drive.components.util.ISteppable;

import plugs.IProcessor;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;

public interface IExcessTorqueStore extends IProcessor, ISteppable {
    function get torqueInput():NumberInput
    function get torqueOutput():NumberOutput

    function get torque():Number
    function set torque(value:Number):void
}
}
