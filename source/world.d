module world;

import std.stdio;
import raylib;
import std.uuid;
import std.math.algebraic: sqrt, abs;
import std.math.rounding: floor;
import std.math.traits: isNaN;
import std.traits: Select, isFloatingPoint, isIntegral;
import std.algorithm.iteration: filter, map;
import std.array;

import game;

struct Vec2 {
    int x = 0;
    int z = 0;
}

/// This is an extremely basic physics engine that uses AABB physics to work
public class World {

    private Game game;

    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 60;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    immutable double gravity = lockedTick * 0.5;

    MapQuad[] heightMap;
    int heightMapSize;
    float quadScale;

    Entity[UUID] entities;
    // Structure[UUID] structures;

    Model terrainModel;

    Texture groundTexture;

    private bool ticked = false;

    private immutable float collisionQuadrantSize = 10;

    this(Game game) {
        this.game = game;

        Texture newGroundTexture = LoadTexture("textures/grass.png");
        GenTextureMipmaps(&newGroundTexture);
        SetTextureFilter(newGroundTexture, TextureFilter.TEXTURE_FILTER_TRILINEAR);
        this.groundTexture = newGroundTexture;
    }
    
    /// Add an entity into the entity associative array
    void addEntity(Entity newEntity) {
        this.entities[newEntity.getUUID()] = newEntity;
    }

    /*
     * Size needs to be a multiple of 250!
     */
    void uploadHeightMap(float[] heightMap, float quadScale) {

        /// This is error prone, but D has no integer sqrt function
        this.heightMapSize = cast(int)floor(sqrt(floor(cast(float)heightMap.length)));

        // int chunkSize = this.heightMapSize % 250;

        if (heightMapSize <= 0 || heightMapSize % 250 != 0) {
            throw new Exception("Map size must be multiple of 250!");
        }


        float get(int x, int z) {
            if (x < 0 || x > this.heightMapSize - 1) {
                throw new Exception("X getter is out of bounds for heightmap!");
            }
            if (z < 0 || z > this.heightMapSize - 1) {
                throw new Exception("Z getter is out of bounds for heightmap!");
            }
            return heightMap[(x * this.heightMapSize) + z];
        }

        ushort getIndex(int x, int z) {
            return cast(ushort)((x * this.heightMapSize) + z);
        }


        this.quadScale = quadScale;

        writeln("height map size: ", this.heightMapSize);

        
        for (int x = 0; x < this.heightMapSize - 1; x++) {
            for (int z = 0; z < this.heightMapSize - 1; z++) {
                this.heightMap ~= new MapQuad(
                    Vector2(x,z),
                    get(x,z),
                    get(x+1,z),
                    get(x,z+1),
                    get(x+1,z+1),
                    quadScale
                );
            }
        }

        writeln("beginning heightmap terrain gen! This needs to be a separate function");

        float[] vertices;
        float[] textureCoordinates;
        ushort[] indices;

        for (int x = 0; x < this.heightMapSize; x++) {
            for (int z = 0; z < this.heightMapSize; z++) {
                
                vertices ~= x * quadScale;
                vertices ~= get(x,z); // Y
                vertices ~= z * quadScale;
            }
        }

        for (int x = 0; x < this.heightMapSize - 1; x++) {
            for (int z = 0; z < this.heightMapSize - 1; z++) {
                /// Tri 1
                indices ~= getIndex(x,     z    );
                indices ~= getIndex(x    , z + 1);
                indices ~= getIndex(x + 1, z + 1);
                /// Tri 2
                indices ~= getIndex(x + 1, z + 1);
                indices ~= getIndex(x + 1, z    );
                indices ~= getIndex(x,     z    );
            }
        }

        for (int x = 0; x < this.heightMapSize; x++) {
            for (int z = 0; z < this.heightMapSize; z++) {
                /// This requires an ABSOLUTELY HUMONGOUS texture!!! :( <literal map to texture location>
                // textureCoordinates ~= cast(float)x / cast(float)this.heightMapSize;
                // textureCoordinates ~= cast(float)z / cast(float)this.heightMapSize;


                /// This just repeats :)
                textureCoordinates ~= x * this.quadScale;
                textureCoordinates ~= z * this.quadScale;
            }
        }

        Mesh terrainMesh = *new Mesh();

        terrainMesh.vertexCount = cast(int)vertices.length;
        terrainMesh.triangleCount = cast(int)indices.length / 3;
        writeln("vcount = ",terrainMesh.vertexCount);
        writeln("tcount = ", terrainMesh.triangleCount);
        terrainMesh.vertices  = vertices.ptr;
        terrainMesh.texcoords = cast(float*)textureCoordinates;
        terrainMesh.indices   = indices.ptr;

        UploadMesh(&terrainMesh, false);

        Model newTerrainModel = LoadModelFromMesh(terrainMesh);
        newTerrainModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = this.groundTexture;

        this.terrainModel = newTerrainModel;
    }

