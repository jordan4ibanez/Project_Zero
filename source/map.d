module map;

import raylib;

public class Map {

    MapObject[string] cache;
    Rectangle boundingBox;
    Texture2D groundTexture;
    Rectangle groundTextureSource;

    this(int mapWidth, int mapHeight, string groundTextureLocation) {
        this.boundingBox = *new Rectangle( -mapWidth / 2, -mapHeight / 2, mapWidth, mapHeight);
        this.groundTexture = LoadTexture(groundTextureLocation.ptr);
        this.groundTextureSource = *new Rectangle(0,0, this.groundTexture.width, this.groundTexture.height);
    }

    void drawGround(Vector2 offset) {
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
}

public class MapObject {
    Rectangle boundingBox;
    Vector2 origin;
    Texture2D floorTexture;

    void draw(int posX, int posY, bool xray) {

    }

}


public class Structure : MapObject {

    Rectangle boundingBox;
    Wall[] walls;
    Vector2 origin;

    Texture2D floorTexture;
    Rectangle floorTextureSource;

    Texture2D roofTexture;
    Rectangle roofTextureSource;

    immutable int doorSize = 100;
    immutable int halfDoorSize = doorSize / 2;

    this(
        int width,
        int height,
        Rectangle[] newWalls,
        string floorTextureLocation,
        string wallTextureLocation,
        string roofTextureLocation
    ) {
                
        this.floorTexture = LoadTexture(floorTextureLocation.ptr);
        this.floorTextureSource = *new Rectangle(0,0, this.floorTexture.width, this.floorTexture.height);

        this.roofTexture = LoadTexture(roofTextureLocation.ptr);
        this.roofTextureSource = *new Rectangle(0,0, this.roofTexture.width, this.roofTexture.height);


        this.origin = Vector2(width / 2, height / 2);
        this.boundingBox = Rectangle(0, 0, width, height);

        foreach (Rectangle wall; newWalls) {
            walls ~= new Wall(wallTextureLocation, wall);
        }
    }

    override
    void draw(int posX, int posY, bool xray) {

        if (xray) {
            DrawTextureTiled(
                this.floorTexture,
                this.floorTextureSource,
                this.boundingBox,
                Vector2Subtract(
                    this.origin,
                    Vector2(posX, posY)
                ),
                0,
                1, 
                Colors.WHITE
            );
            foreach (Wall wall; this.walls) {
                DrawTextureTiled(
                    wall.texture,
                    wall.textureSource,
                    wall.rectangle,
                    /**
                    * Subtract because this is a double inversion!
                    * Origin = how far to shift to center to 0,0
                    * So top left is shifted negatively. Therefore we must further subtract to get a positive position addition!
                    * This makes it easier to understand while making maps.
                    */
                    Vector2Subtract(
                        this.origin,
                        Vector2(posX, posY)
                    ),
                    0,
                    1,
                    Colors.WHITE
                );
            }
        } else {
            DrawTextureTiled(
                this.roofTexture,
                this.roofTextureSource,
                this.boundingBox,
                Vector2Subtract(
                    this.origin,
                    Vector2(posX, posY)
                ),
                0,
                1, 
                Colors.WHITE
            );
        }
    }
}

public class Wall {
    Texture2D texture;
    Rectangle rectangle;
    Rectangle textureSource;
    this(string textureLocation, Rectangle rectangle) {
        this.texture = LoadTexture(textureLocation.ptr);
        this.rectangle = *new Rectangle(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        this.textureSource = *new Rectangle(0,0, texture.width, texture.height);
    }
}