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
        window      = new Window(this, 1280,720, 144);
        camera3d    = new GameCamera(this);
        keyboard    = new Keyboard(this);
        mouse       = new Mouse(this);
        player      = new Player(this);
        soundEngine = new SoundEngine(this);
        timeKeeper  = new TimeKeeper(this);
        world       = new World(this);




        writeln("I'm alive!");
    }

    ~this() {
        writeln("I'm dead!");
    }

    void run() {
        writeln("I'm running!");
    }


}