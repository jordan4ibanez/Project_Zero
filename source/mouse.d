module mouse;

import raylib;
import camera;

/// Wrapper class for mouse interfacing
public class Mouse {

    private Vector2 position;
    private Vector2 delta;
    private float mouseWheelMove;
    private float sensitivity;
    private bool grabbed = false;
    /// Only initialize after the window has been created
    this() {
        this.position       = GetMousePosition();
        this.delta          = GetMouseDelta();
        this.mouseWheelMove = GetMouseWheelMove();
        this.sensitivity    = 0.001;
    }

    void update() {
        this.position       = GetMousePosition();
        this.mouseWheelMove = GetMouseWheelMove();
        this.delta          = GetMouseDelta();
        /// Reset the mouse position
        /// This is a workaround for glfw FLINGING the mouse delta on lock
        if (grabbed) {
            SetMousePosition(0,0);
        }
    }    

    Vector2 getPosition() {
        return this.position;
    }

    Vector2 getDelta() {
        return this.delta;
    }

    float getSensitivity() {
        return this.sensitivity;
    }

    void setSensitivity(float newSensitivity) {
        this.sensitivity = newSensitivity;
    }

    float getMouseWheelMove() {
        return this.mouseWheelMove;
    }

    bool isGrabbed() {
        return this.grabbed;
    }

    void grab(GameCamera camera) {
        DisableCursor();
        this.grabbed = true;
        camera.ignoreFrame();
    }

    void release() {
        EnableCursor();
        this.grabbed = false;
    }
}