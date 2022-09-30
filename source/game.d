module game;

import camera;
import keyboard;
import mouse;
import delta;
import player;
import sound_engine;
import window;

public class Game {

    GameCamera camera;
    Mouse mouse;
    Keyboard keyboard;
    DeltaCalculator deltaCalculator;
    Player player;
    // Lua lua <- lua will be OOP too!
    SoundEngine soundEngine;
    Window window;

    this() {
        
    }
    
}