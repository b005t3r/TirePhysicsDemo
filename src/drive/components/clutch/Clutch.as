/**
 * User: booster
 * Date: 18/03/15
 * Time: 13:50
 */
package drive.components.clutch {
import drive.components.DrivetrainComponent;
import drive.components.DrivetrainComponentData;
import drive.components.drivetrain_internal;

import flash.errors.IllegalOperationError;

import plugs.inputs.NumberInput;

use namespace drivetrain_internal;

public class Clutch extends DrivetrainComponent {
    private var _clutchRatioInput:NumberInput;
    private var _previousAngularVelocityInput:NumberInput;
    private var _nextAngularVelocityInput:NumberInput;

    public function Clutch(name:String = null) {
        super(name);

        _clutchRatioInput               = new NumberInput("ClutchRatio");
        _previousAngularVelocityInput   = new NumberInput("PreviousAngularVelocity");
        _nextAngularVelocityInput       = new NumberInput("NextAngularVelocity");
    }

    public function get clutchRatioInput():NumberInput { return _clutchRatioInput; }
    public function get previousAngularVelocityInput():NumberInput { return _previousAngularVelocityInput; }
    public function get nextAngularVelocityInput():NumberInput { return _nextAngularVelocityInput; }

    protected function pullClutchRatio():Number {
        return _clutchRatioInput.connections.get(0).pullData();
    }

    override protected function pullGearRatio():Number { throw new IllegalOperationError("clutch has no gear ratio"); }
    override protected function pullTorque():Number { throw new IllegalOperationError("clutch nas not torque"); }
    override protected function pullInertia():Number { throw new IllegalOperationError("clutch has no inertia"); }
    override protected function pullTimeStep():Number { throw new IllegalOperationError("clutch does not use time step pulling"); }
    override protected function calculateNewAngularVelocity():Number { throw new IllegalOperationError("clutch does not integrate velocity over time"); }

    override protected function calculatePreviousAngularVelocityDiff():Number {
        var prevData:DrivetrainComponentData = drivetrain_internal::_previousComponentInput.connections.get(0).pullData();

        // no need to use gear ratio for previous component's values, it's always 1 for clutch
        var prevInertia:Number      = prevData.combinedEffectiveInertia;
        var prevAngVel:Number       = _previousAngularVelocityInput.connections.get(0).pullData();
        var prevAngMomentum:Number  = prevInertia * prevAngVel;

        var nextData:DrivetrainComponentData = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();

        var nextInertia:Number      = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
        var nextAngVel:Number       = _nextAngularVelocityInput.connections.get(0).pullData() * nextData.gearRatio;
        var nextAngMomentum:Number  = nextInertia * nextAngVel;

        var clutchRatio:Number      = pullClutchRatio();

        var newPrevAngVel:Number    = (prevAngMomentum + clutchRatio * nextAngMomentum) / (prevInertia + clutchRatio * nextInertia);

        return newPrevAngVel - prevAngVel;
    }

    override protected function calculateNextAngularVelocityDiff():Number {
        var prevData:DrivetrainComponentData = drivetrain_internal::_previousComponentInput.connections.get(0).pullData();

        // no need to use gear ratio for previous component's values, it's always 1 for clutch
        var prevInertia:Number      = prevData.combinedEffectiveInertia;
        var prevAngVel:Number       = _previousAngularVelocityInput.connections.get(0).pullData();
        var prevAngMomentum:Number  = prevInertia * prevAngVel;

        var nextData:DrivetrainComponentData = drivetrain_internal::_nextComponentInput.connections.get(0).pullData();

        var nextInertia:Number      = nextData.combinedEffectiveInertia / (nextData.gearRatio * nextData.gearRatio);
        var nextAngVel:Number       = _nextAngularVelocityInput.connections.get(0).pullData() * nextData.gearRatio;
        var nextAngMomentum:Number  = nextInertia * nextAngVel;

        var clutchRatio:Number      = pullClutchRatio();

        var newNextAngVel:Number    = (nextAngMomentum + clutchRatio * prevAngMomentum) / (nextInertia + clutchRatio * prevInertia);

        return newNextAngVel - prevAngVel;
    }
}
}
