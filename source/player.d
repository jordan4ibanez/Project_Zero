module player;

import raylib;
import std.stdio;



public class Player {

    private float size = 50;
    private Vector2 position;

    this(Vector2 position) {
        this.position = position;        
    }

    Vector2 getPosition() {
        return this.position;
    }

    float getX() {
        return this.position.x;
    }

    float getY() {
        return this.position.y;
    }

    float getSize() {
        return this.size;
    }
}