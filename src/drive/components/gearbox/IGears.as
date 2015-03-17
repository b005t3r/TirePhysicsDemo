/**
 * User: booster
 * Date: 15/03/15
 * Time: 11:01
 */
package drive.components.gearbox {
import plugs.IProcessor;
import plugs.outputs.NumberOutput;

public interface IGears extends IProcessor {
    function get gearInertiaOutput():NumberOutput
    function get gearRatioOutput():NumberOutput
}
}
