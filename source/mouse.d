module mouse;

import raylib;

/// Wrapper class for mouse interfacing
public class Mouse {

    private Vector2 position;
    private Vector2 delta;
    private float mouseWheelMove;
    private float sensitivity;

    /// Only initialize after the window has been created
    this() {
        this.position       = GetMousePosition();
        this.delta          = GetMouseDelta();
        this.mouseWheelMove = GetMouseWheelMove();
        this.sensitivity    = 0.01;
    }

    void update() {
        this.position       = GetMousePosition();
        this.delta          = GetMouseDelta();
        this.mouseWheelMove = GetMouseWheelMove();
    }

    Vector2 getPosition() {
        return this.position;
    }
    Vector2 getDelta() {
        return this.delta;
    }
    float getMouseWheelMove() {
        return this.mouseWheelMove;
    }

    void grab() {
        DisableCursor();
    }

    void release() {
        EnableCursor();
    }
}