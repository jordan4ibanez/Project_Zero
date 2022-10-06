module game.game;

import std.stdio;

import engine.camera;
import engine.keyboard;
import engine.mouse;
import engine.time_keeper;
import engine.sound_engine;
import engine.window;
import engine.world;
import game.player;
import raylib;



/// This needs to be moved into it's own object
import fast_noise;

public class Game {

    Window window;
    GameCamera camera3d;
    Mouse mouse;
    Keyboard keyboard;
    TimeKeeper timeKeeper;
    Player player;
    //private  Lua lua <- lua will be OOP too!
    SoundEngine soundEngine;
    World world;


    Texture testTexture;

    Model head;
    ModelAnimation* headAnimation;

    Model torso;
    ModelAnimation* torsoAnimation;

    Model legs;
    ModelAnimation* legsAnimation;
    
    uint torsoAnimationCount;
    uint legsAnimationCount;
    uint headAnimationCount;

    this() {
        /// Game sets up Raylib
        validateRaylibBinding();
        SetTraceLogLevel(TraceLogLevel.LOG_NONE);

        /// Allow objects to communicate with eachother
        window      = new Window(this, 1280,720);
        camera3d    = new GameCamera(this, Vector3(0,50,0));
        keyboard    = new Keyboard(this);
        mouse       = new Mouse(this);
        soundEngine = new SoundEngine(this);
        timeKeeper  = new TimeKeeper(this);
        world       = new World(this);
        player      = new Player(this, Vector3(3,0,2));


        testTexture = LoadTexture("textures/bricks.png");

        torso = LoadModel("models/torso.iqm"); 
        torso.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = testTexture;
        this.torsoAnimation = LoadModelAnimations("models/torso.iqm", &this.torsoAnimationCount);

        legs = LoadModel("models/legs.iqm"); 
        legs.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = testTexture;
        this.legsAnimation = LoadModelAnimations("models/legs.iqm", &this.legsAnimationCount);

        head = LoadModel("models/head.iqm"); 
        head.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = testTexture;
        this.headAnimation = LoadModelAnimations("models/head.iqm", &this.headAnimationCount);

        writeln("ANIMATION COUNT HEAD: ", headAnimationCount);
        writeln("ANIMATION COUNT TORSO: ", torsoAnimationCount);
        writeln("ANIMATION COUNT LEGS: ", legsAnimationCount);

        /// Temporary debugging things
        mouse.grab();

        import std.random;

        Random randy = Random(unpredictableSeed());

        float[] heightMap;

        /// testing out a random map!

        int size = 250;

        /*
        for (int i = 0; i < 2; i++) {
            Entity myNewEntity = new Entity(
                //Vector3((i % size) + uniform(-3.0, 3.0, randy) + 3.5 ,(i + 3) * 4, 50 + uniform(-3.0, 3.0, randy) + 3.5),
                Vector3(1 + uniform(-1.0, 1.0, randy),0, 1 + uniform(-1.0, 1.0, randy)),
                // Vector3(((i + 50) / 10) + uniform(-0.1, 0.1, randy) ,(i + 3) * 4, 50 + uniform(-0.1, 0.1, randy)),
                //Vector2(uniform(0.51, 3.9, randy), uniform(0.51, 3.9, randy)),
                Vector2(0.51,1.51),

                Vector3(0,0,0), false);
            world.addEntity(myNewEntity);
            /// writeln(myNewEntity.getUUID());
            // boxes ~= physicsEngine.addBox(Vector3(3, 1 + i * 10,0));
        }
        */
        

        FNLState noiseEngine = fnlCreateState(1234);
        noiseEngine.noise_type = FNLNoiseType.FNL_NOISE_OPENSIMPLEX2;
        noiseEngine.frequency = 0.01;
        noiseEngine.octaves = 10;

        for (int x = 0; x < size; x++) {
            for (int z = 0; z < size; z++) {
                heightMap ~= fnlGetNoise2D(&noiseEngine, x, z) * 50;
            }
        }

        world.uploadHeightMap(heightMap, 10);

    }

    ~this() {
        writeln("I'm dead!");
    }

    void run() {
        while (!window.shouldClose()) {

            timeKeeper.calculateDelta();
            window.update();
            mouse.update();
            keyboard.update();

            world.update();

            player.update();
            camera3d.firstPersonLook();
            camera3d.update();

            this.render();
        }
    }

    // animation starts at 1 ends at 60
    private uint frame = 1;
    float frameAccumulator = 0;

    int currentAnimation = 0;

    void render() {
        BeginDrawing();
        {
            BeginMode3D(this.camera3d.get());
            {
                camera3d.clear(Colors.RAYWHITE);

                world.render();

                // Animation is locked to 60 FPS
                frameAccumulator += this.timeKeeper.getDelta();
                if (frameAccumulator > 1.0 / 60.0) {
                    frame++;

                    if (frame >= 60) {
                        frame = 1;
                        currentAnimation++;
                        if (currentAnimation >= torsoAnimationCount) {
                            currentAnimation = 0;
                        }
                        
                    }

                    frameAccumulator -= 1.0 / 60.0;

                    UpdateModelAnimation(head,  headAnimation[2], frame /* * 3*/ );
                    UpdateModelAnimation(torso, torsoAnimation[15], frame);
                    UpdateModelAnimation(legs,  legsAnimation[4], frame);

                }

                DrawModelEx(
                    this.head,     // Model
                    Vector3(2,0.25,2),//this.player.getModelPosition(), // Position  
                    Vector3(0,1,0), // Rotation Axis
                    45.0f,          // Rotation angle
                    Vector3(1,1,1), // Scale
                    Colors.WHITE    // Tint
                );

                DrawModelEx(
                    this.torso,     // Model
                    Vector3(2,0.25,2),//this.player.getModelPosition(), // Position Vector3(2,0.25,2),
                    Vector3(0,1,0), // Rotation Axis
                    45.0f,          // Rotation angle
                    Vector3(1,1,1), // Scale
                    Colors.WHITE    // Tint
                );
                DrawModelEx(
                    this.legs,     // Model
                    Vector3(2,0.25,2),//this.player.getModelPosition(), // Position  
                    Vector3(0,1,0), // Rotation Axis
                    45.0f,          // Rotation angle
                    Vector3(1,1,1), // Scale
                    Colors.WHITE    // Tint
                );

                /*
                Vector3 debugTest = this.player.getModelPosition();
                debugTest.x += 3;

                import std.math.traits: isNaN;
                float collision = world.collidePointToMap(debugTest);
                if (!isNaN(collision)) {
                    debugTest.y = collision;
                }

                debugTest.y += 0.01;

                DrawModelEx(
                    this.torso,     // Model
                    debugTest, // Position Vector3(2,0.25,2),
                    Vector3(0,1,0), // Rotation Axis
                    45.0f,          // Rotation angle
                    Vector3(1,1,1), // Scale
                    Colors.WHITE    // Tint
                );
                DrawModelEx(
                    this.legs,     // Model
                    debugTest, // Position Vector3(2,0.25,2),// 
                    Vector3(0,1,0), // Rotation Axis
                    45.0f,          // Rotation angle
                    Vector3(1,1,1), // Scale
                    Colors.WHITE    // Tint
                );
                */


            }
            EndMode3D();
        }
        EndDrawing();
    }

}