module world;

import std.stdio;
import raylib;
import std.uuid;
import std.math.algebraic: sqrt;
import std.math.rounding: floor;

/// This is an extremely basic physics engine that uses AABB physics to work
public class World {

    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    MapQuad[] heightMap;
    int heightMapSize;

    Entity[UUID] entities;
    RigidBody[UUID] rigidBodies;

    this() {

    }

    /*
     * Size needs to be odd, heightmaps are created via quads, and they overlap data!
     * If not, this will absolutely crash!
     */
    void uploadHeightMap(float[] heightMap) {

        /// This is error prone, but D has no integer sqrt function
        this.heightMapSize = cast(int)floor(sqrt(floor(cast(float)heightMap.length)));

        float get(int x, int z) {
            if (x < 0 || x > this.heightMapSize - 1) {
                throw new Exception("X getter is out of bounds for heightmap!");
            }
            if (z < 0 || z > this.heightMapSize - 1) {
                throw new Exception("Z getter is out of bounds for heightmap!");
            }
            return heightMap[(x * this.heightMapSize) + z];
        }


        writeln("height map size: ", this.heightMapSize);

        get(1,2);

        
        for (int x = 0; x < this.heightMapSize - 1; x++) {
            for (int z = 0; z < this.heightMapSize - 1; z++) {
                
                this.heightMap ~= new MapQuad(
                    Vector2(x,z),
                    get(x,z),
                    get(x+1,z),
                    get(x,z+1),
                    get(x+1,z+1),
                    0.25
                );
            }
        }        
    }

    void drawHeightMap() {
        foreach (MapQuad quad; this.heightMap) {
            quad.draw();
        }
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


/**
 * The map's base is a heightmap based on quads, these are fixed size of 1x1.
 * Therefor, we only need the Y positions of the quads.
 */
public class MapQuad {
    float[] yPoints;
    Vector2 position;
    float tileSize;

    /// This looks suspiciously like an OpenGL quad from 2 tris. Well that's because it is.
    this(
        Vector2 position,
        float yPosNegativeXNegativeZ,
        float yPosPositiveXNegativeZ,
        float yPosNegativeXPositiveZ,
        float yPosPositiveXPositiveZ,
        float tileSize
    ){
        this.yPoints = new float[4];
        // y: negative x, negative z
        this.yPoints[0] = yPosNegativeXNegativeZ;
        // y: negative x, positive z
        this.yPoints[1] = yPosNegativeXPositiveZ;
        // y: positive x, positive z
        this.yPoints[2] = yPosPositiveXPositiveZ;
        // y: positive x, negative z
        this.yPoints[3] = yPosPositiveXNegativeZ;

        this.position = *new Vector2(position.x, position.y);
        this.tileSize = tileSize;
    }

    void draw() {

        // Tri 1
        DrawTriangle3D(
            Vector3(
                this.position.x * this.tileSize,
                yPoints[0],
                this.position.y * this.tileSize
            ),
            Vector3(
                this.position.x * this.tileSize,
                yPoints[1],
                (this.position.y + 1)  * this.tileSize
            ),
            Vector3(
                (this.position.x + 1) * this.tileSize,
                yPoints[2],
                (this.position.y + 1) * this.tileSize
            ),
            Colors.GREEN
        );

        // Tri 2
        DrawTriangle3D(
            Vector3(
                (this.position.x + 1) * this.tileSize,
                yPoints[2],
                (this.position.y + 1) * this.tileSize
            ),
            Vector3(
                (this.position.x + 1) * this.tileSize,
                yPoints[3],
                this.position.y * this.tileSize
            ),
            Vector3(
                this.position.x * this.tileSize,
                yPoints[0],
                this.position.y * this.tileSize
            ),
            Colors.GOLD
        );
    }
}


void collidePointToMapQuad(Vector3 point, MapQuad quad) {
    float posX = point.x;
    float posY = point.y;
    float posZ = point.z;

    float baseX = 0;
    float baseZ = 0;

    Vector3 lerpedMin = Vector3Lerp(Vector3(0, quad.yPoints[0], 0),Vector3(1,quad.yPoints[3]), posX - baseX);
    Vector3 lerpedMax = Vector3Lerp(Vector3(0, quad.yPoints[1], 0),Vector3(1,quad.yPoints[2]), posX - baseX);

    Vector3 combined = Vector3Lerp(lerpedMin, lerpedMax, posZ - baseZ);

    if (posY < combined.y) {
        point.y = combined.y + 0.00001;
    }
}