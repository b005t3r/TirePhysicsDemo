/**
 * User: booster
 * Date: 02/04/15
 * Time: 16:57
 */
package drive.components.wheel {
import drive.components.DrivetrainComponent;

public class WheelComponent extends DrivetrainComponent {
    public function WheelComponent(name:String = null) {
        super(name);

        _maxNextComponents = 0;
    }
}
}
