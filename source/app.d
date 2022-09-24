import std.stdio;

import raylib;
import lua;
import camera;
import mouse;
import keyboard;
import physics;
import sound_engine;
import delta;
import window;

void main()
{

    validateRaylibBinding();

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    Window window = new Window(1280,720);


    SetTargetFPS(144);

    DeltaCalculator deltaCalculator = new DeltaCalculator();


    GameCamera camera = new GameCamera(Vector2(0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera);

    Keyboard keyboard = new Keyboard();
    


    SoundEngine soundEngine = new SoundEngine();

    soundEngine.playSound("sounds/sounds_hurt.ogg");

    bool wasToggle = false;

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


        /// End internal calculations, begin draw


        BeginDrawing();
        {
            
            

           


            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }
}
