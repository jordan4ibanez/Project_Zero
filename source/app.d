import std.stdio;

import raylib;
import lua;
import delta_time;
import camera;
import mouse;

void main()
{
    validateRaylibBinding();

	if (load_lua()) {
        return;
    }

    InitWindow(800,600, "hi there");

    GameCamera camera = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();

    mouse.grab();


    while(!WindowShouldClose()) {

        calculateDelta();



        BeginDrawing();
        {

            camera.update();
            
            camera.clear(Colors.RAYWHITE);

            BeginMode3D(camera.get());
            {

                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLACK);
                DrawCube(Vector3(0,10,0),2,2,2,Colors.BLACK);

            }
            EndMode3D();


            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }

    CloseWindow();
}
