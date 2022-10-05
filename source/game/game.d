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

    Model testModel;
    Texture testTexture;
    ModelAnimation* testAnimation;
    uint animCount;

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
        player      = new Player(this, Vector3(1,0,1));

        testModel = LoadModel("models/human.iqm"); 
        testTexture = LoadTexture("textures/bricks.png");
        testModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = testTexture;
        this.testAnimation = LoadModelAnimations("models/human.iqm", &this.animCount);

        writeln("ANIMATION COUNT: ", animCount);

        /// Temporary debugging things
        mouse.grab();

        import std.random;

        Random randy = Random(unpredictableSeed());

        float[] heightMap;

        /// testing out a random map!

        int size = 250;

        
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



        writeln("I'm alive!");
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

    void render() {
        BeginDrawing();
        {
            BeginMode3D(this.camera3d.get());
            {
                camera3d.clear(Colors.RAYWHITE);

                world.render();

                // Animation is locked to 60 FPS
                frameAccumulator += timeKeeper.getDelta();
                if (frameAccumulator > 1.0 / 60.0) {
                    frame++;
                    if (frame >= 60) {
                        frame = 1;
                    }
                    frameAccumulator -= 1.0 / 60.0;

                    UpdateModelAnimation(testModel, testAnimation[0], frame);
                }

                // Mesh test = testModel.meshes[0];
                // writeln(test.boneIds[1]);
                // writeln(testAnimation.frameCount);
                
                
                // writeln(*testModel.meshes[0].boneIds);
                //DrawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2f, 0.2f, 0.2f, RED);

                // DrawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2f, 0.2f, 0.2f, RED);

                DrawModel(this.testModel, Vector3(0,1,0), 1, Colors.WHITE);
            }
            EndMode3D();
        }
        EndDrawing();
    }

}