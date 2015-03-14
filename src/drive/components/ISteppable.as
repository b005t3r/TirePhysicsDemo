/**
 * User: booster
 * Date: 14/03/15
 * Time: 14:46
 */
package drive.components {
import plugs.IConsumer;
import plugs.inputs.NumberInput;

public interface ISteppable extends IConsumer {
    function get timeStepInput():NumberInput
}
}