    MapQuad getQuad(float x, float z) {
        if (x < 0 || x > (this.heightMapSize - 1) * this.quadScale) {
            throw new Exception("X getter is out of bounds for heightmap!");
        }
        if (z < 0 || z > (this.heightMapSize - 1) * this.quadScale) {
            throw new Exception("Z getter is out of bounds for heightmap!");
        }

        int newX = cast(int)(floor(x / this.quadScale));
        int newZ = cast(int)(floor(z / this.quadScale));

        // writeln("----------------");
        // writeln("NewXZ: ", newX, " ", newZ);

        int index = (newX * (this.heightMapSize - 1)) + newZ;
        // writeln("Index: ", index);
        return heightMap[index];
    }

    float collidePointToMap(Vector3 point) {
        float posX = point.x;
        float posY = point.y;
        float posZ = point.z;

        MapQuad quad = this.getQuad(posX, posZ);

        float baseX = quad.position.x * this.quadScale;
        float baseZ = quad.position.y * this.quadScale;

        // writeln("quad position: ", quad.position);

        // writeln("subtraction: ",  posX - baseX);

        /// writeln("This lerp percentile: ", (posX - baseX) / this.quadScale);

        Vector3 lerpedMin = Vector3Lerp(Vector3(0, quad.yPoints[0], 0),Vector3(1,quad.yPoints[3], 0), (posX - baseX) / this.quadScale);
        Vector3 lerpedMax = Vector3Lerp(Vector3(0, quad.yPoints[1], 0),Vector3(1,quad.yPoints[2], 0), (posX - baseX) / this.quadScale);
        // writeln("--------------------");
        // writeln(lerpedMin, " ", lerpedMax);

        Vector3 combined = Vector3Lerp(lerpedMin, lerpedMax, (posZ - baseZ) / quadScale);

        if (posY < combined.y) {
            return combined.y;
        }

        return float.nan;
    }

    /// This function can be extremely laggy! Only use it for debugging on small terrains
    void drawHeightMap() {
        foreach (MapQuad quad; this.heightMap) {
            quad.draw();
        }
    }

    void drawTerrain() {
        DrawModel(this.terrainModel, Vector3(0,0,0), 1, Colors.WHITE);
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

    bool didTick() {
        return this.ticked;
    }

    /// Remember: this needs an external handler for fixed time stamps!
    void update() {
        /// Simulate higher FPS precision
        this.timeAccumalator += game.timeKeeper.getDelta();

        int updates = 0;

        this.ticked = false;


        // Entity[] awakeEntities = entitiesArray.filter!(o => o.awake).array();

        /// Literally all IO with the physics engine NEEDS to happen here!
        if (this.timeAccumalator >= lockedTick) {

            Entity[] entitiesArray = this.entities.array();
            
            this.ticked = true;

            // writeln("UPDATE! ", this.timeAccumalator);
            
            foreach (thisEntity; entitiesArray[0..entitiesArray.length]) {

                thisEntity.velocity.y -= this.gravity;

                // Grab a slice of this sweet data wooo
                float[3] position3 = Vector3ToFloatV(thisEntity.position).v[0..3];
                float[3] velocity3 = Vector3ToFloatV(thisEntity.velocity).v[0..3];
                float[3] size = Vector3ToFloatV(thisEntity.size).v[0..3];

                
                foreach (i; 0..3) {

                    position3[i] += velocity3[i];

                    thisEntity.setPositionIndex(i, position3[i]);

                    foreach (otherEntity; entitiesArray.filter!(o => o != thisEntity && Vector3DistanceSqr(o.position, thisEntity.position) < 3)) {

                        BoundingBox thisBox = boundingBoxFromArray(position3, size);

                        BoundingBox otherBox = otherEntity.getBoundingBox();

                        if (CheckCollisionBoxes(thisBox, otherBox)) {

                            float diff = (size[i] + otherEntity.getSizeIndex(i) + 0.001) * signum(-velocity3[i]);
                            position3[i] = otherEntity.getPositionIndex(i) + diff;
                            velocity3[i] = 0;///otherEntity.getVelocityIndex(i);
                            
                        }
                            
                    }
                }

                thisEntity.position = Vector3(position3[0], position3[1], position3[2]);
                thisEntity.velocity = Vector3(velocity3[0], velocity3[1], velocity3[2]);


                float mapCollision = this.collidePointToMap(thisEntity.getCollisionBoxPosition());

                if (!isNaN(mapCollision)) {
                    thisEntity.velocity.y = 0;
                    thisEntity.position.y = mapCollision + thisEntity.size.y;
                }

                /*
                if (!thisEntity.isPlayer && thisEntity.velocity.y == 0) {
                    thisEntity.sleep();
                }
                */
            }

            updates++;
            this.timeAccumalator -= lockedTick;
        }

        /// writeln("Physics updates in this frame: ", updates);

    }


    void render() {
        foreach (Entity thisEntity; this.entities) {
            thisEntity.drawCollisionBox();
        }

        this.drawTerrain();
    }

}

/// Entities are 3D boxes that can rotate their models. This is a base class that should be extended.
public class Entity {
    
