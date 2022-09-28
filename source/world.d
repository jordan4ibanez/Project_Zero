module world;

import std.stdio;
import raylib;
import std.uuid;

/// This is an extremely basic physics engine that uses AABB physics to work
public class World {

    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    
    Entity[UUID] entities;
    RigidBody[UUID] rigidBodies;

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

/// Entities are 3D boxes that can rotate their models. This is a base class that should be extended.
public class Entity {
    
    protected Vector3 position;
    protected Vector3 size;
    protected Vector3 velocity;
    
    /// Rotation is only used for rotating the model of an entity
    protected float rotation;

    this(Vector3 position, Vector3 size, Vector3 velocity) {
        /// Moving these values off the stack
        this.position = *new Vector3(position.x, position.y, position.z);
        this.size     = *new Vector3(size.x / 2, size.y / 2, size.z / 2);
        this.velocity = *new Vector3(velocity.x, velocity.y, velocity.z);
    }

    /// Allows quick rendering and collision detection.
    final
    BoundingBox getBoundingBox() {
        return BoundingBox(
            Vector3(
                this.position.x - this.size.x,
                this.position.y - this.size.y,
                this.position.z - this.size.z
            ),
            Vector3(
                this.position.x + this.size.x,
                this.position.y + this.size.y,
                this.position.z + this.size.z
            )
        );
    }

    void drawCollisionBox() {
        DrawBoundingBox(this.getBoundingBox(), Colors.RED);
    }
}

/// Rigid bodies are simply cuboids that contain other rigid bodies
public class RigidBody {
    BoundingBox boundingBox;
    Vector3 position;
}


public class Point {
    Vector2 position;
    Vector2 velocity;
    this(float posX, float posY) {
        this.position = *new Vector2(posX, posY);
        this.velocity = *new Vector2(0.01, -0.1);
    }

    void update() {
        this.position.x += this.velocity.x;
        this.position.y += this.velocity.y;
    }

    void draw() {
        DrawCircle(cast(int)this.position.x, cast(int)this.position.y,3, Colors.GOLD);
    }
}

public class Line {

    Vector2 start;
    Vector2 end;

    this(Vector2 start, Vector2 end) {
        this.start = start;
        this.end   = end;
    }

    void draw() {
        DrawLine(cast(int) this.start.x, cast(int) this.start.y, cast(int) this.end.x, cast(int) this.end.y, Colors.BLUE); 
    }
}

float collidePointToLine(Vector2 point, Line line) {
    float pointX = point.x;
    float pointY = point.y;

    float startX = line.start.x;
    float startY = line.start.y;
    float endX   = line.end.x;
    float endY   = line.end.y;

    /// First we must check if it's within bounds on the X axis
    if (pointX >= startX && pointX <= endX) {

        /// Next, we check the percentage of the line
        float lineSize = endX - startX;
        float distanceFromStart = pointX - startX;
        float percentage = distanceFromStart / lineSize;

        /// Now we need to check which is the high point on the Y axis
        float yMax = endY - startY;

        float collisionHeight = (yMax * percentage) + startY;

        float diff = pointY - collisionHeight;

        if (diff <= 0) {
            return collisionHeight + 0.01;
        }
    }
    return float.nan;
}

public class Point3D {
    Vector3 position;
    Vector3 velocity;
    this(float posX, float posY, float posZ) {
        this.position = *new Vector3(posX, posY, posZ);
        this.velocity = *new Vector3(0.0, -0.001, 0.0);
    }

    void update() {
        this.position.x += this.velocity.x;
        this.position.y += this.velocity.y;
        this.position.z += this.velocity.z;
    }

    void draw() {
        DrawSphere(this.position, 0.1, Colors.MAGENTA);
    }
}


/**
 * The map's base is a heightmap based on quads, these are fixed size of 1x1.
 * Therefor, we only need the Y positions of the quads.
 */
public class MapQuad {
    float[] yPoints;
    Line xMinLine;
    Line xMaxLine;

    Line zCrossRefLine;
    
    this( float yPosNXNZ, float yPosPXNZ, float yPosNXPZ, float yPosPXPZ){
        this.yPoints = new float[4];
        // y: negative x, negative z
        this.yPoints[0] = yPosNXNZ;
        // y: negative x, positive z
        this.yPoints[1] = yPosNXPZ;
        // y: positive x, positive z
        this.yPoints[2] = yPosPXPZ;
        // y: positive x, negative z
        this.yPoints[3] = yPosPXNZ;

        float posX = 0;
        float posZ = 0;

        this.xMinLine = new Line(Vector2(posX, yPosNXNZ), Vector2(posX + 1, yPosNXPZ));
        this.zCrossRefLine = new Line(Vector2(posZ, yPosPXNZ), Vector2(posZ + 1, yPosPXPZ));
    }

    void draw() {

        // Tri 1
        DrawTriangle3D(
            Vector3(
                0,
                yPoints[0],
                0
            ),
            Vector3(
                0,
                yPoints[1],
                1
            ),
            Vector3(
                1,
                yPoints[2],
                1
            ),
            Colors.GREEN
        );

        // Tri 2
        DrawTriangle3D(
            Vector3(
                1,
                yPoints[2],
                1
            ),
            Vector3(
                1,
                yPoints[3],
                0
            ),
            Vector3(
                0,
                yPoints[0],
                0
            ),
            Colors.GOLD
        );
    }
}


void collide3DPointToMapQuad(Point3D point, MapQuad quad) {
    float posX = point.position.x;
    float posY = point.position.y;
    float posZ = point.position.z;

    Line minXLine = quad.xMinLine;
    Line maxXLine = quad.xMaxLine;

    // float minCalculation = collidePointToLine(Vector2(posX, posY),minXLine);
    // float maxCalculation = collidePointToLine(Vector2(posX, posY),maxXLine);

    //writeln(minCalculation, " ", maxCalculation);

}