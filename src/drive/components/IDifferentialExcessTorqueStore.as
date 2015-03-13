/**
 * User: booster
 * Date: 13/03/15
 * Time: 15:39
 */
package drive.components {
import plugs.IProcessor;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;

public interface IDifferentialExcessTorqueStore extends IProcessor {
    function get torqueInput():NumberInput
    function get torqueOutput():NumberOutput

    function get torque():Number
    function set torque(value:Number):void

    function pullTorque():void
}
}
