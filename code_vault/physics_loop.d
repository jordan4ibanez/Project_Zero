module code_vault.physics_loop;


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