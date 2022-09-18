module player;

import raylib;
import std.stdio;

public class Player {

    Vector3 position;
    Vector3 size;

    this(Vector3 position, Vector3 size) {
        this.position = position;
        this.size     = size;
    }
}