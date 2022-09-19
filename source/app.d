import std.stdio;

import raylib;
import lua;
import delta_time;
import camera;
import mouse;
import keyboard;
import physics;

void main()
{
    /// This is just awesome!
    validateRaylibBinding();

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    /// Load physics engine
    if (loadNewtonLibrary()) {
        return;
    }

    InitWindow(800,600, "D Raylib Zombie Game 0.0.0");

    SetTargetFPS(144);

    GameCamera camera3d = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera3d);

    Keyboard keyboard = new Keyboard();

    Physics physics = new Physics();
    physics.addEntity();


    while(!WindowShouldClose()) {

        calculateDelta();

        /// Begin internal calculations

        mouse.update();

        keyboard.update();

        camera3d.firstPersonLook(mouse);

        camera3d.update();

        /// End internal calculations, begin draw


        BeginDrawing();
        {
            
            camera3d.clear(Colors.RAYWHITE);

            BeginMode3D(camera3d.get());
            {

                DrawCube(Vector3(-10,0,0),2,2,2,Colors.RED);
                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLUE);
                DrawCube(Vector3(0,10,0),2,2,2,Colors.YELLOW);
                DrawCube(Vector3(0,-10,0),2,2,2,Colors.GREEN);
                DrawCube(Vector3(0,0,10),2,2,2,Colors.BEIGE);
                DrawCube(Vector3(0,0,-10),2,2,2,Colors.DARKGRAY);

            }
            EndMode3D();


            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }

    CloseWindow();
}
