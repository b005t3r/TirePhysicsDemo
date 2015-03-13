/**
 * User: booster
 * Date: 11/03/15
 * Time: 9:23
 */
package drive {
import drive.components.DifferentialComponent;
import drive.components.DrivetrainComponent;
import drive.components.EngineComponent;

import plugs.Connection;
import plugs.consumers.DebugConsumer;
import plugs.inputs.NumberInput;

import plugs.outputs.NumberOutput;

import plugs.providers.ValueProvider;

public class Drivetrain {
    public function Drivetrain() {
        var engine:EngineComponent              = new EngineComponent("Engine");
        var gearbox:DrivetrainComponent         = new DrivetrainComponent("Gearbox");
        var differential:DifferentialComponent  = new DifferentialComponent(0.5, "Differential");
        var leftWheel:DrivetrainComponent       = new DrivetrainComponent("LeftWheel");
        var rightWheel:DrivetrainComponent      = new DrivetrainComponent("RightWheel");

        engine.connectNextComponent(gearbox);
        gearbox.connectNextComponent(differential);
        //differential.connectNextComponent(leftWheel);
        //differential.connectNextComponent(rightWheel);

        var engineTorque:ValueProvider = new ValueProvider(new NumberOutput("EngineTorque"));
        engineTorque.value = 100;
        var engineInertia:ValueProvider = new ValueProvider(new NumberOutput("EngineInertia"));
        //engineInertia.value = 0.2;
        engineInertia.value = 2;

        Connection.connect(engineTorque.output, engine.torqueInput);
        Connection.connect(engineInertia.output, engine.inertiaInput);

        var gearRatio:ValueProvider = new ValueProvider(new NumberOutput("GearRatio"));
        gearRatio.value = 2;
        var gearInertia:ValueProvider = new ValueProvider(new NumberOutput("GearInertia"));
        //gearInertia.value = 0.15;
        gearInertia.value = 3;

        Connection.connect(gearRatio.output, gearbox.gearRatioInput);
        Connection.connect(gearInertia.output, gearbox.inertiaInput);

        var diffRatio:ValueProvider = new ValueProvider(new NumberOutput("DiffRatio"));
        diffRatio.value = 4;
        var diffInertia:ValueProvider = new ValueProvider(new NumberOutput("DiffInertia"));
        //diffInertia.value = 0.1;
        diffInertia.value = 5;

        Connection.connect(diffRatio.output, differential.gearRatioInput);
        Connection.connect(diffInertia.output, differential.inertiaInput);

        // total torque
        var engineTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("EngineTotalTorque"));
        Connection.connect(engine.totalTorqueOutput, engineTotalTorque.input);

        var gearboxTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("GearboxTotalTorque"));
        Connection.connect(gearbox.totalTorqueOutput, gearboxTotalTorque.input);

        var diffTotalTorque:DebugConsumer = new DebugConsumer(new NumberInput("DiffTotalTorque"));
        Connection.connect(differential.totalTorqueOutput, diffTotalTorque.input);

        // effective inertia
        var engineEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("EngineEffectiveInertia"));
        Connection.connect(engine.effectiveInertiaOutput, engineEffectiveInertia.input);

        var gearboxEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("GearboxEffectiveInertia"));
        Connection.connect(gearbox.effectiveInertiaOutput, gearboxEffectiveInertia.input);

        var diffEffectiveInertia:DebugConsumer = new DebugConsumer(new NumberInput("DiffEffectiveInertia"));
        Connection.connect(differential.effectiveInertiaOutput, diffEffectiveInertia.input);

        engineTotalTorque.pullData();
        gearboxTotalTorque.pullData();
        diffTotalTorque.pullData();

        engineEffectiveInertia.pullData();
        gearboxEffectiveInertia.pullData();
        diffEffectiveInertia.pullData();
    }
}
}
