module physics;

import bindbc.newton;

/// This class is a wrapper for bindbc newton physics
public class Physics {
    NewtonWorld world;

    this() {
        world = NewtonWorld();
    }

    ~this() {
        NewtonDestroyAllBodies(&world);
    }


}