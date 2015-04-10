/**
 * User: booster
 * Date: 05/03/15
 * Time: 9:27
 */
package tire {
import flash.filesystem.File;

import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;
import medkit.object.Serializable;

public class TirePhysics implements Serializable {
    public static function sign(value:Number):Number {
        if(value < 0)       return -1.0;
        else if(value > 0)  return 1.0;
        else                return 0.0;
    }

    public static function sameSign(valueA:Number, valueB:Number, ignoreZero:Boolean = true):Boolean {
        if(ignoreZero && valueA == 0 || valueB == 0)
            return true;

        return sign(valueA) == sign(valueB);
    }

    public const gravity:Number             = 9.81;
    public var wheelMass:Number             = 20;
    public var wheelRadius:Number           = 0.33;
    public var wheelTorque:Number           = 1400;
    public var brakeTorque:Number           = 3200;
    public var carMass:Number               = 400;
    //public var wheelInertia:Number          = 0.5 * wheelMass * wheelRadius * wheelRadius;
    public var wheelInertiaLocked:Boolean   = true;
    public var wheelInertia:Number          = 20;

    public var coefSF:Number                = 0.9;
    public var coefKF:Number                = 1;
    public var airDensity:Number            = 1.29;
    public var frontalArea:Number           = 2.2; // = 1;
    public var coefDrag:Number              = 0.3; // = 0.525; // for the vehicle's shape
    public var coefAirDrag:Number           = 0.5 * airDensity * frontalArea * coefDrag; // * v * v = F
    public var coefRollingDrag:Number       = 0.015;

    // state variables
    public var wheelPos:Number              = 0;
    public var wheelPosVel:Number           = 0;
    public var wheelAngle:Number            = 0;
    public var wheelAngVel:Number           = 0;
    public var throttle:Number              = 0;
    public var brakes:Number                = 0;
    public var direction:Number             = 1;    // 1 for forward, -1 for reverse
    public var useStaticFriction:Boolean    = true;
    public var wasStaticFriction:Boolean    = true;
    public var slipRatio:Number             = 0;
    public var forceRatio:Number            = 0;
    public var responseTorque:Number        = 0;
    public var angAcceleration:Number       = 0;
    public var acceleration:Number          = 0;

    public var airDragForce:Number          = 0;
    public var airDragTorque:Number         = 0;
    public var rollingDragForce:Number      = 0;
    public var rollingDragTorque:Number     = 0;
    public var totalDragForce:Number        = 0;
    public var totalDragTorque:Number       = 0;

    public var longSlipRatios:Vector.<Number>  = new <Number>[ -1.0, -0.333, -0.20, -0.133, -0.066, -0.033, 0,  0.01,  0.02,  0.04,  0.06,  0.10,  0.30,  0.50];
    public var longForceRatios:Vector.<Number> = new <Number>[0.625,  0.875, 0.999,  0.981,  0.875,  0.625, 0, 0.625, 0.875, 0.981, 0.999, 0.875, 0.625, 0.525];

    public var staticForceRatio:Number              = 0.8;
    public var kineticSlipRatios:Vector.<Number>    = new <Number>[0,  0.02,  0.04,  0.08, 0.1,  0.15,  0.40,  0.75, 1.25, 2.0];
    public var kineticForceRatios:Vector.<Number>   = new <Number>[0, 0.625, 0.875, 0.981, 1.0, 0.875, 0.625, 0.525, 0.45, 0.4];
    public var kineticPeakSlipRatio:Number          = 0.06;

    public function TirePhysics() {
        var maxForce:Number     = kineticForceRatios[0];
        kineticPeakSlipRatio    = kineticSlipRatios[0];

        var count:int = kineticSlipRatios.length;
        for(var i:int = 1; i < count; ++i) {
            var slip:Number     = kineticSlipRatios[i];
            var force:Number    = kineticForceRatios[i];

            if(force <= maxForce)
                continue;

            kineticPeakSlipRatio    = slip;
            maxForce                = force;
        }

//                for(var a:Number = 0; a < 1.2; a += 0.05)
//                    trace(a + ":", getKineticForceRatio(a));
    }

    public function step(dt:Number, subStepCount:int):void {
        dt /= subStepCount;

        for(var i:int = 0; i < subStepCount; ++i) {
            var normalForce:Number          = (carMass + wheelMass) * gravity;
            var tireStaticLimit:Number      = staticForceRatio * normalForce * coefSF;

            var appliedTorque:Number        = wheelTorque * throttle * direction;
            var torqueForce:Number          = -appliedTorque / wheelRadius;

            var dragForceSign:Number        = sign(wheelPosVel) != 0 ? -sign(wheelPosVel) : sign(appliedTorque);
            var brakingTorqueSign:Number    = sign(wheelAngVel) != 0 ? -sign(wheelAngVel) : -dragForceSign;

            var brakingTorque:Number        = brakingTorqueSign * brakeTorque * brakes;
            var brakingForce:Number         = -brakingTorque / wheelRadius;

            airDragForce                    = dragForceSign * coefDrag * wheelPosVel * wheelPosVel;
            airDragTorque                   = -airDragForce * wheelRadius;
            rollingDragForce                = dragForceSign * coefRollingDrag * normalForce;
            rollingDragTorque               = -rollingDragForce * wheelRadius;
            totalDragForce                  = rollingDragForce;
            totalDragTorque                 = rollingDragTorque;

            // Total forces acting on the body, not created by the tire.
            // It transfers onto a tire (and from the tire back onto the body) up to a static limit. The excess force
            // does not make the tire spin more, but still acts on the body (changing the acceleration)
            var bodyTotalForce:Number       = airDragForce;
            var bodyStaticForce:Number      = Math.abs(bodyTotalForce) > tireStaticLimit ? sign(bodyTotalForce) * tireStaticLimit : bodyTotalForce;
            var bodyExcessForce:Number      = bodyTotalForce - bodyStaticForce;

            // TODO: edit this
            // A tire has a tireStaticLimit, which is how much force can it transfer without slipping - this is
            // described by tireStaticForce. If it slips just a little bit, it can transfer even more force, but
            // if it stats to slip too much, it'll go below its tireStaticLimit. This is described by tireKineticLimit.
            // Any force over tireStaticLimit but below tireKineticLimit accelerates the body and decelerates the wheel
            // (it creates a kinetic force pushing body forward and a torque which tries to slow down the wheel).
            // Anything above tireKineticLimit contributes only to increasing tire slip (which will in turn contribute
            // to changing the tireKineticLimit in the next iteration) - this is stored as tireExcessForce.
            // First, we calculate the tireStaticForce and tireExcessForce. Then the currently available tireKineticLimit
            // and using it we calculate tireKineticForce and eventually decrease tireExcessForce (some of it might increase
            // the tireKineticForce - all depending on the tireKineticLimit available).
            var tireTotalForce:Number   = torqueForce + brakingForce + bodyStaticForce + totalDragForce;
            var tireStaticForce:Number  = Math.abs(tireTotalForce) > tireStaticLimit ? sign(tireTotalForce) * tireStaticLimit : tireTotalForce;
            var tireExcessForce:Number  = tireTotalForce - tireStaticForce;

            var surfaceVel:Number       = wheelPosVel + wheelAngVel * wheelRadius;
            var tireKineticLimit:Number = -sign(surfaceVel) * getKineticForceRatio(slipRatio) * normalForce * coefSF;
            var tireKineticForce:Number;

            // static friction only
            if(tireKineticLimit == 0) {
                tireKineticForce = 0;
            }
            // kinetic friction, kinetic force pushes the opposite direction (or static force is 0)
            else if(! sameSign(tireStaticForce, tireKineticLimit, false)) {
                tireKineticForce = tireKineticLimit;
            }
            // kinetic friction, both forces push the same direction
            else {
                // slip ratio at or about to reach its optimum
                if(Math.abs(slipRatio) <= kineticPeakSlipRatio) {
                    var maxKineticLimit:Number  = getKineticForceRatio(sign(slipRatio) * kineticPeakSlipRatio) * normalForce * coefSF;
                    var boostRatio:Number       = tireKineticLimit / maxKineticLimit;
                    var kineticBoostLeft:Number = maxKineticLimit - tireStaticForce;

                    tireKineticForce                = kineticBoostLeft * boostRatio;
                    tireExcessForce                -= tireKineticForce;

                    // was all excess force used up
                    if(sign(maxKineticLimit) * tireExcessForce < 0)
                        tireExcessForce = 0;
                }
                // sub-optimal slip, past the optimum
                else {
                    tireKineticForce = tireKineticLimit - tireStaticForce;

                    // static force higher than kinetic limit
                    if(sign(tireKineticLimit) * tireKineticForce < 0) {
                        tireStaticForce    -= sign(tireKineticLimit) * tireKineticForce;
                        tireExcessForce    += sign(tireKineticLimit) * tireKineticForce;
                        tireKineticForce    = 0;
                    }
                    else {
                        tireExcessForce    -= sign(tireKineticLimit) * tireKineticForce;

                        // was all excess force used up
                        if(sign(tireKineticLimit) * tireExcessForce < 0)
                            tireExcessForce = 0;
                    }
                }
            }

            // compute longitudinal and angular accelerations based on tireStaticForce (no slipping)
            var acc:Number      = tireStaticForce / (carMass + wheelMass);
            var angAcc:Number   = -acc / wheelRadius;

            // add bodyExcessForce (like huge air resistance, e.g. wind)
            acc                += bodyExcessForce / (carMass + wheelMass);

            // add tireKineticForce to both - acc increases, angAcc decreases
            acc                += tireKineticForce / (carMass + wheelMass);
            angAcc             += tireKineticForce * wheelRadius / wheelInertia;

            // finally add tireExcessForce to increase angular acceleration
            angAcc             += -tireExcessForce * wheelRadius / wheelInertia;

            //compute new velocities
            var oldPosVel:Number = wheelPosVel;
            var oldAngVel:Number = wheelAngVel;
            wheelPosVel        += acc * dt;
            wheelAngVel        += angAcc * dt;

            // drag was high enough to stop body's roll
            if(! sameSign(oldAngVel, wheelAngVel, false) && (appliedTorque != 0 && ! sameSign(appliedTorque, wheelAngVel, false) || brakingTorque != 0 && sameSign(brakingTorque, wheelAngVel, false)))
                wheelAngVel = 0;

            // drag was high enough to stop the body
            if(! sameSign(oldPosVel, wheelPosVel, false) && torqueForce != 0 && ! sameSign(torqueForce, wheelPosVel, false))
                wheelPosVel = 0;

            // common integration
            wheelPos   += wheelPosVel * dt;
            wheelAngle += wheelAngVel * dt;

            wasStaticFriction   = tireKineticForce != 0;
            forceRatio          = getKineticForceRatio(slipRatio);
            acceleration        = acc;
            angAcceleration     = angAcc;
            responseTorque      = -(appliedTorque - angAcc * wheelInertia);

            const minVel:Number = 0.15;

            if(Math.abs(wheelPosVel) < minVel)
                slipRatio = 0;
            else
                slipRatio = direction * (wheelAngVel * wheelRadius + wheelPosVel) / Math.abs(wheelPosVel);
        }
    }

    public function validateInertia():void {
        if(wheelInertiaLocked)
            return;

        wheelInertia = 0.5 * wheelMass * wheelRadius * wheelRadius;
    }

    public function validateAirDrag():void {
        coefAirDrag = 0.5 * airDensity * frontalArea * coefDrag;
    }

    public function toString():String {
        var s:String =
            " | " +
            "i: " + int(direction * throttle * 100) + "%" + " | " +
            "x: " + int(wheelPos * 100) / 100 + "[m]" + " | " +
            "v: " + int(wheelPosVel * 100) / 100 + "[m/s]" + " | " +
            "α: " + int(wheelAngle * wheelRadius * 100) / 100 + "[m]" + " | " +
            "ω: " + int(wheelAngVel * wheelRadius * 100) / 100 + "[m/s]" + " | " +
            "s: " + int(slipRatio * 100) + "%" +" | " +
            "t: " + int(wheelTorque * throttle * direction * 100) / 100 + "[Nm]" + " | " +
            "tb: " + int(brakeTorque * brakes * 100) / 100 + "[Nm]" + " | " +
            "ta: " + int(airDragTorque * 100) / 100 + "[Nm]" +" | " +
            "tr: " + int(rollingDragTorque * 100) / 100 + "[Nm]" + " | " +
            "td: " + int(totalDragTorque * 100) / 100 + "[Nm]" + " | " +
            "f: " + (wasStaticFriction ? "static" : "kinetic") + " | "
        ;

        return s;
    }

    public function readObject(input:ObjectInputStream):void {
        wheelMass           = input.readNumber("wheelMass");
        wheelRadius         = input.readNumber("wheelRadius");
        wheelTorque         = input.readNumber("wheelTorque");
        brakeTorque         = input.readNumber("brakeTorque");
        carMass             = input.readNumber("carMass");
        wheelInertiaLocked  = input.readBoolean("wheelInertiaLocked");
        wheelInertia        = input.readNumber("wheelInertia");

        coefSF              = input.readNumber("coefSF");
        coefKF              = input.readNumber("coefKf");
        frontalArea         = input.readNumber("frontalArea");
        coefDrag            = input.readNumber("coefDrag");
        coefRollingDrag     = input.readNumber("coefRollingDrag");

        validateInertia();
        validateAirDrag();
    }

    public function writeObject(output:ObjectOutputStream):void {
        output.writeNumber(wheelMass, "wheelMass");
        output.writeNumber(wheelRadius, "wheelRadius");
        output.writeNumber(wheelTorque, "wheelTorque");
        output.writeNumber(brakeTorque, "brakeTorque");
        output.writeNumber(carMass, "carMass");
        output.writeBoolean(wheelInertiaLocked, "wheelInertiaLocked");
        output.writeNumber(wheelInertia, "wheelInertia");
        output.writeNumber(coefSF, "coefSF");
        output.writeNumber(coefKF, "coefKf");
        output.writeNumber(frontalArea, "frontalArea");
        output.writeNumber(coefDrag, "coefDrag");
        output.writeNumber(coefRollingDrag, "coefRollingDrag");
    }

    CONFIG::desktop
    public static function load():TirePhysics {
        var retVal:TirePhysics = null;

        try {
            var input:ObjectInputStream = ObjectInputStream.readFromFile(File.applicationStorageDirectory.resolvePath("settings"));
            retVal = input.readObject("root") as TirePhysics;
        }
        catch(e:Error) {
            return null;
        }

        return retVal;
    }

    CONFIG::web
    public static function load():TirePhysics { return null; }

    CONFIG::desktop
    public function save():void {
        var output:ObjectOutputStream = new ObjectOutputStream();
        output.writeObject(this, "root");
        output.saveToFile(File.applicationStorageDirectory.resolvePath("settings"));
    }

    CONFIG::web
    public function save():void { }

    private function getLongForceRatio(slipRatio:Number):Number {
        if(slipRatio <  longSlipRatios[0])                          return longForceRatios[0];
        if(slipRatio >  longSlipRatios[longSlipRatios.length - 1])  return longForceRatios[longForceRatios.length - 1];

        var count:int = longSlipRatios.length;
        for(var i:int = 0; i < count; ++i) {
            var maxSlipRatio:Number = longSlipRatios[i];

            if(maxSlipRatio == slipRatio)       return longForceRatios[i];
            else if (maxSlipRatio < slipRatio)  continue;

            var minSlipRatio:Number     = longSlipRatios[i - 1];
            var ratio:Number            = (slipRatio - minSlipRatio) / (maxSlipRatio - minSlipRatio);

            var maxForceRatio:Number    = longForceRatios[i];
            var minForceRatio:Number    = longForceRatios[i - 1];

            return minForceRatio + (maxForceRatio - minForceRatio) * ratio;
        }

        throw new Error("slip ratio not found?");
    }

    private function getKineticForceRatio(slipRatio:Number):Number {
        if(slipRatio == 0)
            return 0;

        var sr:Number = Math.abs(slipRatio);

        if(sr > kineticSlipRatios[kineticSlipRatios.length - 1])
            return kineticForceRatios[kineticForceRatios.length - 1];

        var count:int = kineticSlipRatios.length;
        for(var i:int = 0; i < count; ++i) {
            var maxSlipRatio:Number = kineticSlipRatios[i];

            if(maxSlipRatio == sr)       return kineticForceRatios[i];
            else if (maxSlipRatio < sr)  continue;

            var minSlipRatio:Number     = kineticSlipRatios[i - 1];
            var ratio:Number            = (sr - minSlipRatio) / (maxSlipRatio - minSlipRatio);

            var maxForceRatio:Number    = kineticForceRatios[i];
            var minForceRatio:Number    = kineticForceRatios[i - 1];
            var forceRatio:Number       = minForceRatio + (maxForceRatio - minForceRatio) * ratio;

            return forceRatio;
        }

        throw new Error("slip ratio not found?");
    }
}
}
