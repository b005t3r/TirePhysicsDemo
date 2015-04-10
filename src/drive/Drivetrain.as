/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:23
 */
package drive {
import drive.components.DrivetrainComponent;
import drive.components.clutch.ClutchComponent;
import drive.components.differential.DifferentialComponent;
import drive.components.differential.IExcessTorqueStore;
import drive.components.differential.ExcessTorqueStore;
import drive.components.engine.EngineComponent;
import drive.components.util.SteppableValueStore;
import drive.components.util.TimeStepper;
import drive.components.util.ValueForwarder;

import flash.utils.getTimer;

import plugs.Connection;
import plugs.consumers.DebugConsumer;
import plugs.inputs.NumberInput;
import plugs.outputs.NumberOutput;
import plugs.providers.ValueProvider;

public class Drivetrain {
    public function Drivetrain() {
        RWDDrivetrainTest();
        //ClutchTest();
    }

    private function ClutchTest():void {
        var timeStepper:TimeStepper             = new TimeStepper("TimeStepper");
        var engine:EngineComponent              = new EngineComponent("Engine");
        var engineVelStore:SteppableValueStore  = new SteppableValueStore("EngineAngularVelocityStore");
        var clutch:ClutchComponent              = new ClutchComponent("Clutch");
        var clutchVelForwarder:ValueForwarder   = new ValueForwarder("ClutchAngularVelocityForwarder");
        var wheel:DrivetrainComponent           = new DrivetrainComponent("LeftWheel");
        var wheelVelStore:SteppableValueStore   = new SteppableValueStore("LeftWheelAngularVelocityStore");

        engine.connectNextComponent(clutch);
        clutch.connectNextComponent(wheel);

        // engine
        var engineTorque:ValueProvider = new ValueProvider(new NumberOutput("EngineTorque"));
        engineTorque.value = 100;
        var engineInertia:ValueProvider = new ValueProvider(new NumberOutput("EngineInertia"));
        engineInertia.value = 0.2;
        //engineInertia.value = 2;

        Connection.connect(engineTorque.output, engine.torqueInput);
        Connection.connect(engineInertia.output, engine.inertiaInput);

        Connection.connect(engine.newAngularVelocityOutput, engineVelStore.angularVelocityInput);
        Connection.connect(engineVelStore.angularVelocityOutput, engine.angularVelocityInput);
        Connection.connect(engineVelStore.stepDurationOutput, engine.stepDurationInput);

        // clutch
        var clutchRatio:ValueProvider = new ValueProvider(new NumberOutput("ClutchRatio"));
        clutchRatio.value = 0.0;

        Connection.connect(clutchRatio.output, clutch.clutchRatioInput);

        Connection.connect(clutchVelForwarder.angularVelocityOutput, clutch.angularVelocityInput);

        Connection.connect(engine.angularVelocityOutput, clutch.previousAngularVelocityInput);
        Connection.connect(wheel.angularVelocityOutput, clutch.nextAngularVelocityInput);

        // left wheel
        var wheelInertia:ValueProvider = new ValueProvider(new NumberOutput("WheelInertia"));
        wheelInertia.value = 10;
        var wheelTorque:ValueProvider = new ValueProvider(new NumberOutput("WheelTorque"));
        wheelTorque.value = -50;
        var wheelRatio:ValueProvider = new ValueProvider(new NumberOutput("WheelGearRatio"));
        wheelRatio.value = 4;

        Connection.connect(wheelInertia.output, wheel.inertiaInput);
        Connection.connect(wheelTorque.output, wheel.torqueInput);
        Connection.connect(wheelRatio.output, wheel.gearRatioInput);

        Connection.connect(wheel.newAngularVelocityOutput, wheelVelStore.angularVelocityInput);
        Connection.connect(wheelVelStore.angularVelocityOutput, wheel.angularVelocityInput);

        Connection.connect(wheel.angularVelocityOutput, clutchVelForwarder.angularVelocityInput);
        Connection.connect(wheelVelStore.stepDurationOutput, wheel.stepDurationInput);

        // time step - order is important, clutch first, then all the rest
        Connection.connect(timeStepper.timeStepOutput, clutch.timeStepInput);           // 1. Update clutch torque and inertia transfer.
        Connection.connect(timeStepper.timeStepOutput, wheelVelStore.timeStepInput);    // 2. Update wheel's ang. velocity.
                                                                                        // 3. Update differential's torque store.
        Connection.connect(timeStepper.timeStepOutput, engineVelStore.timeStepInput);   // 4. Update engine's ang. velocity.

        // total torque
        var engineTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("EngineTotalTorque"));
        Connection.connect(engine.totalTorqueOutput, engineTotalTorque.input);

        var clutchTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("ClutchTotalTorque"));
        Connection.connect(clutch.totalTorqueOutput, clutchTotalTorque.input);

        var wheelTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("WheelTotalTorque"));
        Connection.connect(wheel.totalTorqueOutput, wheelTotalTorque.input);

        // effective inertia
        var engineEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("EngineEffectiveInertia"));
        Connection.connect(engine.effectiveInertiaOutput, engineEffectiveInertia.input);

        var clutchEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("ClutchEffectiveInertia"));
        Connection.connect(clutch.effectiveInertiaOutput, clutchEffectiveInertia.input);

        var wheelEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("WheelEffectiveInertia"));
        Connection.connect(wheel.effectiveInertiaOutput, wheelEffectiveInertia.input);

        // angular velocity
        var engineAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("EngineAngularVelocity"));
        Connection.connect(engine.angularVelocityOutput, engineAngularVelocity.input);

        var clutchAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("ClutchAngularVelocity"));
        Connection.connect(clutch.angularVelocityOutput, clutchAngularVelocity.input);

        var wheelAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("WheelAngularVelocity"));
        Connection.connect(wheel.angularVelocityOutput, wheelAngularVelocity.input);

        // clutch ratio
        var clutchRatioConsumer:DebugConsumer = new DebugConsumer(new NumberInput("ClutchRatio"));
        Connection.connect(clutchRatio.output, clutchRatioConsumer.input);

        //var time:int = getTimer();
        const stepCount:int = 15;
        for(var i:int = 0, c:Number = 0.0; i < stepCount; ++i, c = Math.abs(c - 1) > 0.1 ? c + 0.1 : 1) {
            clutchRatio.value = c;

            timeStepper.pushTimeStep(0.1);

            trace("Clutch[" + i + "]:");
            clutchRatioConsumer.pullData();

            trace("Inertia[" + i + "]:");
            engineEffectiveInertia.pullData();
            clutchEffectiveInertia.pullData();
            wheelEffectiveInertia.pullData();

            trace("Torque[" + i + "]:");
            engineTotalTorque.pullData();
            clutchTotalTorque.pullData();
            wheelTotalTorque.pullData();

            trace("Velocity[" + i + "]:");
            engineAngularVelocity.pullData();
            clutchAngularVelocity.pullData();
            wheelAngularVelocity.pullData();
        }

        c = 0;

        for(i = 0; i < stepCount + stepCount / 2; ++i) {
            clutchRatio.value = c;

            timeStepper.pushTimeStep(0.1);

            trace("Clutch[" + i + "]:");
            clutchRatioConsumer.pullData();

            trace("Inertia[" + i + "]:");
            engineEffectiveInertia.pullData();
            clutchEffectiveInertia.pullData();
            wheelEffectiveInertia.pullData();

            trace("Torque[" + i + "]:");
            engineTotalTorque.pullData();
            clutchTotalTorque.pullData();
            wheelTotalTorque.pullData();

            trace("Velocity[" + i + "]:");
            engineAngularVelocity.pullData();
            clutchAngularVelocity.pullData();
            wheelAngularVelocity.pullData();
        }

        for(i = 0; i < stepCount + stepCount; ++i, c = Math.abs(c - 1) > 0.1 ? c + 0.1 : 1) {
            clutchRatio.value = c;

            timeStepper.pushTimeStep(0.1);

            trace("Clutch[" + i + "]:");
            clutchRatioConsumer.pullData();

            trace("Inertia[" + i + "]:");
            engineEffectiveInertia.pullData();
            clutchEffectiveInertia.pullData();
            wheelEffectiveInertia.pullData();

            trace("Torque[" + i + "]:");
            engineTotalTorque.pullData();
            clutchTotalTorque.pullData();
            wheelTotalTorque.pullData();

            trace("Velocity[" + i + "]:");
            engineAngularVelocity.pullData();
            clutchAngularVelocity.pullData();
            wheelAngularVelocity.pullData();
        }

        //trace("elapsed: " + (getTimer() - time));
    }

    private function RWDDrivetrainTest():void {
        var timeStepper:TimeStepper = new TimeStepper("TimeStepper");
        var engine:EngineComponent = new EngineComponent("Engine");
        var engineVelStore:SteppableValueStore = new SteppableValueStore("EngineAngularVelocityStore");
        var gearbox:DrivetrainComponent = new DrivetrainComponent("Gearbox");
        var gearboxVelForwarder:ValueForwarder = new ValueForwarder("GearboxAngularVelocityForwarder");
        var differential:DifferentialComponent = new DifferentialComponent(0.5, "Differential");
        var differentialVelForwarder:ValueForwarder = new ValueForwarder("DifferentialAngularVelocityForwarder");
        var torqueStore:IExcessTorqueStore = new ExcessTorqueStore("OpenDiffStore");
        var leftWheel:DrivetrainComponent = new DrivetrainComponent("LeftWheel");
        var leftWheelVelStore:SteppableValueStore = new SteppableValueStore("LeftWheelAngularVelocityStore");
        var rightWheel:DrivetrainComponent = new DrivetrainComponent("RightWheel");
        var rightWheelVelStore:SteppableValueStore = new SteppableValueStore("RightWheelAngularVelocityStore");

        engine.connectNextComponent(gearbox);
        gearbox.connectNextComponent(differential);
        differential.connectNextComponent(leftWheel);
        differential.connectNextComponent(rightWheel);
        differential.connectExcessTorqueStore(torqueStore);

        // engine
        var engineTorque:ValueProvider = new ValueProvider(new NumberOutput("EngineTorque"));
        engineTorque.value = 100;
        var engineInertia:ValueProvider = new ValueProvider(new NumberOutput("EngineInertia"));
        engineInertia.value = 0.2;
        //engineInertia.value = 2;

        Connection.connect(engineTorque.output, engine.torqueInput);
        Connection.connect(engineInertia.output, engine.inertiaInput);

        Connection.connect(engine.newAngularVelocityOutput, engineVelStore.angularVelocityInput);
        Connection.connect(engineVelStore.angularVelocityOutput, engine.angularVelocityInput);
        Connection.connect(engineVelStore.stepDurationOutput, engine.stepDurationInput);

        Connection.connect(timeStepper.timeStepOutput, engineVelStore.timeStepInput);

        // gearbox
        var gearTorque:ValueProvider = new ValueProvider(new NumberOutput("GearTorque"));
        gearTorque.value = 200;
        var gearRatio:ValueProvider = new ValueProvider(new NumberOutput("GearRatio"));
        gearRatio.value = 2;
        var gearInertia:ValueProvider = new ValueProvider(new NumberOutput("GearInertia"));
        gearInertia.value = 0.15;
        //gearInertia.value = 3;

        //Connection.connect(gearTorque.output, gearbox.torqueInput);
        Connection.connect(gearRatio.output, gearbox.gearRatioInput);
        Connection.connect(gearInertia.output, gearbox.inertiaInput);

        Connection.connect(gearboxVelForwarder.angularVelocityOutput, gearbox.angularVelocityInput);

        // differential
        var diffTorque:ValueProvider = new ValueProvider(new NumberOutput("DiffTorque"));
        diffTorque.value = 800;
        var diffRatio:ValueProvider = new ValueProvider(new NumberOutput("DiffRatio"));
        diffRatio.value = 4;
        var diffInertia:ValueProvider = new ValueProvider(new NumberOutput("DiffInertia"));
        diffInertia.value = 0.1;
        //diffInertia.value = 5;

        //Connection.connect(diffTorque.output, differential.torqueInput);
        Connection.connect(diffRatio.output, differential.gearRatioInput);
        Connection.connect(diffInertia.output, differential.inertiaInput);

        Connection.connect(differential.angularVelocityOutput, gearboxVelForwarder.angularVelocityInput);
        Connection.connect(diffRatio.output, gearboxVelForwarder.gearRatioInput);

        Connection.connect(differentialVelForwarder.angularVelocityOutput, differential.angularVelocityInput);

        // left wheel
        var leftWheelInertia:ValueProvider = new ValueProvider(new NumberOutput("LeftWheelInertia"));
        leftWheelInertia.value = 10;
        var leftWheelTorque:ValueProvider = new ValueProvider(new NumberOutput("LeftWheelTorque"));
        leftWheelTorque.value = -300;

        Connection.connect(leftWheelInertia.output, leftWheel.inertiaInput);
        Connection.connect(leftWheelTorque.output, leftWheel.torqueInput);

        Connection.connect(leftWheel.newAngularVelocityOutput, leftWheelVelStore.angularVelocityInput);
        Connection.connect(leftWheelVelStore.angularVelocityOutput, leftWheel.angularVelocityInput);

        Connection.connect(leftWheel.angularVelocityOutput, differentialVelForwarder.angularVelocityInput);
        Connection.connect(leftWheelVelStore.stepDurationOutput, leftWheel.stepDurationInput);

        Connection.connect(timeStepper.timeStepOutput, leftWheelVelStore.timeStepInput);

        // right wheel
        var rightWheelInertia:ValueProvider = new ValueProvider(new NumberOutput("RightWheelInertia"));
        rightWheelInertia.value = 10;
        var rightWheelTorque:ValueProvider = new ValueProvider(new NumberOutput("RightWheelTorque"));
        rightWheelTorque.value = -310;

        Connection.connect(rightWheelInertia.output, rightWheel.inertiaInput);
        Connection.connect(rightWheelTorque.output, rightWheel.torqueInput);

        Connection.connect(rightWheel.newAngularVelocityOutput, rightWheelVelStore.angularVelocityInput);
        Connection.connect(rightWheelVelStore.angularVelocityOutput, rightWheel.angularVelocityInput);

        Connection.connect(rightWheel.angularVelocityOutput, differentialVelForwarder.angularVelocityInput);
        Connection.connect(rightWheelVelStore.stepDurationOutput, rightWheel.stepDurationInput);

        Connection.connect(timeStepper.timeStepOutput, rightWheelVelStore.timeStepInput);

        // total torque
        var engineTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("EngineTotalTorque"));
        Connection.connect(engine.totalTorqueOutput, engineTotalTorque.input);

        var gearboxTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("GearboxTotalTorque"));
        Connection.connect(gearbox.totalTorqueOutput, gearboxTotalTorque.input);

        var diffTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("DiffTotalTorque"));
        Connection.connect(differential.totalTorqueOutput, diffTotalTorque.input);

        var diffExcessTorque:DebugConsumer = new DebugConsumer(new NumberInput("DiffExcessTorque"));
        Connection.connect(torqueStore.torqueOutput, diffExcessTorque.input);

        var leftWheelTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("LeftWheelTotalTorque"));
        Connection.connect(leftWheel.totalTorqueOutput, leftWheelTotalTorque.input);

        var rightWheelTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("RightWheelTotalTorque"));
        Connection.connect(rightWheel.totalTorqueOutput, rightWheelTotalTorque.input);

        // effective inertia
        var engineEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("EngineEffectiveInertia"));
        Connection.connect(engine.effectiveInertiaOutput, engineEffectiveInertia.input);

        var gearboxEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("GearboxEffectiveInertia"));
        Connection.connect(gearbox.effectiveInertiaOutput, gearboxEffectiveInertia.input);

        var diffEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("DiffEffectiveInertia"));
        Connection.connect(differential.effectiveInertiaOutput, diffEffectiveInertia.input);

        var leftWheelEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("LeftWheelEffectiveInertia"));
        Connection.connect(leftWheel.effectiveInertiaOutput, leftWheelEffectiveInertia.input);

        var rightWheelEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("RightWheelEffectiveInertia"));
        Connection.connect(rightWheel.effectiveInertiaOutput, rightWheelEffectiveInertia.input);

        // angular velocity
        var engineAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("EngineAngularVelocity"));
        Connection.connect(engine.angularVelocityOutput, engineAngularVelocity.input);

        var gearboxAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("GearboxAngularVelocity"));
        Connection.connect(gearbox.angularVelocityOutput, gearboxAngularVelocity.input);

        var diffAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("DiffAngularVelocity"));
        Connection.connect(differential.angularVelocityOutput, diffAngularVelocity.input);

        var leftWheelAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("LeftWheelAngularVelocity"));
        Connection.connect(leftWheel.angularVelocityOutput, leftWheelAngularVelocity.input);

        var rightWheelAngularVelocity:DebugConsumer = new DebugConsumer(new NumberInput("RightWheelAngularVelocity"));
        Connection.connect(rightWheel.angularVelocityOutput, rightWheelAngularVelocity.input);

        Connection.connect(timeStepper.timeStepOutput, torqueStore.timeStepInput);

        trace("Inertia:");
        engineEffectiveInertia.pullData();
        gearboxEffectiveInertia.pullData();
        diffEffectiveInertia.pullData();
        leftWheelEffectiveInertia.pullData();
        rightWheelEffectiveInertia.pullData();

        var time:int = getTimer();
        for(var i:int = 0; i < 100; ++i)
            timeStepper.pushTimeStep(0.001);

        trace("elapsed: " + (getTimer() - time));

        trace("Torque[" + i + "]:");
        engineTotalTorque.pullData();
        gearboxTotalTorque.pullData();
        diffTotalTorque.pullData();
        diffExcessTorque.pullData();
        leftWheelTotalTorque.pullData();
        rightWheelTotalTorque.pullData();

        //torqueStore.pullTorque();
        trace("Pulled " + torqueStore.torque + " [Nm] of excess torque");

        trace("Velocity[" + i + "]:");
        engineAngularVelocity.pullData();
        gearboxAngularVelocity.pullData();
        diffAngularVelocity.pullData();
        leftWheelAngularVelocity.pullData();
        rightWheelAngularVelocity.pullData();
    }
}
}
