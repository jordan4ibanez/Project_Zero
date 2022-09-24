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
import player;

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


    GameCamera camera = new GameCamera(window);

    Mouse mouse = new Mouse();
    mouse.grab(camera);

    Keyboard keyboard = new Keyboard();

    SoundEngine soundEngine = new SoundEngine();

    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    bool wasToggle = false;

    Player player = new Player(Vector2(0,0));

    float rotation = 0;


    while(!WindowShouldClose()) {


        window.update(camera);

        mouse.update();

        keyboard.update();


        bool togglingFullScreen = keyboard.getToggleFullScreen();
        if (togglingFullScreen && !wasToggle) {
            window.toggleFullScreen(camera);
        }
        wasToggle = togglingFullScreen;

        deltaCalculator.calculateDelta();

        double delta = deltaCalculator.getDelta();

        // rotation += delta * 100;

        if (rotation > 360) {
            rotation -= 360;
        }

        writeln(rotation);


        camera.setRotation(rotation);


        /// End internal calculations, begin draw

        camera.updateTarget(player.getPosition());


        BeginDrawing();
        {

            camera.clear(Colors.WHITE);
            
            BeginMode2D(camera.get());
            
            DrawText("hello there", 10, 10, 28, Colors.BLACK);

            DrawCircle(cast(int)player.getX(), cast(int)player.getY(), player.getSize(), Colors.RED);

            DrawRectangle(-150 / 2,  150, 150, 150, Colors.YELLOW);
            DrawRectangle(-150 / 2, -300, 150, 150, Colors.BEIGE);

            DrawRectangle(150,  -150 / 2, 150, 150, Colors.GREEN);
            DrawRectangle(-300, -150 / 2, 150, 150, Colors.VIOLET);


            EndMode2D();

        }
        EndDrawing();
    }
}
