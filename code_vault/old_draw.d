module code_vault.old_draw;

 BeginMode3D(camera3d.get());
            {
                DrawCube(groundPosition, 40, 1, 40, Colors.GREEN);


                ballPosition.y -= .5;

                DrawSphere(ballPosition, 1, Colors.BLACK);

                
                DrawCube(Vector3(-10,0,0),2,2,2,Colors.RED);
                DrawCube(Vector3(10,0,0),2,2,2,Colors.BLUE);
                DrawCube(Vector3(0,10,0),2,2,2,Colors.YELLOW);
                DrawCube(Vector3(0,-10,0),2,2,2,Colors.GREEN);
                DrawCube(Vector3(0,0,10),2,2,2,Colors.BEIGE);
                DrawCube(Vector3(0,0,-10),2,2,2,Colors.DARKGRAY);

            }
            EndMode3D();