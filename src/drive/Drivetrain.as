/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:23
 */
package drive {
import drive.components.differential.DifferentialComponent;
import drive.components.DrivetrainComponent;
import drive.components.engine.EngineComponent;
import drive.components.differential.IDifferentialExcessTorqueStore;
import drive.components.differential.OpenDifferentialExcessTorqueStore;
import drive.components.util.AngularVelocityForwarder;
import drive.components.util.AngularVelocityStore;
import drive.components.util.TimeStepper;

import flash.utils.getTimer;

import plugs.Connection;
import plugs.consumers.DebugConsumer;
import plugs.inputs.NumberInput;

import plugs.outputs.NumberOutput;

import plugs.providers.ValueProvider;

public class Drivetrain {
    public function Drivetrain() {
        var timeStepper:TimeStepper                             = new TimeStepper("TimeStepper");
        var engine:EngineComponent                              = new EngineComponent("Engine");
        var engineVelStore:AngularVelocityStore                 = new AngularVelocityStore("EngineAngularVelocityStore");
        var gearbox:DrivetrainComponent                         = new DrivetrainComponent("Gearbox");
        var gearboxVelForwarder:AngularVelocityForwarder        = new AngularVelocityForwarder("GearboxAngularVelocityForwarder");
        var differential:DifferentialComponent                  = new DifferentialComponent(0.5, "Differential");
        var differentialVelForwarder:AngularVelocityForwarder   = new AngularVelocityForwarder("DifferentialAngularVelocityForwarder");
        var torqueStore:IDifferentialExcessTorqueStore          = new OpenDifferentialExcessTorqueStore("OpenDiffStore");
        var leftWheel:DrivetrainComponent                       = new DrivetrainComponent("LeftWheel");
        var leftWheelVelStore:AngularVelocityStore              = new AngularVelocityStore("LeftWheelAngularVelocityStore");
        var rightWheel:DrivetrainComponent                      = new DrivetrainComponent("RightWheel");
        var rightWheelVelStore:AngularVelocityStore             = new AngularVelocityStore("RightWheelAngularVelocityStore");

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
        Connection.connect(engineVelStore.timeStepOutput, engine.timeStepInput);

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
        //Connection.connect(leftWheelTorque.output, leftWheel.torqueInput);

        Connection.connect(leftWheel.newAngularVelocityOutput, leftWheelVelStore.angularVelocityInput);
        Connection.connect(leftWheelVelStore.angularVelocityOutput, leftWheel.angularVelocityInput);

        Connection.connect(leftWheel.angularVelocityOutput, differentialVelForwarder.angularVelocityInput);
        Connection.connect(leftWheelVelStore.timeStepOutput, leftWheel.timeStepInput);

        Connection.connect(timeStepper.timeStepOutput, leftWheelVelStore.timeStepInput);

        // right wheel
        var rightWheelInertia:ValueProvider = new ValueProvider(new NumberOutput("RightWheelInertia"));
        rightWheelInertia.value = 10;
        var rightWheelTorque:ValueProvider = new ValueProvider(new NumberOutput("RightWheelTorque"));
        rightWheelTorque.value = -350;

        Connection.connect(rightWheelInertia.output, rightWheel.inertiaInput);
//        Connection.connect(rightWheelTorque.output, rightWheel.torqueInput);

        Connection.connect(rightWheel.newAngularVelocityOutput, rightWheelVelStore.angularVelocityInput);
        Connection.connect(rightWheelVelStore.angularVelocityOutput, rightWheel.angularVelocityInput);

        Connection.connect(rightWheel.angularVelocityOutput, differentialVelForwarder.angularVelocityInput);
        Connection.connect(rightWheelVelStore.timeStepOutput, rightWheel.timeStepInput);

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

        trace("Inertia:");
        engineEffectiveInertia.pullData();
        gearboxEffectiveInertia.pullData();
        diffEffectiveInertia.pullData();
        leftWheelEffectiveInertia.pullData();
        rightWheelEffectiveInertia.pullData();

        var time:int = getTimer();
        for(var i:int = 0; i < 10000; ++i)
            timeStepper.pushTimeStep(0.001);

        trace("elapsed: " + (getTimer() - time));

            trace("Torque[" + i + "]:");
            engineTotalTorque.pullData();
            gearboxTotalTorque.pullData();
            diffTotalTorque.pullData();
            diffExcessTorque.pullData();
            leftWheelTotalTorque.pullData();
            rightWheelTotalTorque.pullData();

            torqueStore.pullTorque();
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
