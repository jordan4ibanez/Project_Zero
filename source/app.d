import std.stdio;

import raylib;
import lua;
import delta_time;
import camera;
import mouse;
import keyboard;
import physics;

import dmech.rigidbody;
import dmech.shape;

void main()
{

    validateRaylibBinding();

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    InitWindow(800,600, "D Raylib Zombie Game 0.0.0");

    SetTargetFPS(60);


    GameCamera camera3d = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera3d);

    Keyboard keyboard = new Keyboard();

    Physics physics = new Physics();

    RigidBody ground =  physics.addGround();

    Vector3 groundPosition = cast(Vector3)ground.position;
    Vector4 groundRotation = cast(Vector4)ground.orientation;

    RigidBody ball = physics.addBody();

    float oldSpeed = 0;
    

    while(!WindowShouldClose()) {

        calculateDelta();

        /// Begin internal calculations

        physics.update();

        Vector3 ballPosition = cast(Vector3)ball.position;
        Vector4 ballRotation = cast(Vector4)ball.orientation;


        Vector3 ballSpeed = cast(Vector3)ball.linearVelocity;

        float speed = ballSpeed.y;

        if (oldSpeed < 0 && speed > 0) {
            writeln("bonk");
        }
        
        oldSpeed = speed;

        writeln(ballSpeed);

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
                DrawCube(groundPosition, 40, 1, 40, Colors.GREEN);


                ballPosition.y -= .5;

                DrawSphere(ballPosition, 1, Colors.BLACK);

                
                DrawCube(Vector3(-10,0,0),2,2,2,Colors.RED);
                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLUE);
                DrawCube(Vector3(2,10,0),2,2,2,Colors.YELLOW);
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
