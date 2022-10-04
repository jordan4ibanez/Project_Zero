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
        player      = new Player(this, Vector3(1,0,49));


        /// Temporary debugging things
        mouse.grab();

        import std.random;

        Random randy = Random(unpredictableSeed());

        float[] heightMap;

        /// testing out a random map!

        int size = 250;

        
        for (int i = 0; i < 1; i++) {
            Entity myNewEntity = new Entity(
                Vector3((i % size) + uniform(-3.0, 3.0, randy) + 3.5 ,(i + 3) * 4, 50 + uniform(-3.0, 3.0, randy) + 3.5),
                // Vector3(((i + 50) / 10) + uniform(-0.1, 0.1, randy) ,(i + 3) * 4, 50 + uniform(-0.1, 0.1, randy)),
                Vector2(uniform(0.51, 3.9, randy), uniform(0.51, 3.9, randy)),
                // Vector3(0.51,0.51,0.51),
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

    void render() {
        BeginDrawing();
        {
            BeginMode3D(this.camera3d.get());
            {
                camera3d.clear(Colors.RAYWHITE);

                world.render();
            }
            EndMode3D();
        }
        EndDrawing();
    }

}