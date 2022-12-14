module code_vault.old_physics;

module physics;

import std.stdio;
import dmech.geometry;
import dmech.rigidbody;
import dmech.world;
import dlib.core.memory;
import dlib.math.vector;
import dlib.math.matrix;
import raylib;

/// This class is a wrapper for bindbc newton physics
public class PhysicsEngine {

    PhysicsWorld world;
    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    this() {
        this.world = New!PhysicsWorld(null);
    }

    ~this() {
        Delete(this.world);
    }

    RigidBody addGround() {
        RigidBody bGround = this.world.addStaticBody(Vector3f(0,-1,0));
        Geometry ground = New!GeomBox(this.world, Vector3f(40, 1, 40));
        this.world.addShapeComponent(bGround, ground, Vector3f(0,0,0), 1);

        return bGround;
    }

    RigidBody addBody() {
        // bSphere - dynamic sphere with radius of 1 m and mass of 1 kg 
        RigidBody bSphere = world.addDynamicBody(Vector3f(-4.0f, 20.0f, 0.0f), 0.0f);
        Geometry gSphere = New!GeomSphere(world, 1.0f);
        world.addShapeComponent(bSphere, gSphere, Vector3f(0.0f, 0.0f, 0.0f), 1.0f);

        return bSphere;
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
        world.update(this.lockedTick);
    }
    
    auto get() {
        return world.shapeComponents;
    }

}










