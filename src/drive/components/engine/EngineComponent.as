/**
 * User: booster
 * Date: 11/03/15
 * Time: 13:43
 */
package drive.components.engine {
import drive.components.*;
import drive.components.util.ISteppable;

import plugs.Connection;

import plugs.inputs.NumberInput;

import plugs.outputs.NumberOutput;

public class EngineComponent extends DrivetrainComponent {
    public function EngineComponent(name:String = null) {
        super(name);

        _maxPreviousComponents = 0;
    }
}
}
