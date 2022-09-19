module physics;

import std.stdio;
import dmech.geometry;
import dmech.rigidbody;
import dmech.world;
import dlib.core.memory;
import dlib.math.vector;
import dlib.math.matrix;

/// This class is a wrapper for bindbc newton physics
public class Physics {
    PhysicsWorld world;

    this() {
        this.world = New!PhysicsWorld(null);
    }

}










