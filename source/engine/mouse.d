module engine.mouse;

import raylib;
import engine.camera;
import game.game;

/// Wrapper class for mouse interfacing
public class Mouse {

    private Game game;

    private Vector2 position;
    private Vector2 delta;
    private float mouseWheelMove;
    private float sensitivity;
    private bool grabbed = false;
    private bool leftClick = false;
    private bool rightClick = false;

    /// Only initialize after the window has been created
    this(Game game) {
        this.game = game;
        this.position       = GetMousePosition();
        this.delta          = GetMouseDelta();
        this.mouseWheelMove = GetMouseWheelMove();
        this.sensitivity    = 0.001;
    }

    void update() {
        this.position       = GetMousePosition();
        this.mouseWheelMove = GetMouseWheelMove();
        this.delta          = GetMouseDelta();
        this.leftClick      = IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON);
        this.rightClick     = IsMouseButtonDown(MouseButton.MOUSE_RIGHT_BUTTON);
        /// Reset the mouse position
        /// This is a workaround for glfw FLINGING the mouse delta on lock
        if (grabbed) {
            SetMousePosition(0,0);
        }
    }

    bool getLeftClick() {
        return this.leftClick;
    }

    bool getRightClick() {
        return this.rightClick;
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

    void grab() {
        DisableCursor();
        this.grabbed = true;
        game.camera3d.ignoreFrame();
    }

    void release() {
        EnableCursor();
        this.grabbed = false;
    }
}