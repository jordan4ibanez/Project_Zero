module physics;

import std.stdio;
import bindbc.newton;

public bool loadNewtonLibrary() {
    NewtonSupport returnedVersion;

    version(Windows) {
        returnedVersion = loadNewton("newton.dll");
    } else {
        // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
        returnedVersion = loadNewton();
    }

    if (returnedVersion != NewtonSupport.newton314) {
        writeln("NEWTON 3.14 FAILED TO LOAD!");
        // Handle error. For most use cases, its reasonable to use the the error handling API in
        // bindbc-loader to retrieve error messages for logging and then abort. If necessary, it's
        // possible to determine the root cause via the return value:
        if(returnedVersion == NewtonSupport.noLibrary) {
            writeln("Newton shared library failed to load!");
        } else if (returnedVersion == NewtonSupport.badLibrary) {
            writeln("One or more symbols failed to load. The likely cause is that the",
            "shared library is a version different from the one the app was",
            "configured to load");
        }
        return true;
    }

    writeln("Newton 3.14 loaded successfully!");

    return false;
}

/// This class is a wrapper for bindbc newton physics
public class Physics {

    private NewtonWorld* world;

    private int entity_count;

    this() {
        this.world = NewtonCreate();
        this.entity_count = 0;
    }

    ~this() {
        NewtonDestroyAllBodies(this.world);
        NewtonDestroy(this.world);
    }




}