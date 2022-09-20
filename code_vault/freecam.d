module code_vault.freecam;

void freecam() {
    /// Freecam test
        if (keyboard.getForward()) {
            Vector3 direction = camera3d.getForward();
            Vector3 position = camera3d.getPosition();
            camera3d.setPosition(Vector3Add(position, direction));
        } else if (keyboard.getBack()) {
            Vector3 direction = camera3d.getForward();
            Vector3 position = camera3d.getPosition();
            direction = Vector3Multiply(direction, Vector3(-1,-1,-1));
            camera3d.setPosition(Vector3Add(position, direction));
        }
        if (keyboard.getRight()) {
            Vector3 direction = camera3d.getRight();
            Vector3 position = camera3d.getPosition();
            camera3d.setPosition(Vector3Add(position, direction));
        } else if (keyboard.getLeft()) {
            Vector3 direction = camera3d.getRight();
            Vector3 position = camera3d.getPosition();
            direction = Vector3Multiply(direction, Vector3(-1,-1,-1));
            camera3d.setPosition(Vector3Add(position, direction));
        }
        if (keyboard.getJump()) {
            Vector3 direction = camera3d.getUp();
            Vector3 position = camera3d.getPosition();
            camera3d.setPosition(Vector3Add(position, direction));
        } else if (keyboard.getRun()) {
            Vector3 direction = camera3d.getUp();
            Vector3 position = camera3d.getPosition();
            direction = Vector3Multiply(direction, Vector3(-1,-1,-1));
            camera3d.setPosition(Vector3Add(position, direction));
        }
}