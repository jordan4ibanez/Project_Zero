module project_zero;

import game;

void main() {

    Game game = new Game();

    game.run();

    // Game cleans itself up

    /*

    

    

    /// Mod API & Integration
	if (loadLuaLibrary()) {
        return;
    }

    // soundEngine.enableDebugging();
    
    // soundEngine.cacheSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_main_menu.ogg");
    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    // soundEngine.playSound("sounds/sounds_hurt.ogg");

    bool wasToggle = false;

    Vector3 velocity = Vector3(0,0,0);

    Vector3 playerPos = Vector3(50,10,51);

    // MapQuad begin = world.heightMap[0];
    // MapQuad end   = world.heightMap[62000];

    // writeln(begin.position, " ", end.position);

    // world.collidePointToMap(Vector3(0,0,0));
    // world.collidePointToMap(Vector3(248,0,248));

    // world.getQuad(1, 249);
    // world.getQuad(2, 0);

    float stepAccumulator = 0;

    Vector3 oldPosition = Vector3(playerPos.x,0, playerPos.z);

    bool wasOnGround = false;

    Vector3 fancyBox = Vector3(playerPos.x - 2, 20, playerPos.z);
    Vector3 fancyBoxVelocity = Vector3(0,0,0);

    while(!WindowShouldClose()) {

        double delta = deltaCalculator.getDelta();

        velocity.y -= 0.01;
        fancyBoxVelocity.y -= 0.001;

        fancyBox = Vector3Add(fancyBox, fancyBoxVelocity);

        /// collliding that fancy box
        BoundingBox fancyBoxBoundingBox = BoundingBox(
            Vector3(fancyBox.x - 0.5, fancyBox.y - 0.5, fancyBox.z - 0.5),
            Vector3(fancyBox.x + 0.5, fancyBox.y + 0.5, fancyBox.z + 0.5)
        );

        {
            float collision = 0;

            Vector3 min = fancyBoxBoundingBox.min;
            Vector3 max = fancyBoxBoundingBox.max;

            bool collide = false;

            collision = world.collidePointToMap(
                Vector3(
                    min.x, 
                    min.y, 
                    min.z
                )
            );

            if (!isNaN(collision) && collision >= fancyBox.y - 0.5) {
                collide = true;
                fancyBox.y = collision + 0.5;
                fancyBoxVelocity.y = 0;
            }

            collision = world.collidePointToMap(
                Vector3(
                    min.x, 
                    min.y, 
                    max.z
                )
            );

            if (!isNaN(collision) && collision >= fancyBox.y - 0.5) {
                collide = true;
                fancyBox.y = collision + 0.5;
                fancyBoxVelocity.y = 0;
            }

            collision = world.collidePointToMap(
                Vector3(
                    max.x, 
                    min.y, 
                    min.z
                )
            );

            if (!isNaN(collision) && collision >= fancyBox.y - 0.5) {
                collide = true;
                fancyBox.y = collision + 0.5;
                fancyBoxVelocity.y = 0;
            }

            collision = world.collidePointToMap(
                Vector3(
                    max.x, 
                    min.y, 
                    max.z
                )
            );

            if (!isNaN(collision) && collision >= fancyBox.y - 0.5) {
                collide = true;
                fancyBox.y = collision + 0.5;
                fancyBoxVelocity.y = 0;
            }

            if (collide) {
                fancyBoxVelocity.x = 0.01;
                fancyBoxVelocity.z = 0.01;
            }
            
        }

        writeln(fancyBox);

        /// writeln(playerPos.y);
        /// First person movement test
        Vector3 movementSpeed = Vector3Multiply(Vector3(delta, delta, delta), Vector3(0.1, 0.0, 0.1));
        if (keyboard.getForward()) {
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
            
        } else if (keyboard.getBack()) {
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getRight()) {
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        } else if (keyboard.getLeft()) {
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (wasOnGround && keyboard.getJump()) {
            velocity = Vector3Add(velocity, Vector3(0,0.25,0));
        } else if (keyboard.getRun()) {
            // Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            // velocity = Vector3Add(velocity, direction);
        }

        Vector2 velocity2d = Vector2(velocity.x, velocity.z);
        float speedLimit = 0.025;

        if (Vector2Length(velocity2d) > speedLimit) {
            /// writeln("slow down there buddy");
            velocity2d = Vector2Normalize(velocity2d);
            velocity2d = Vector2Multiply(velocity2d, Vector2(speedLimit,speedLimit));

            velocity.x = velocity2d.x;
            velocity.z = velocity2d.y;
        }


        playerPos = Vector3Add(playerPos, velocity);

        float collisionPoint = world.collidePointToMap(playerPos);
        
        bool onGround = false;

        if (!isNaN(collisionPoint)){
            onGround = true;
            playerPos.y = collisionPoint;
            velocity.y = 0;
        }

        if (onGround) {
            Vector3 inverseDirection = Vector3Normalize(Vector3(velocity.x, 0, velocity.z));
            inverseDirection.x *= (-0.06 * delta);
            inverseDirection.z *= (-0.06 * delta);
            velocity = Vector3Add(velocity, inverseDirection);


            if (Vector2Length(Vector2(velocity.x, velocity.z)) < 0.01 * delta) {
                velocity.x = 0;
                velocity.z = 0;
            }

            /// Finicky for now, but with fixed timestep won't have to worry about float issues like this

            stepAccumulator += Vector3Distance(Vector3(playerPos.x, 0, playerPos.z), Vector3(oldPosition.x, 0, oldPosition.z));

            if (stepAccumulator >= 2.5) {
                stepAccumulator = 0;

                Random randy = Random(unpredictableSeed());
                int selection = uniform(1,6, randy);
                soundEngine.playSound("sounds/hard_step_" ~ to!string(selection) ~ ".ogg");
            }

            oldPosition = playerPos;
        }


        camera3d.setPosition(Vector3(playerPos.x, playerPos.y + 1.5, playerPos.z));

        bool togglingFullScreen = keyboard.getToggleFullScreen();

        if (togglingFullScreen && !wasToggle) {
            window.toggleFullScreen();
        }

        wasToggle = togglingFullScreen;

        wasOnGround = onGround;

        

        /// Begin physics engine
        
        /// Simulate higher FPS precision
        double timeAccumalator = world.getTimeAccumulator() + delta;
        immutable double lockedTick = world.getLockedTick();

        /// Literally all IO with the physics engine NEEDS to happen here!
        while(timeAccumalator >= lockedTick) {

            timeAccumalator -= lockedTick;
        }

        world.setTimeAccumulator(timeAccumalator);



        /// Begin internal calculations
        

        camera3d.firstPersonLook(mouse);

        camera3d.update();


        /// End internal calculations, begin draw

        {
            

            BeginMode3D(camera3d.get());
            {
                // DrawCube(groundPosition, 40, 1, 40, Colors.GREEN);


                
                foreach (Entity box; boxes) {
                    box.drawCollisionBox();                
                }
                
                world.drawTerrain();
                // world.drawHeightMap();

                DrawSphere(playerPos, 0.1, Colors.RED);

                DrawCube(fancyBox, 1,1,1, Colors.RED);

                DrawSphere(Vector3(
                    fancyBoxBoundingBox.min.x, 
                    fancyBoxBoundingBox.min.y, 
                    fancyBoxBoundingBox.min.z
                ), 0.1, Colors.BLUE);

                DrawSphere(Vector3(
                    fancyBoxBoundingBox.min.x, 
                    fancyBoxBoundingBox.min.y, 
                    fancyBoxBoundingBox.max.z
                ), 0.1, Colors.ORANGE);

                DrawSphere(Vector3(
                    fancyBoxBoundingBox.max.x, 
                    fancyBoxBoundingBox.min.y, 
                    fancyBoxBoundingBox.min.z
                ), 0.1, Colors.DARKPURPLE);

                DrawSphere(Vector3(
                    fancyBoxBoundingBox.max.x, 
                    fancyBoxBoundingBox.min.y, 
                    fancyBoxBoundingBox.max.z
                ), 0.1, Colors.BEIGE);

            }
            EndMode3D();

            // DrawText("hello there", 400, 300, 28, Colors.BLACK);

        }
        EndDrawing();
    }
    */
}
