import std.stdio;

import raylib;
import lua;
import camera;
import mouse;
import keyboard;
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

    Player player = new Player(Vector2(0,0), "singleplayer");

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
        Rectangle(0, height - thickness, width, thickness)
    ];

    Decoration[] decorations = [
        new Decoration(380,330, "textures/chair.png", false)
    ];

    Map map = new Map(2000,2000, "textures/grass.png");    

    // Wall wall = new Wall("textures/bricks.png", 0, 0, 50, 200);
    map.insertNewStructure(new Structure(-200, -200, width, height, walls, decorations, "textures/wood_floor.png", "textures/bricks.png", "textures/tile_roof.png"));



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

        camera.intakeMouseInput(mouse);

        /// Simulate higher FPS precision
        double timeAccumalator = map.getTimeAccumulator() + delta;
        immutable double lockedTick = map.getLockedTick();

        /// Literally all IO with the physics engine NEEDS to happen here!
        while(timeAccumalator >= lockedTick) {

            player.move(camera, keyboard);

            map.updatePhysics(player);

            timeAccumalator -= lockedTick;
        }

        map.setTimeAccumulator(timeAccumalator);

        player.processFootsteps(soundEngine);
        

        // writeln(rotation);
        // camera.setRotation(rotation);


        /// End internal calculations, begin draw

        camera.updateTarget(player.getCenter());


        BeginDrawing();
        {

            camera.clear(Colors.WHITE);
            
            { // Begin 2d
                BeginMode2D(camera.get());

                map.draw(Vector2(0,0));

                Rectangle aabb = player.getBoundingBox();
                DrawRectangle(cast(int)aabb.x, cast(int)aabb.y, cast(int)aabb.width, cast(int)aabb.height, Colors.RED);

                EndMode2D();
            }

            DrawTextEx(font, "Zombie Game 0.0.0", Vector2(10,10), 30, 1, Colors.BLACK);
            DrawTextEx(font, "Zombie Game 0.0.0", Vector2(7,7), 30, 1, Colors.GREEN);

        }
        EndDrawing();
    }
}
