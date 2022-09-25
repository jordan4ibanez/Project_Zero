module entity;

import raylib;
import std.stdio: writeln;

/**
 * Entities are a square
 */
public class Entity {

    protected Vector2 speed;
    protected Rectangle boundingBox;
    
    final
    Vector2 getPosition() {
        return Vector2(this.boundingBox.x, this.boundingBox.y);
    }

    final
    float getX() {
        return this.boundingBox.x + (this.boundingBox.width / 2);
    }

    final
    float getY() {
        return this.boundingBox.y + (this.boundingBox.height / 2);
    }

    final
    void setPosition(Vector2 newPosition) {
        this.boundingBox.x = newPosition.x;
        this.boundingBox.y = newPosition.y;
    }

    final
    Rectangle getBoundingBox() {
        return this.boundingBox;
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