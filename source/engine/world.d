module engine.world;

import std.stdio;
import raylib;
import std.uuid;
import std.math.algebraic: sqrt, abs;
import std.math.rounding: floor;
import std.math.traits: isNaN;
import std.traits: Select, isFloatingPoint, isIntegral;
import std.algorithm.iteration: filter, map;
import std.array;
import std.algorithm.searching: canFind;
import std.conv: to;
import std.random;

import game.game;

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

    /// This also sets the min entity size!
    private immutable float speedLimit = 0.5;

    /// This also sets the max entity size!
    private immutable float quadrantSize = 30;

    private immutable float minPosition = 0;
    private float maxPosition; // unknown until heightmap uploaded

    this(Game game) {
        this.game = game;

        Texture newGroundTexture = LoadTexture("textures/grass.png");
        GenTextureMipmaps(&newGroundTexture);
        SetTextureFilter(newGroundTexture, TextureFilter.TEXTURE_FILTER_TRILINEAR);
        this.groundTexture = newGroundTexture;
    }
    
    /// Add an entity into the entity associative array
    void addEntity(Entity newEntity) {
        if (newEntity.size.x >= this.quadrantSize / 2 || newEntity.size.y >= this.quadrantSize / 2 || newEntity.size.z >= this.quadrantSize / 2) {
            throw new Exception ("Entity size is limited to less than " ~ to!string(this.quadrantSize / 2) ~ " units x,y,z!!");
        }

        if (newEntity.size.x <= this.speedLimit / 2.0 || newEntity.size.y <= this.speedLimit / 2.0 || newEntity.size.z <= this.speedLimit / 2.0) {
            writeln(newEntity.size);
            throw new Exception ("Entity must be bigger than " ~ to!string(this.speedLimit / 2.0) ~ " units x,y,z!");
        }

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

        this.maxPosition = (this.heightMapSize - 1) * quadScale;

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

    private struct Vector3I {
        int x = 0;
        int y = 0;
        int z = 0;
    }
    private struct Quadrant {
        Entity[] entitiesWithin;
    }

    private Quadrant[Vector3I] quadrants;

    private void quadrantsInsert(Vector3I index, Entity entity) {
        bool quickPlop = false;
        if (index !in quadrants) {
            quickPlop = true;
            quadrants[index] = Quadrant();
        }
        // avoid duplicates
        if (quickPlop || !canFind(quadrants[index].entitiesWithin, entity)) {
            quadrants[index].entitiesWithin ~= entity;
        }
    }

    private BoundingBox quadrantToBoundingBox(Vector3I input) {
        Vector3 basePosition = Vector3(
            input.x * this.quadrantSize,
            input.y * this.quadrantSize,
            input.z * this.quadrantSize
        );
        return BoundingBox(
            Vector3(
                basePosition.x,
                basePosition.y,
                basePosition.z
            ),
            Vector3(
                basePosition.x + this.quadrantSize,
                basePosition.y + this.quadrantSize,
                basePosition.z + this.quadrantSize
            )
        );
    }

    private static immutable Vector3I[] quadrantNeighbors = [

        Vector3I( 0, 1, 0),
        Vector3I( 0,-1, 0),
        /// 0,0,0 is current quadrant, no check
        Vector3I( 1, 0, 0),
        Vector3I(-1, 0, 0),
        Vector3I( 1, 1, 0),
        Vector3I(-1, 1, 0),
        Vector3I( 1,-1, 0),
        Vector3I(-1,-1, 0),
        /// This is where x and z loop
        Vector3I( 0, 0, 1),
        Vector3I( 1, 0, 1),
        Vector3I(-1, 0, 1),
        Vector3I( 1, 1, 1),
        Vector3I(-1, 1, 1),
        Vector3I( 1,-1, 1),
        Vector3I(-1,-1, 1),
        /// This is where x and z loop
        Vector3I( 0, 0,-1),
        Vector3I( 1, 0,-1),
        Vector3I(-1, 0,-1),
        Vector3I( 1, 1,-1),
        Vector3I(-1, 1,-1),
        Vector3I( 1,-1,-1),
        Vector3I(-1,-1,-1),
    ];

    /// Remember: this needs an external handler for fixed time stamps!
    void update() {

        /// Simulate higher FPS precision
        this.timeAccumalator += game.timeKeeper.getDelta();

        int updates = 0;

        this.ticked = false;

        this.quadrants.clear();

        /* This is a test remove this*/
        UUID[] deletionQueue;
        /*End part of test*/

        // Entity[] awakeEntities = entitiesArray.filter!(o => o.awake).array();

        /// Literally all IO with the physics engine NEEDS to happen here!
        if (this.timeAccumalator >= lockedTick) {

            this.ticked = true;

            // writeln("UPDATE! ", this.timeAccumalator);

           
            foreach (thisEntity; this.entities.values) {

                // enforce speed limit
                if (Vector3Length(thisEntity.velocity) > this.speedLimit) {
                    // writeln("Entity ", thisEntity.uuid, " is breaking the speed limit!");
                    thisEntity.velocity = Vector3Multiply(Vector3Normalize(thisEntity.velocity), Vector3(this.speedLimit,this.speedLimit,this.speedLimit));
                }

                // set up each entity
                thisEntity.wasOnGround = false;
                thisEntity.velocity.y -= this.gravity;

                thisEntity.applied = false;
                thisEntity.oldPosition = thisEntity.position;

                BoundingBox futureBoundingBox = thisEntity.getBoundingBoxWithOverProvision();

                // Quadrant of current position
                Vector3I currentQuadrant = Vector3I(
                    cast(int)floor(
                        thisEntity.position.x / this.quadrantSize
                    ),
                    cast(int)floor(
                        thisEntity.position.y / this.quadrantSize
                    ),
                    cast(int)floor(
                        thisEntity.position.z / this.quadrantSize
                    )
                );

                quadrantsInsert(currentQuadrant, thisEntity);

                /// Generate neighbors
                foreach (quadPos; quadrantNeighbors) {
                    Vector3I neighbor = Vector3I(
                        currentQuadrant.x + quadPos.x,
                        currentQuadrant.y + quadPos.y,
                        currentQuadrant.z + quadPos.z
                    );

                    BoundingBox neighborBox = quadrantToBoundingBox(neighbor);

                    // plop em into the quadrant
                    if (CheckCollisionBoxes(futureBoundingBox, neighborBox)) {
                        quadrantsInsert(neighbor, thisEntity);
                    }
                }
            }

            
            foreach (thisQuadrant; quadrants.byValue) {

                foreach (thisEntity; thisQuadrant.entitiesWithin) {

                    BoundingBox oldBox = thisEntity.getOldBoundingBox();

                    if (!thisEntity.applied) {
                        thisEntity.position = Vector3Add(thisEntity.position, thisEntity.velocity);
                        thisEntity.applied = true;
                    }
                    /**
                     * This is magnetic 3D detection 2D resolution cylindrical detection.
                     * This allows for entities to bunch up and shove other entities out of the way.
                     * This only affects the entity's velocity. This avoids some extremely strange behavior.
                     */

                    Vector2 thisCircle = Vector2(thisEntity.position.x, thisEntity.position.z);
                    float thisRadius   = thisEntity.size.x;
                    float thisTop      = thisEntity.position.y + thisEntity.size.y;
                    float thisBottom   = thisEntity.position.y - thisEntity.size.y;

                    foreach (otherEntity; thisQuadrant.entitiesWithin.filter!(o => o != thisEntity)) {

                        Vector2 otherCircle = Vector2(otherEntity.position.x, otherEntity.position.z);
                        float otherRadius   = otherEntity.size.x;

                        /// First we check 2D
                        if (CheckCollisionCircles(thisCircle, thisRadius, otherCircle, otherRadius)) {

                            /// Next we check 1D
                            float otherTop    = otherEntity.position.y + otherEntity.size.y;
                            float otherBottom = otherEntity.position.y - otherEntity.size.y;

                            bool within(float input) {
                                return input <= otherTop && input >= otherBottom;
                            }

                            bool biggerWithin() {
                                return thisTop > otherTop && thisBottom < otherBottom;
                            }

                            bool smallerWithin() {
                                return thisTop < otherTop && thisBottom > otherBottom;
                            }

                            /// 2 cylinders have collided
                            if (within(thisTop) || within(thisBottom) || biggerWithin() || smallerWithin() ) {
                                float maxVelocity = thisRadius + otherRadius;
                                float distance = Vector2Distance(thisCircle, otherCircle);
                                float forceApplication = maxVelocity - distance;
                                Vector2 forceDirection = Vector2Normalize(Vector2Subtract(thisCircle, otherCircle));

                                // now we apply the velocity
                                forceDirection.x *= forceApplication;
                                forceDirection.y *= forceApplication;

                                // Allows entities to slightly phase through eachother
                                thisEntity.velocity.x += forceDirection.x / 100.0;
                                thisEntity.velocity.z += forceDirection.y / 100.0;

                            }
                        }
                    }


                    /**
                     * This is rigid AABB collision detection.
                     * Only useful for colliding entities to structures.
                     * Can cause extremely weird behavior for 2 moving objects.
                     */
                    /*
                    BoundingBox thisBox = thisEntity.getBoundingBox();

                    foreach (otherEntity; thisQuadrant.entitiesWithin.filter!(o => o != thisEntity)) {

                        BoundingBox otherBox = otherEntity.getBoundingBox();

                        if(CheckCollisionBoxes(thisBox, otherBox)) {

                            // These are 1D collision detections
                            bool bottomWasNotIn = oldBox.min.y > otherBox.max.y;
                            bool bottomIsNowIn = thisBox.min.y <= otherBox.max.y && thisBox.min.y >= otherBox.min.y;
                            bool topWasNotIn = oldBox.max.y < otherBox.min.y;
                            bool topIsNowIn = thisBox.max.y <= otherBox.max.y && thisBox.max.y >= otherBox.min.y;

                            bool leftWasNotIn = oldBox.min.x > otherBox.max.x;
                            bool leftIsNowIn = thisBox.min.x <= otherBox.max.x && thisBox.min.x >= otherBox.min.x;
                            bool rightWasNotIn = oldBox.max.x < otherBox.min.x;
                            bool rightIsNowIn = thisBox.max.x <= otherBox.max.x && thisBox.max.x >= otherBox.min.x;

                            bool backWasNotIn = oldBox.min.z > otherBox.max.z;
                            bool backIsNowIn = thisBox.min.z <= otherBox.max.z && thisBox.min.z >= otherBox.min.z;
                            bool frontWasNotIn = oldBox.max.z < otherBox.min.z;
                            bool frontIsNowIn = thisBox.max.z <= otherBox.max.z && thisBox.max.z >= otherBox.min.z;



                            /// y check first
                            // This allows entities to clip, but this isn't a voxel game so we won't worry about that
                            if (bottomWasNotIn && bottomIsNowIn) {
                                thisEntity.position.y = otherBox.max.y + thisEntity.size.y + 0.001;
                                thisEntity.wasOnGround = true;

                                thisEntity.velocity.y = 0;
                            } else if (topWasNotIn && topIsNowIn) {
                                thisEntity.position.y = otherBox.min.y - thisEntity.size.y - 0.001;
                                thisEntity.velocity.y = 0;
                            } 
                            // then x
                            else if (leftWasNotIn && leftIsNowIn) {
                                thisEntity.position.x = otherBox.max.x +thisEntity.size.x + 0.001;
                                thisEntity.velocity.x = 0;
                            } else if (rightWasNotIn && rightIsNowIn) {
                                thisEntity.position.x = otherBox.min.x - thisEntity.size.x - 0.001;
                                thisEntity.velocity.x = 0;
                            }
                            
                            // finally z
                            else if (backWasNotIn && backIsNowIn) {
                                thisEntity.position.z = otherBox.max.z +thisEntity.size.z + 0.001;
                                thisEntity.velocity.z = 0;
                            } else if (frontWasNotIn && frontIsNowIn) {
                                thisEntity.position.z = otherBox.min.z - thisEntity.size.z - 0.001;
                                thisEntity.velocity.z = 0;
                            }   
                        }
                    }
                    */

                    
                    // Finally, keep those entities within the simulation!
                    // This can cause some extremely weird behavior on the border.
                    // but it's better than the game crashing!

                    // Needs a fresh box, old box is now out of date
                    BoundingBox thisBox = thisEntity.getBoundingBox();
                    if (thisBox.max.x > this.maxPosition) {
                        thisEntity.position.x = this.maxPosition - thisEntity.size.x;
                        thisEntity.velocity.x = 0;
                    } else if (thisBox.min.x < this.minPosition) {
                        thisEntity.position.x = this.minPosition + thisEntity.size.x;
                        thisEntity.velocity.x = 0;
                    }
                    if (thisBox.max.z > this.maxPosition) {
                        thisEntity.position.z = this.maxPosition - thisEntity.size.z;
                        thisEntity.velocity.z = 0;
                    } else if (thisBox.min.z < this.minPosition) {
                        thisEntity.position.z = this.minPosition + thisEntity.size.z;
                        thisEntity.velocity.z = 0;
                    }

                    float mapCollision = this.collidePointToMap(thisEntity.getCollisionBoxPosition());

                    if (!isNaN(mapCollision)) {
                        thisEntity.wasOnGround = true;
                        thisEntity.velocity.y = 0;
                        thisEntity.position.y = mapCollision + thisEntity.size.y;
                        /* This is a test, delete this*/
                        if (!thisEntity.isPlayer) {
                            //thisEntity.deleteMe = true;
                            // deletionQueue ~= thisEntity.uuid;
                        }
                        /* end this part of test*/
                    }

                }
            }

            updates++;
            this.timeAccumalator -= lockedTick;
        }

        /* this is a test, remove this
        foreach (UUID key; deletionQueue) {
            this.entities.remove(key);
        }
        /* end this part of test*/

        /// writeln("Physics updates in this frame: ", updates);

    }


    void render() {
        Vector3 cameraPos = game.camera3d.getPosition();
        foreach (Entity thisEntity; this.entities) {
            thisEntity.drawCollisionBox(cameraPos);
        }

        this.drawTerrain();
    }

}

