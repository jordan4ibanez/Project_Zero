module entity;

import raylib;
import std.stdio: writeln;

/**
 * Entities are always a circle, allows easier integration into raylib collision detection.
 */
public class Entity {

    protected Vector2 position;
    protected Vector2 speed;
    protected float size;
    
    final
    Vector2 getPosition() {
        return this.position;
    }

    final
    float getX() {
        return this.position.x;
    }

    final
    float getY() {
        return this.position.y;
    }

    final
    void setPosition(Vector2 newPosition) {
        this.position = newPosition;
    }    

    final
    float getSize() {
        return this.size;
    }

    final
    void setSize(float newSize) {
        this.size = newSize;
    }

    final
    Vector2 getSpeed() {
        return this.speed;
    }

    final
    void setSpeed(Vector2 newSpeed) {
        this.speed = newSpeed;
    }

    void move(){writeln("Move function has not been defined.");}

    void update(){writeln("Update function has not been defined");}
    
    void die(){writeln("Die function has not been defined");}

    void hurt(){writeln("Hurt function has not been defined");}
}