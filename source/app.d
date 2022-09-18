import std.stdio;

import raylib;
import lua;

void main()
{
    validateRaylibBinding();
	if (load_lua()) {
        return;
    }

    InitWindow(800,600, "hi there");

    while(!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        DrawText("hello there", 400, 300, 28, Colors.BLACK);
        EndDrawing();
    }

    CloseWindow();
}
