/**
 * User: booster
 * Date: 05/03/15
 * Time: 9:27
 */
package {

public class TirePhysics {
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
    public var wheelTorque:Number           = 2000;
    public var brakeTorque:Number           = 2000;
    public var carMass:Number               = 400;
    //public var wheelInertia:Number          = 0.5 * wheelMass * wheelRadius * wheelRadius;
    public var wheelInertia:Number          = 20;

    public var coefSF:Number                = 0.15;
    public var coefKf:Number                = 1;
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

    public var airDragForce:Number          = 0;
    public var airDragTorque:Number         = 0;
    public var rollingDragForce:Number      = 0;
    public var rollingDragTorque:Number     = 0;
    public var totalDragForce:Number        = 0;
    public var totalDragTorque:Number       = 0;

    public var longSlipRatios:Vector.<Number>  = new <Number>[ -1.0, -0.333, -0.20, -0.133, -0.066, -0.033, 0,  0.01,  0.02,  0.04,  0.06,  0.10,  0.30,  0.50];
    public var longForceRatios:Vector.<Number> = new <Number>[0.625,  0.875, 0.999,  0.981,  0.875,  0.625, 0, 0.625, 0.875, 0.981, 0.999, 0.875, 0.625, 0.525];

    public function TirePhysics() {
    }

    public function step(dt:Number, subStepCount:int):void {
        dt /= subStepCount;

        for(var i:int = 0; i < subStepCount; ++i) {
            var normalForce:Number          = (carMass + wheelMass) * gravity;
            var staticLimit:Number          = Math.abs(normalForce * coefSF);

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
            totalDragForce                  = airDragForce + rollingDragForce;
            totalDragTorque                 = airDragTorque + rollingDragTorque;

            // nothing's moving, switch for static friction at least for one iteration
            if (Math.abs(torqueForce - brakingForce) > staticLimit)
                useStaticFriction = false;

            //useStaticFriction = true;

            if (useStaticFriction) {
                //static friction, direct force feedback
                var staticResponseForce:Number = torqueForce + brakingForce + totalDragForce;

                //compute acceleration of system based on result force
                var acc:Number = (staticResponseForce) / (carMass + wheelMass);

                //compute new velocities
                var oldPosVel:Number = wheelPosVel;
                wheelPosVel    += acc * dt;
                wheelAngVel     = -wheelPosVel / wheelRadius;

                // drag was high enough to stop the body
                if(! sameSign(oldPosVel, wheelPosVel, false) && ! sameSign(torqueForce, wheelPosVel, false))
                    wheelPosVel = wheelAngVel = 0;

                wasStaticFriction = true;
            }
            else {
                // kinetic friction, wheel is sliding
                var wheelSurfaceVel:Number = wheelPosVel + wheelAngVel * wheelRadius;

                // sometimes float precision simply isn't enough
                if(Math.abs(wheelSurfaceVel) < 0.0001)
                    wheelSurfaceVel = 0.0;

                var kineticResponseForce:Number = -sign(wheelSurfaceVel) * normalForce * coefKf * getLongForceRatio(slipRatio);

                // feed friction force back into torque
                var responseTorque:Number       = kineticResponseForce * wheelRadius;
                var angAcc:Number               = (appliedTorque + responseTorque + brakingTorque + totalDragTorque) / wheelInertia;
                var oldAngVel:Number            = wheelAngVel;
                wheelAngVel                    += angAcc * dt;

                // feed friction force back into system
                var posAcc:Number       = (kineticResponseForce + totalDragForce) / (carMass + wheelMass);
                var kOldPosVel:Number   = wheelPosVel;
                wheelPosVel            += posAcc * dt;

                // drag was high enough to stop body's roll
                if(! sameSign(oldAngVel, wheelAngVel, false) && ! sameSign(appliedTorque, wheelAngVel, false))
                    wheelAngVel = 0;

                // drag was high enough to stop the body
                if(! sameSign(kOldPosVel, wheelPosVel, false) && ! sameSign(torqueForce, wheelPosVel, false))
                    wheelPosVel = 0;

                var newWheelSurfaceVel:Number = wheelPosVel + wheelAngVel * wheelRadius;

                // both velocities are temporarily on par, try switching back to static friction
                if(! sameSign(wheelSurfaceVel, newWheelSurfaceVel, false))
                    useStaticFriction = true;

                wasStaticFriction = false;
            }

            // common integration
            wheelPos   += wheelPosVel * dt;
            wheelAngle += wheelAngVel * dt;
            var newSlipRatio:Number = wheelPosVel != 0 ? (wheelAngVel * wheelRadius + wheelPosVel) / Math.abs(wheelPosVel) : 0.0;

            //slipRatio   = slipRatio * 0.5 + newSlipRatio * 0.5;
            slipRatio   = newSlipRatio;
        }
    }

    public function validateInertia():void {
        wheelInertia = 0.5 * wheelMass * wheelRadius * wheelRadius;
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
}
}
