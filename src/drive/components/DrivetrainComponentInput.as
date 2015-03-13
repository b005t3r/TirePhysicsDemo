/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:37
 */
package drive.components {
import plugs.IOutput;
import plugs.inputs.AbstractInput;

public class DrivetrainComponentInput extends AbstractInput {
    public function DrivetrainComponentInput(name:String = null) {
        super(name);
    }

    override public function canConnect(output:IOutput):Boolean {
        return output is DrivetrainComponentOutput;
    }
}
}
