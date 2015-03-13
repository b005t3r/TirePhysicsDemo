/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:38
 */
package drive.components {
import drive.*;

import plugs.IInput;
import plugs.outputs.AbstractOutput;

public class DrivetrainComponentOutput extends AbstractOutput {
    public function DrivetrainComponentOutput(name:String = null) {
        super(name);
    }

    override public function canConnect(input:IInput):Boolean {
        return input is DrivetrainComponentInput;
    }
}
}
