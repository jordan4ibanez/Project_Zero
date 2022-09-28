import std.stdio;

import raylib;
import lua;
import camera;
import mouse;
import keyboard;
import world;
import sound_engine;
import delta;
import window;
import std.random;

void main()
{

    validateRaylibBinding();

    SetTraceLogLevel(TraceLogLevel.LOG_NONE);

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    Window window = new Window(1280,720);


    SetTargetFPS(144);

    DeltaCalculator deltaCalculator = new DeltaCalculator();


    GameCamera camera3d = new GameCamera(Vector3(0,1,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera3d);

    Keyboard keyboard = new Keyboard();
    
    World world = new World();

    // SoundEngine soundEngine = new SoundEngine();

    // soundEngine.enableDebugging();
    
    // soundEngine.cacheSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    bool wasToggle = false;

    Entity[] boxes;
    for (int i = 0; i < 10; i++) {
        boxes ~= new Entity(Vector3(-3,i * 2,0), Vector3(1,1,1), Vector3(0,0,0));
        // boxes ~= physicsEngine.addBox(Vector3(3, 1 + i * 10,0));
    }

    float[] heightMap;

    /// testing out a random map!

    int size = 100;

    Random randy = Random(unpredictableSeed());

    for (int x = 0; x < size; x++) {
        for (int z = 0; z < size; z++) {
            heightMap ~= uniform(0.0, 0.25, randy);
        }
    }

    world.uploadHeightMap(heightMap);
    


    while(!WindowShouldClose()) {


        window.update();

        mouse.update();

        keyboard.update();


        bool togglingFullScreen = keyboard.getToggleFullScreen();

        if (togglingFullScreen && !wasToggle) {
            window.toggleFullScreen();
        }

        wasToggle = togglingFullScreen;

        deltaCalculator.calculateDelta();

        double delta = deltaCalculator.getDelta();

        Vector3 movementSpeed = Vector3Multiply(Vector3(delta, delta, delta), Vector3(10, 10, 10));

        /// Freecam 2d test
        if (keyboard.getForward()) {
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), movementSpeed);
            camera3d.movePosition(direction);
        
        } else if (keyboard.getBack()) {
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        if (keyboard.getRight()) {
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), movementSpeed);
            camera3d.movePosition(direction);
        } else if (keyboard.getLeft()) {
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        if (keyboard.getJump()) {
            Vector3 direction = Vector3Multiply(camera3d.getUp2d(), movementSpeed);
            camera3d.movePosition(direction);
        } else if (keyboard.getRun()) {
            Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        

        /// Begin physics engine
        
        /// Simulate higher FPS precision
        double timeAccumalator = world.getTimeAccumulator() + delta;
        immutable double lockedTick = world.getLockedTick();

        /// Literally all IO with the physics engine NEEDS to happen here!
        while(timeAccumalator >= lockedTick) {


            timeAccumalator -= lockedTick;
        }

        world.setTimeAccumulator(timeAccumalator);



        /// Begin internal calculations
        

        camera3d.firstPersonLook(mouse);

        camera3d.update();

        /// End internal calculations, begin draw

        BeginDrawing();
        {
            
            camera3d.clear(Colors.RAYWHITE);

            BeginMode3D(camera3d.get());
            {
                // DrawCube(groundPosition, 40, 1, 40, Colors.GREEN);


                
                foreach (Entity box; boxes) {
                    box.drawCollisionBox();                
                }
                
                world.drawHeightMap();
                /*
                DrawCube(Vector3(-10,0,0),2,2,2,Colors.RED);
                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLUE);
                DrawCube(Vector3(0,10,0),2,2,2,Colors.YELLOW);
                DrawCube(Vector3(0,-10,0),2,2,2,Colors.GREEN);
                DrawCube(Vector3(0,0,10),2,2,2,Colors.BEIGE);
                DrawCube(Vector3(0,0,-10),2,2,2,Colors.DARKGRAY);
                */

            }
            EndMode3D();

            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }

}
