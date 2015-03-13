/**
 * User: booster
 * Date: 11/03/15
 * Time: 12:42
 */
package drive.components {

public class DifferentialComponent extends DrivetrainComponent {
    protected var _shareRatio:Number;

    public function DifferentialComponent(shareRatio:Number = 0.5, name:String = null) {
        super(name);

        _maxNextComponents = 2;
        _shareRatio = shareRatio;
    }

    public function get shareRatio():Number { return _shareRatio; }


}
}
