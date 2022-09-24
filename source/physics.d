module physics;

import std.stdio;
import raylib;

/// This class is a wrapper for bindbc newton physics
public class PhysicsEngine {

    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    private Vector2 size;

    this(float sizeX, float sizeY) {
        this.size = *new Vector2(sizeX, sizeY);
    }

    ~this() {
        
    }

    void addGround() {
        /*
        RigidBody bGround = this.world.addStaticBody(Vector3f(0,-1,0));
        Geometry ground = New!GeomBox(this.world, Vector3f(40, 1, 40));
        this.world.addShapeComponent(bGround, ground, Vector3f(0,0,0), 1);

        return bGround;
        */
    }

    void addBody() {

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

    void update() {
        
    }    

}










