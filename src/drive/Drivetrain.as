/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:23
 */
package drive {
import drive.components.DifferentialComponent;
import drive.components.DrivetrainComponent;
import drive.components.EngineComponent;
import drive.components.IDifferentialExcessTorqueStore;
import drive.components.OpenDifferentialExcessTorqueStore;

import plugs.Connection;
import plugs.consumers.DebugConsumer;
import plugs.inputs.NumberInput;

import plugs.outputs.NumberOutput;

import plugs.providers.ValueProvider;

public class Drivetrain {
    public function Drivetrain() {
        var engine:EngineComponent                      = new EngineComponent("Engine");
        var gearbox:DrivetrainComponent                 = new DrivetrainComponent("Gearbox");
        var differential:DifferentialComponent          = new DifferentialComponent(0.5, "Differential");
        var torqueStore:IDifferentialExcessTorqueStore  = new OpenDifferentialExcessTorqueStore("OpenDiffStore");
        var leftWheel:DrivetrainComponent               = new DrivetrainComponent("LeftWheel");
        var rightWheel:DrivetrainComponent              = new DrivetrainComponent("RightWheel");

        engine.connectNextComponent(gearbox);
        gearbox.connectNextComponent(differential);
        differential.connectNextComponent(leftWheel);
        differential.connectNextComponent(rightWheel);
        differential.connectExcessTorqueStore(torqueStore);

        // engine
        var engineTorque:ValueProvider = new ValueProvider(new NumberOutput("EngineTorque"));
        engineTorque.value = 100;
        var engineInertia:ValueProvider = new ValueProvider(new NumberOutput("EngineInertia"));
        //engineInertia.value = 0.2;
        engineInertia.value = 2;

        Connection.connect(engineTorque.output, engine.torqueInput);
        Connection.connect(engineInertia.output, engine.inertiaInput);

        // gearbox
        var gearTorque:ValueProvider = new ValueProvider(new NumberOutput("GearTorque"));
        gearTorque.value = 200;
        var gearRatio:ValueProvider = new ValueProvider(new NumberOutput("GearRatio"));
        gearRatio.value = 2;
        var gearInertia:ValueProvider = new ValueProvider(new NumberOutput("GearInertia"));
        //gearInertia.value = 0.15;
        gearInertia.value = 3;

        //Connection.connect(gearTorque.output, gearbox.torqueInput);
        Connection.connect(gearRatio.output, gearbox.gearRatioInput);
        Connection.connect(gearInertia.output, gearbox.inertiaInput);

        // differential
        var diffTorque:ValueProvider = new ValueProvider(new NumberOutput("DiffTorque"));
        diffTorque.value = 800;
        var diffRatio:ValueProvider = new ValueProvider(new NumberOutput("DiffRatio"));
        diffRatio.value = 4;
        var diffInertia:ValueProvider = new ValueProvider(new NumberOutput("DiffInertia"));
        //diffInertia.value = 0.1;
        diffInertia.value = 5;

        //Connection.connect(diffTorque.output, differential.torqueInput);
        Connection.connect(diffRatio.output, differential.gearRatioInput);
        Connection.connect(diffInertia.output, differential.inertiaInput);

        // left wheel
        var leftWheelInertia:ValueProvider = new ValueProvider(new NumberOutput("LeftWheelInertia"));
        leftWheelInertia.value = 10;
        var leftWheelTorque:ValueProvider = new ValueProvider(new NumberOutput("LeftWheelTorque"));
        leftWheelTorque.value = -300;

        Connection.connect(leftWheelInertia.output, leftWheel.inertiaInput);
        Connection.connect(leftWheelTorque.output, leftWheel.torqueInput);

        // right wheel
        var rightWheelInertia:ValueProvider = new ValueProvider(new NumberOutput("RightWheelInertia"));
        rightWheelInertia.value = 10;
        var rightWheelTorque:ValueProvider = new ValueProvider(new NumberOutput("RightWheelTorque"));
        rightWheelTorque.value = -350;

        Connection.connect(rightWheelInertia.output, rightWheel.inertiaInput);
        Connection.connect(rightWheelTorque.output, rightWheel.torqueInput);

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

        var rightWheelEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("rightWheelEffectiveInertia"));
        Connection.connect(rightWheel.effectiveInertiaOutput, rightWheelEffectiveInertia.input);

        engineEffectiveInertia.pullData();
        gearboxEffectiveInertia.pullData();
        diffEffectiveInertia.pullData();
        leftWheelEffectiveInertia.pullData();
        rightWheelEffectiveInertia.pullData();

        trace();

        engineTotalTorque.pullData();
        gearboxTotalTorque.pullData();
        diffTotalTorque.pullData();
        diffExcessTorque.pullData();
        leftWheelTotalTorque.pullData();
        rightWheelTotalTorque.pullData();

        torqueStore.pullTorque();
        trace("Pulled " + torqueStore.torque + " [Nm] of excess torque");

        engineTotalTorque.pullData();
        gearboxTotalTorque.pullData();
        diffTotalTorque.pullData();
        diffExcessTorque.pullData();
        leftWheelTotalTorque.pullData();
        rightWheelTotalTorque.pullData();

        torqueStore.pullTorque();
        trace("Pulled " + torqueStore.torque + " [Nm] of excess torque");

        engineTotalTorque.pullData();
        gearboxTotalTorque.pullData();
        diffTotalTorque.pullData();
        diffExcessTorque.pullData();
        leftWheelTotalTorque.pullData();
        rightWheelTotalTorque.pullData();
    }
}
}
