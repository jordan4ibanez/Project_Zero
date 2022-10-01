module game;

import std.stdio;

import camera;
import keyboard;
import mouse;
import time_keeper;
import player;
import sound_engine;
import window;
import raylib;
import world;


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
        window      = new Window(this, 1280,720, 3000);
        camera3d    = new GameCamera(this, Vector3(0,50,0));
        keyboard    = new Keyboard(this);
        mouse       = new Mouse(this);
        soundEngine = new SoundEngine(this);
        timeKeeper  = new TimeKeeper(this);
        world       = new World(this);
        player      = new Player(this);


        /// Temporary debugging things
        mouse.grab();

        for (int i = 0; i < 800; i++) {
            Entity myNewEntity = new Entity(Vector3(i ,(i + 3) * 4, 50), Vector3(1,1,1), Vector3(0,0,0), false);
            world.addEntity(myNewEntity);
            /// writeln(myNewEntity.getUUID());
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