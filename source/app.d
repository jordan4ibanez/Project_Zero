import std.stdio;

import raylib;
import lua;
import camera;
import mouse;
import keyboard;
import physics;
import sound_engine;
import delta;
import window;
import player;
import map;

void main()
{

    validateRaylibBinding();

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    Window window = new Window(1280,720);


    SetTargetFPS(144);

    DeltaCalculator deltaCalculator = new DeltaCalculator();

    GameCamera camera = new GameCamera(window);

    Mouse mouse = new Mouse();
    mouse.grab(camera);

    Keyboard keyboard = new Keyboard();

    SoundEngine soundEngine = new SoundEngine();

    Font font = LoadFont("textures/roboto_slab.ttf");
    GenTextureMipmaps(&font.texture);
    SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_TRILINEAR);

    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    bool wasToggle = false;

    Player player = new Player(Vector2(0,0));

    float rotation = 0;

    int thickness = 30;
    int doorPosition = 100;
    int halfDoorSize = 50;
    int width = 500;
    int height = 500;

    Rectangle[] walls = [        
        // Left wall (upper)
        Rectangle(0, 0, thickness, doorPosition - halfDoorSize),
        // Left wall (lower)
        Rectangle(0, doorPosition + halfDoorSize, thickness, height - halfDoorSize - doorPosition),
        // Right wall
        Rectangle(width - thickness, 0, thickness, height),
        // Top wall
        Rectangle(0, 0, width, thickness),
        // Bottom wall
        Rectangle(0, height - thickness, width, thickness),
    ];

    // Wall wall = new Wall("textures/bricks.png", 0, 0, 50, 200);
    Structure house = new Structure(width, height, walls, "textures/wood_floor.png", "textures/bricks.png", "textures/tile_roof.png");

    Map map = new Map(2000,2000, "textures/grass.png");

    while(!WindowShouldClose()) {


        window.update(camera);

        mouse.update();

        keyboard.update();


        bool togglingFullScreen = keyboard.getToggleFullScreen();
        if (togglingFullScreen && !wasToggle) {
            window.toggleFullScreen(camera);
        }
        wasToggle = togglingFullScreen;

        deltaCalculator.calculateDelta();

        double delta = deltaCalculator.getDelta();

        // rotation += delta * 100;

        if (rotation > 360) {
            rotation -= 360;
        }

        // writeln(rotation);


        camera.setRotation(rotation);


        /// End internal calculations, begin draw

        camera.updateTarget(player.getPosition());


        BeginDrawing();
        {

            camera.clear(Colors.WHITE);
            
            BeginMode2D(camera.get());

            map.drawGround(Vector2(0,0));

            house.draw(0, 0, true);

            DrawCircle(cast(int)player.getX(), cast(int)player.getY(), player.getSize(), Colors.RED);

            EndMode2D();



            DrawTextEx(font, "Zombie Game 0.0.0", Vector2(10,10), 30, 1, Colors.BLACK);
            DrawTextEx(font, "Zombie Game 0.0.0", Vector2(7,7), 30, 1, Colors.GREEN);

        }
        EndDrawing();
    }
}
