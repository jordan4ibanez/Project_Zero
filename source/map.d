module map;

import raylib;
import std.stdio;

public class Map {

    double timeAccumalator = 0.0;

    /// 300 FPS physics simulation
    immutable double fpsPrecision = 300;
    immutable double lockedTick = 1.0 / this.fpsPrecision;

    Texture2D[string] textureCache;
    MapObject[string] cache;

    Rectangle boundingBox;
    Texture2D groundTexture;
    Rectangle groundTextureSource;

    Structure[] buildings;

    this(int mapWidth, int mapHeight, string groundTextureLocation) {
        this.boundingBox = *new Rectangle( -mapWidth / 2, -mapHeight / 2, mapWidth, mapHeight);
        this.groundTexture = LoadTexture(groundTextureLocation.ptr);
        this.groundTextureSource = *new Rectangle(0,0, this.groundTexture.width, this.groundTexture.height);
    }

    void insertNewStructure(Structure newStruct) {
        this.buildings ~= newStruct;
    }

    void draw(Vector2 offset) {
        this.drawGround(offset);
        this.drawBuildings(offset);
    }

    private void drawBuildings(Vector2 offset) {
        foreach (Structure building; this.buildings) {
            building.draw(true);
        }
    }

    private void drawGround(Vector2 offset) {
        DrawTextureTiled(
            this.groundTexture,
            this.groundTextureSource,
            this.boundingBox,
            offset,
            0,
            1, 
            Colors.WHITE
        );
    }

    // "Physics" & Collision Detection
    double getTimeAccumulator() {
        return this.timeAccumalator;
    }

    void setTimeAccumulator(double newValue) {
        this.timeAccumalator = newValue;
    }

    double getLockedTick() {
        return this.lockedTick;
    }

    void update() {
        
    } 
}

public class MapObject {
    Rectangle boundingBox;    
    Texture2D floorTexture;

    void draw(bool xray) {

    }

}

/**
 * Even though these are called decorations, they will have functionality in the future
 */
public class Decoration : MapObject {
    Rectangle boundingBox;
    Texture2D floorTexture;
    bool collide;
    
    /**
     * If you're putting this decoration inside a structure, it's relative to the structure!
     */
    this(int posX, int posY, string decorationTextureLocation, bool collides) {
        this.floorTexture = LoadTexture(decorationTextureLocation.ptr);
        this.boundingBox = *new Rectangle(posX,posY,this.floorTexture.width, this.floorTexture.height);
    }

    this(Decoration cloningDecoration) {
        this.collide = cloningDecoration.collide;
        this.boundingBox = *new Rectangle(cloningDecoration.boundingBox.x, cloningDecoration.boundingBox.y, cloningDecoration.boundingBox.width, cloningDecoration.boundingBox.height);
        this.floorTexture = cloningDecoration.floorTexture;
    }

    override
    void draw(bool xray) {
        DrawTexture(this.floorTexture, cast(int)this.boundingBox.x, cast(int)this.boundingBox.y, Colors.RAYWHITE);
    }
}


public class Structure : MapObject {

    Rectangle boundingBox;
    Wall[] walls;
    Decoration[] decorations;

    Texture2D floorTexture;
    Rectangle floorTextureSource;

    Texture2D roofTexture;
    Rectangle roofTextureSource;

    immutable int doorSize = 100;
    immutable int halfDoorSize = doorSize / 2;

    this(
        int posX,
        int posY,
        int width,
        int height,
        Rectangle[] newWalls,
        Decoration[] newDecorations,
        string floorTextureLocation,
        string wallTextureLocation,
        string roofTextureLocation
    ) {
                
        this.floorTexture = LoadTexture(floorTextureLocation.ptr);
        this.floorTextureSource = *new Rectangle(0,0, this.floorTexture.width, this.floorTexture.height);

        this.roofTexture = LoadTexture(roofTextureLocation.ptr);
        this.roofTextureSource = *new Rectangle(0,0, this.roofTexture.width, this.roofTexture.height);

        this.boundingBox = Rectangle(posX, posY, width, height);

        foreach (Rectangle wall; newWalls) {
            this.walls ~= new Wall(posX, posY, wallTextureLocation, wall);
        }
        foreach (Decoration decoration; newDecorations) {
            Decoration clone = new Decoration(decoration);
            clone.boundingBox.x += posX;
            clone.boundingBox.y += posY;
            this.decorations ~= clone;
        }
    }

    override
    void draw(bool xray) {

        if (xray) {
            DrawTextureTiled(
                this.floorTexture,
                this.floorTextureSource,
                this.boundingBox,
                Vector2(0,0),
                0,
                1, 
                Colors.WHITE
            );
            
            foreach (Wall wall; this.walls) {
                DrawTextureTiled(
                    wall.texture,
                    wall.textureSource,
                    wall.boundingBox,
                    /**
                    * Subtract because this is a double inversion!
                    * Origin = how far to shift to center to 0,0
                    * So top left is shifted negatively. Therefore we must further subtract to get a positive position addition!
                    * This makes it easier to understand while making maps.
                    */
                    Vector2(0,0),
                    0,
                    1,
                    Colors.WHITE
                );
            }

            foreach (Decoration decoration; this.decorations) {
                DrawTexture(
                    decoration.floorTexture,
                    cast(int)decoration.boundingBox.x,
                    cast(int)decoration.boundingBox.y,
                    Colors.WHITE
                );
            }
        } 
        
        else {
            DrawTextureTiled(
                this.roofTexture,
                this.roofTextureSource,
                this.boundingBox,
                Vector2(0,0),
                0,
                1, 
                Colors.WHITE
            );
        }
    }
}

public class Wall {
    Texture2D texture;
    Rectangle boundingBox;
    Rectangle textureSource;
    this(int posX, int posY, string textureLocation, Rectangle rectangle) {
        this.texture = LoadTexture(textureLocation.ptr);
        this.boundingBox = *new Rectangle(posX + rectangle.x, posY + rectangle.y, rectangle.width, rectangle.height);
        this.textureSource = *new Rectangle(0,0, texture.width, texture.height);
    }
}