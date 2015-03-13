/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:37
 */
package drive.components {
public class DrivetrainComponentData {
    public var combinedTorque:Number;
    public var combinedEffectiveInertia:Number;
    public var gearRatio:Number;

    public function copyTo(data:DrivetrainComponentData):void {
        data.combinedTorque = combinedTorque;
        data.combinedEffectiveInertia = combinedEffectiveInertia;
        data.gearRatio = gearRatio;
    }
}
}
