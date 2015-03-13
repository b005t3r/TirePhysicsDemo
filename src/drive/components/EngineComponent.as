/**
 * User: booster
 * Date: 11/03/15
 * Time: 13:43
 */
package drive.components {

public class EngineComponent extends DrivetrainComponent {
    public function EngineComponent(name:String = null) {
        super(name);

        _maxPreviousComponents = 0;
    }
}
}
