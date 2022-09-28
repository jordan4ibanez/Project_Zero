module physics;

import std.stdio;
import raylib;
import std.uuid;

/// This is an extremely basic physics engine that uses AABB physics to work
public class PhysicsEngine {

    PhysicsWorld world;
    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;


    


    this() {

    }

    double getTimeAccumulator() {
        return this.timeAccumalator;
    }

    void setTimeAccumulator(double newValue) {
        this.timeAccumalator = newValue;
    }

    double getLockedTick() {
        return this.lockedTick;
    }

    /// Remember: this needs an external handler for fixed time stamps!
    void update() {

    }

}


/// Entities are 3D boxes that 
public class Entity {
    Vector3 position;
    Vector3 velocity;
    float rotation;
}