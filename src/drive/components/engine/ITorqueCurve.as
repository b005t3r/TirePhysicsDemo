/**
 * User: booster
 * Date: 14/03/15
 * Time: 14:30
 */
package drive.components.engine {
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;

public interface ITorqueCurve {
    function get rpmInput():NumberInput
    function get throttleInput():NumberInput
    function get torqueOutput():NumberOutput
}
}
