/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:37
 */
package drive.components {
public class DrivetrainComponentData {
    /** Combined torque of one side of the drivetrain. */
    public var combinedTorque:Number;

    /** Combined effective inertia of one side of the drivetrain. */
    public var combinedEffectiveInertia:Number;

    /** Gear ratio of the component closest to the one pulling this data. */
    public var gearRatio:Number;

    /** Combined angular velocity difference inducted by one side of the drivetrain. */
    public var combinedAngularVelocityDiff:Number;

    public function copyTo(data:DrivetrainComponentData):void {
        data.combinedTorque = combinedTorque;
        data.combinedEffectiveInertia = combinedEffectiveInertia;
        data.gearRatio = gearRatio;
        data.combinedAngularVelocityDiff = combinedAngularVelocityDiff;
    }
}
}
