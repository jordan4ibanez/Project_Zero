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
import physics;

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

    GameCamera camera = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera);

    Keyboard keyboard = new Keyboard();

    SoundEngine soundEngine = new SoundEngine();

    Font font = LoadFont("textures/roboto_slab.ttf");
    GenTextureMipmaps(&font.texture);
    SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_TRILINEAR);

    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    PhysicsEngine physicsEngine = new PhysicsEngine();

    bool wasToggle = false;

    Player player = new Player(Vector2(0,0), "singleplayer");


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

        camera.firstPersonLook(mouse);

        /// Simulate higher FPS precision
        double timeAccumalator = physicsEngine.getTimeAccumulator() + delta;
        immutable double lockedTick = physicsEngine.getLockedTick();

        /*
        /// Literally all IO with the physics engine NEEDS to happen here!
        while(timeAccumalator >= lockedTick) {

            // player.move(camera, keyboard);

            physicsEngine.update();

            timeAccumalator -= lockedTick;
        }
        */

        physicsEngine.setTimeAccumulator(timeAccumalator);

        // player.processFootsteps(soundEngine);
        

        // writeln(rotation);
        // camera.setRotation(rotation);


        /// End internal calculations, begin draw

        // camera.updateTarget(player.getCenter());


        BeginDrawing();
        {

            camera.clear(Colors.WHITE);

            camera.update();
            
            { // Begin 3d
                BeginMode3D(camera.get());

                // map.draw(player.getCenter());

                // Rectangle aabb = player.getBoundingBox();

                // DrawRectangle(cast(int)aabb.x, cast(int)aabb.y, cast(int)aabb.width, cast(int)aabb.height, Colors.RED);

                // DrawCircle3D(Vector3(0,0,0), 1,Vector3(0,1,0), 1, Colors.RED);
                DrawSphere(Vector3(1,0,0), 1, Colors.RED);
                EndMode3D();
            }

            // DrawTextEx(font, "Zombie Game 0.0.0", Vector2(10,10), 30, 1, Colors.BLACK);
            // DrawTextEx(font, "Zombie Game 0.0.0", Vector2(7,7), 30, 1, Colors.GREEN);

        }
        EndDrawing();
    }
}
