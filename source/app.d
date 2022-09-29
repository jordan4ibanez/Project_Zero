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
import fast_noise;
import std.math.traits: isNaN;

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

    int size = 250;

    FNLState noiseEngine = fnlCreateState(1234);
    noiseEngine.noise_type = FNLNoiseType.FNL_NOISE_OPENSIMPLEX2;
    noiseEngine.frequency = 0.01;
    noiseEngine.octaves = 10;

    for (int x = 0; x < size; x++) {
        for (int z = 0; z < size; z++) {
            heightMap ~= fnlGetNoise2D(&noiseEngine, x, z) * 5;
        }
    }
    
    world.uploadHeightMap(heightMap, 1);

    Vector3 velocity = Vector3(0,0,0);

    Vector3 playerPos = Vector3(50,10,51);

    // MapQuad begin = world.heightMap[0];
    // MapQuad end   = world.heightMap[62000];

    // writeln(begin.position, " ", end.position);

    // world.collidePointToMap(Vector3(0,0,0));
    // world.collidePointToMap(Vector3(248,0,248));

    // world.getQuad(1, 249);
    // world.getQuad(2, 0);

    while(!WindowShouldClose()) {

        deltaCalculator.calculateDelta();

        double delta = deltaCalculator.getDelta();

        window.update();

        mouse.update();

        keyboard.update();

        velocity.y -= 0.01;

        writeln(playerPos.y);
        /// First person movement test
        Vector3 movementSpeed = Vector3Multiply(Vector3(delta, delta, delta), Vector3(0.1, 0.0, 0.1));
        if (keyboard.getForward()) {
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
            
        } else if (keyboard.getBack()) {
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getRight()) {
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        } else if (keyboard.getLeft()) {
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getJump()) {
            Vector3 direction = Vector3Multiply(camera3d.getUp2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        } else if (keyboard.getRun()) {
            Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }

        Vector2 velocity2d = Vector2(velocity.x, velocity.z);
        float speedLimit = 0.05;

        if (Vector2Length(velocity2d) > speedLimit) {
            writeln("slow down there buddy");
            velocity2d = Vector2Normalize(velocity2d);
            velocity2d = Vector2Multiply(velocity2d, Vector2(speedLimit,speedLimit));

            velocity.x = velocity2d.x;
            velocity.z = velocity2d.y;
        }


        playerPos = Vector3Add(playerPos, velocity);

        float collisionPoint = world.collidePointToMap(playerPos);
        
        bool onGround = false;

        if (!isNaN(collisionPoint)){
            onGround = true;
            playerPos.y = collisionPoint;
            velocity.y = 0;
        }

        if (onGround) {
            Vector3 inverseDirection = Vector3Normalize(Vector3(velocity.x, 0, velocity.z));
            inverseDirection.x *= (-0.06 * delta);
            inverseDirection.z *= (-0.06 * delta);
            velocity = Vector3Add(velocity, inverseDirection);


            if (Vector2Length(Vector2(velocity.x, velocity.z)) < 0.01 * delta) {
                velocity.x = 0;
                velocity.z = 0;
            } 
        }


        camera3d.setPosition(Vector3(playerPos.x, playerPos.y + 1.5, playerPos.z));

        bool togglingFullScreen = keyboard.getToggleFullScreen();

        if (togglingFullScreen && !wasToggle) {
            window.toggleFullScreen();
        }

        wasToggle = togglingFullScreen;

        

        

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
                
                world.drawTerrain();
                // world.drawHeightMap();

                DrawSphere(playerPos, 0.1, Colors.RED);

            }
            EndMode3D();

            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }

}