    private Vector3 position;
    private Vector3 size;
    private Vector3 velocity;
    private UUID uuid;
    private bool isPlayer;
    private bool awake = true;
    
    /// Rotation is only used for rotating the model of an entity
    private float rotation;

    this(Vector3 position, Vector3 size, Vector3 velocity, bool isPlayer) {
        this.uuid = randomUUID();
        /// Moving these values off the stack
        this.position = *new Vector3(position.x, position.y, position.z);
        this.size     = *new Vector3(size.x / 2, size.y / 2, size.z / 2);
        this.velocity = *new Vector3(velocity.x, velocity.y, velocity.z);
        this.isPlayer = isPlayer;
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

    void sleep() {
        this.awake = false;
    }

    Vector3 getPosition() {
        return this.position;
    }

    Vector3 getCollisionBoxPosition() {
        Vector3 updatedPosition = this.position;
        updatedPosition.y -= this.size.y;
        return updatedPosition;
    }

    void setPosition(Vector3 newPosition) {
        this.position = newPosition;
    }

    void setPositionIndex(int index, float value) {
        final switch(index) {
            case 0: this.position.x = value; break;
            case 1: this.position.y = value; break;
            case 2: this.position.z = value; break;
        }
    }

    void setCollisionBoxPosition(Vector3 newPosition) {
        newPosition.y += this.size.y;
        this.position = newPosition;
    }

    Vector3 getVelocity() {
        return this.velocity;
    }

    float getVelocityIndex(int index) {
        final switch(index) {
            case 0: return this.velocity.x;
            case 1: return this.velocity.y;
            case 2: return this.velocity.z;
        }
    }

    void setVelocity(Vector3 newVelocity) {
        this.velocity = newVelocity;
    }

    float getSizeIndex(int index) {
        return Vector3ToFloatV(this.size).v[index];
    }

    float getPositionIndex(int index) {
        return Vector3ToFloatV(this.position).v[index];
    }

    void addVelocity(Vector3 addition) {
        this.velocity = Vector3Add(this.velocity, addition);
    }

    UUID getUUID() {
        return this.uuid;
    }

    void drawCollisionBox() {
        if (isPlayer) {
            DrawBoundingBox(this.getBoundingBox(), Colors.BLACK);
        } else {
            /// DrawCube(this.position, this.size.x * 2, this.size.y * 2, this.size.z * 2, Colors.YELLOW);
            DrawBoundingBox(this.getBoundingBox(), Colors.RED);
        }
    }
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

pragma(inline)
@safe pure nothrow Select!(isFloatingPoint!T || isIntegral!T, T, float)
signum(T)(in T x) {
    return (T(0) < x) - (x < T(0));
}

pragma(inline)
@safe pure nothrow @nogc
BoundingBox boundingBoxFromArray(float[3] position, float[3] size) {
    return BoundingBox(
        Vector3(
            position[0] - size[0],
            position[1] - size[1],
            position[2] - size[2]
        ),
        Vector3(
            position[0] + size[0],
            position[1] + size[1],
            position[2] + size[2]
        )
    );
}

