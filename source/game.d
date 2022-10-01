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

public class Game {

    Window window;
    GameCamera camera;
    Mouse mouse;
    Keyboard keyboard;
    TimeKeeper timeKeeper;
    Player player;
    // Lua lua <- lua will be OOP too!
    SoundEngine soundEngine;

    this() {
        /// Game sets up Raylib
        validateRaylibBinding();
        SetTraceLogLevel(TraceLogLevel.LOG_NONE);

        window      = new Window(1280,720);
        camera      = new GameCamera();
        keyboard    = new Keyboard();
        mouse       = new Mouse();
        player      = new Player(Vector3(0,0,0));
        soundEngine = new SoundEngine();
        timeKeeper  = new TimeKeeper();




        writeln("I'm alive!");
    }

    ~this() {
        writeln("I'm dead!");
    }

    void run() {
        writeln("I'm running!");
    }


}