/// Entities are 3D boxes that can rotate their models. This is a base class that should be extended.
public class Entity {
    
    private Vector3 position;
    private Vector3 oldPosition;
    private Vector3 size;
    private Vector3 velocity;
    private UUID uuid;
    private bool isPlayer;
    private bool awake = true;
    bool wasOnGround = false;
    private bool applied = false;
    private immutable float overProvision = 2.0;
    private immutable Color color;
    bool deleteMe = false;
    
    
    /// Rotation is only used for rotating the model of an entity
    private float rotation;

    this(Vector3 position, Vector2 size, Vector3 velocity, bool isPlayer) {
        this.uuid = randomUUID();
        /// Moving these values off the stack
        this.position = Vector3(position.x, position.y, position.z);
        this.oldPosition = position;
        this.size     = Vector3(size.x / 2, size.y / 2, size.x / 2);
        this.velocity = Vector3(velocity.x, velocity.y, velocity.z);
        this.isPlayer = isPlayer;

        Random randy = Random(unpredictableSeed());
        this.color = Color(
            cast(ubyte)uniform(0,255,randy),
            cast(ubyte)uniform(0,255,randy),
            cast(ubyte)uniform(0,255,randy),
            255
        );
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

    final
    BoundingBox getOldBoundingBox() {
        return BoundingBox(
            Vector3(
                this.oldPosition.x - this.size.x,
                this.oldPosition.y - this.size.y,
                this.oldPosition.z - this.size.z
            ),
            Vector3(
                this.oldPosition.x + this.size.x,
                this.oldPosition.y + this.size.y,
                this.oldPosition.z + this.size.z
            )
        );
    }

    /// Allows the collision detection to look into the future
    final
    BoundingBox getBoundingBoxWithOverProvision() {
        return BoundingBox(
            Vector3(
                this.position.x - this.size.x - this.overProvision + this.velocity.x,
                this.position.y - this.size.y - this.overProvision + this.velocity.y,
                this.position.z - this.size.z - this.overProvision + this.velocity.z
            ),
            Vector3(
                this.position.x + this.size.x + this.overProvision + this.velocity.x,
                this.position.y + this.size.y + this.overProvision + this.velocity.y,
                this.position.z + this.size.z + this.overProvision + this.velocity.z
            )
        );
    }

    final
    void sleep() {
        this.awake = false;
    }

    final
    Vector3 getPosition() {
        return this.position;
    }

    final
    Vector3 getCollisionBoxPosition() {
        Vector3 updatedPosition = this.position;
        updatedPosition.y -= this.size.y;
        return updatedPosition;
    }

    final
    void setPosition(Vector3 newPosition) {
        this.position = newPosition;
    }

    final
    void setPositionIndex(int index, float value) {
        final switch(index) {
            case 0: this.position.x = value; break;
            case 1: this.position.y = value; break;
            case 2: this.position.z = value; break;
        }
    }

    final
    void setCollisionBoxPosition(Vector3 newPosition) {
        newPosition.y += this.size.y;
        this.position = newPosition;
    }

    final
    Vector3 getVelocity() {
        return this.velocity;
    }

    final
    float getVelocityIndex(int index) {
        final switch(index) {
            case 0: return this.velocity.x;
            case 1: return this.velocity.y;
            case 2: return this.velocity.z;
        }
    }

    final
    void setVelocity(Vector3 newVelocity) {
        this.velocity = newVelocity;
    }

    final
    float getSizeIndex(int index) {
        return Vector3ToFloatV(this.size).v[index];
    }

    final
    float getPositionIndex(int index) {
        return Vector3ToFloatV(this.position).v[index];
    }

    final
    void addVelocity(Vector3 addition) {
        this.velocity = Vector3Add(this.velocity, addition);
    }

    final
    UUID getUUID() {
        return this.uuid;
    }
    final 
    bool wasOnTheGround() {
        return this.wasOnGround;
    }

    final
    void drawCollisionBox(Vector3 cameraPos) {
        if (isPlayer) {
            DrawBoundingBox(this.getBoundingBox(), Colors.BLACK);
            /// This is the collision with other entities (magnetic)
            Vector3 moddedPosition = this.position;
            moddedPosition.y -= this.size.y;
            DrawCylinderWires(moddedPosition, this.size.x, this.size.x, this.size.y * 2, 50, this.color);
        } else {
            /// DrawCube(this.position, this.size.x * 2, this.size.y * 2, this.size.z * 2, Colors.YELLOW);
            
            if (Vector3Distance(this.position, cameraPos) < 150) {
                DrawBoundingBox(this.getBoundingBox(), this.color);
                // DrawCube(this.position, this.size.x * 2, this.size.y * 2, this.size.z * 2, this.color);
                /// This is the collision with other entities (magnetic)
                Vector3 moddedPosition = this.position;
                moddedPosition.y -= this.size.y;
                DrawCylinderWires(moddedPosition, this.size.x, this.size.x, this.size.y * 2, 50, this.color);
            }
        }
    }
}



/**
 * The map's base is a heightmap based on quads, these are fixed size of 1x1.
 * Therefor, we only need the Y positions of the quads.
 */
public immutable class MapQuad {
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
        float[] newYPoints = new float[4];
        // y: negative x, negative z
        newYPoints[0] = yPosNegativeXNegativeZ;
        // y: negative x, positive z
        newYPoints[1] = yPosNegativeXPositiveZ;
        // y: positive x, positive z
        newYPoints[2] = yPosPositiveXPositiveZ;
        // y: positive x, negative z
        newYPoints[3] = yPosPositiveXNegativeZ;

        this.yPoints = cast(immutable)newYPoints;

        this.position = Vector2(position.x, position.y);
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

