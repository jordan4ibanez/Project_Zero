import std.stdio;

import raylib;
import lua;
import camera;
import mouse;
import keyboard;
import physics;
import sound_engine;
import delta;

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

    SetTargetFPS(144);

    DeltaCalculator deltaCalculator = new DeltaCalculator();


    GameCamera camera3d = new GameCamera(Vector3(0,0,0));

    Mouse mouse = new Mouse();
    mouse.grab(camera3d);

    Keyboard keyboard = new Keyboard();
    
    PhysicsEngine physicsEngine = new PhysicsEngine();

    RigidBody ground =  physicsEngine.addGround();

    Vector3 groundPosition = cast(Vector3)ground.position;
    Vector4 groundRotation = cast(Vector4)ground.orientation;

    RigidBody ball = physicsEngine.addBody();

    float oldSpeed = 0;

    float oldY = 10_000;

    SoundEngine soundEngine = new SoundEngine();

    // soundEngine.enableDebugging();
    
    // soundEngine.cacheSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    soundEngine.playSound("sounds/sounds_hurt.ogg");

    while(!WindowShouldClose()) {


        deltaCalculator.calculateDelta();

        double delta = deltaCalculator.getDelta();

        Vector3 movementSpeed = Vector3Multiply(Vector3(delta, delta, delta), Vector3(10, 10, 10));

        /// Freecam 2d test
        if (keyboard.getForward()) {
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), movementSpeed);
            camera3d.movePosition(direction);
        
        } else if (keyboard.getBack()) {
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        if (keyboard.getRight()) {
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), movementSpeed);
            camera3d.movePosition(direction);
        } else if (keyboard.getLeft()) {
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        if (keyboard.getJump()) {
            Vector3 direction = Vector3Multiply(camera3d.getUp2d(), movementSpeed);
            camera3d.movePosition(direction);
        } else if (keyboard.getRun()) {
            Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            camera3d.movePosition(direction);
        }
        
        /// Begin physics engine
        
        /// Simulate higher FPS precision
        double timeAccumalator = physicsEngine.getTimeAccumulator() + delta;
        immutable double lockedTick = physicsEngine.getLockedTick();

        /// Literally all IO with the physics engine NEEDS to happen here!
        while(timeAccumalator >= lockedTick) {


            if(keyboard.getLeanRight()) {
                ball.linearVelocity.y += lockedTick * 100;
            }

            physicsEngine.update();

            timeAccumalator -= lockedTick;
        }

        physicsEngine.setTimeAccumulator(timeAccumalator);



        /// Begin internal calculations

        Vector3 ballPosition = cast(Vector3)ball.position;
        Vector4 ballRotation = cast(Vector4)ball.orientation;


        Vector3 ballSpeed = cast(Vector3)ball.linearVelocity;

        float speed = ballSpeed.y;

        if (oldSpeed < 0 && speed > 0) {
            soundEngine.playSound("sounds/bonk.ogg");
        }
        
        oldSpeed = speed;

        if (ballPosition.y > oldY) {
            writeln("physics error?");
            writeln(ballPosition.y, " ", oldY);
        }

        oldY = ballPosition.y;

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
