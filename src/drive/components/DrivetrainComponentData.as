/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:37
 */
package drive.components {
public class DrivetrainComponentData {
    public var gearRatios:Vector.<Number>;
    public var inertias:Vector.<Number>;
    public var torques:Vector.<Number>;

    public var count:int;

    public function DrivetrainComponentData(buffersSize:int = 10) {
        gearRatios = new Vector.<Number>(buffersSize, true);
        inertias   = new Vector.<Number>(buffersSize, true);
        torques    = new Vector.<Number>(buffersSize, true);
    }
    
    public function copyTo(data:DrivetrainComponentData):void {
        for(var i:int = 0; i < count; ++i) {
            data.gearRatios[i]  = gearRatios[i];
            data.inertias[i]    = inertias[i];
            data.torques[i]     = torques[i];
        }

        data.count = count;
    }
}
}
