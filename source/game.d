module game;

import std.stdio;

import camera;
import keyboard;
import mouse;
import delta;
import player;
import sound_engine;
import window;
import raylib;

public class Game {

    Window window;
    GameCamera camera;
    Mouse mouse;
    Keyboard keyboard;
    DeltaCalculator deltaCalculator;
    Player player;
    // Lua lua <- lua will be OOP too!
    SoundEngine soundEngine;

    this() {
        /// Game sets up Raylib
        validateRaylibBinding();
        SetTraceLogLevel(TraceLogLevel.LOG_NONE);

        window = new Window(1280,720);
        camera = new GameCamera();
        keyboard = new Keyboard();
        mouse = new Mouse();




        writeln("I'm alive!");
    }

    ~this() {
        writeln("I'm dead!");
    }

    void run() {
        writeln("I'm running!");
    }


}