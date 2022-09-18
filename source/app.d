import std.stdio;

import raylib;
import lua;
import delta_time;
import camera;
import mouse;
import keyboard;

void main()
{
    validateRaylibBinding();

	if (load_lua()) {
        return;
    }

    InitWindow(800,600, "hi there");

    SetTargetFPS(30);

    GameCamera camera = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera);

    Keyboard keyboard = new Keyboard();


    while(!WindowShouldClose()) {

        calculateDelta();

        /// Begin internal calculations

        mouse.update();

        keyboard.update();

        camera.firstPersonLook(mouse);

        camera.update();

        /// End internal calculations, begin draw


        BeginDrawing();
        {
            
            camera.clear(Colors.RAYWHITE);

            BeginMode3D(camera.get());
            {

                DrawCube(Vector3(-10,0,0),2,2,2,Colors.RED);
                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLUE);
                DrawCube(Vector3(0,10,0),2,2,2,Colors.BLACK);
                DrawCube(Vector3(0,-10,0),2,2,2,Colors.BLACK);
                DrawCube(Vector3(0,0,10),2,2,2,Colors.GOLD);
                DrawCube(Vector3(0,0,-10),2,2,2,Colors.DARKGRAY);

            }
            EndMode3D();


            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }

    CloseWindow();
}
