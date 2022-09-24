module camera;

import raylib;
import mouse;
import std.math.trigonometry: cos, sin;
import std.math.constants: PI;
import std.algorithm.comparison: clamp;
import window;

/// Wrapper class for the game camera
public class GameCamera {

    private immutable HALF_PI = PI / 2.0;
    private immutable DOUBLE_PI = PI * 2;
    private immutable RAYLIB_FLIP_FIX = 0.0001;

    private Camera2D camera;

    /*
     * This is a flag to ignore one frame from when the mouse was grabbed
     * This is required due to a side effect of GLFW calculations of mouse delta
     */
    private bool ignoreMouseInput = true;


    this() {
        throw new Exception("CANNOT INITIALIZE A CAMERA WITHOUT A POSITION!");
    }

    this(Window window) {
        this.camera            = Camera2D();
        this.camera.offset     = Vector2(window.getWidth() / 2.0, window.getHeight() / 2.0);
        this.camera.target     = Vector2(0,0);
        this.camera.rotation   = 0;
        this.camera.zoom       = 1;
    }

    void clear(Color color) {
        ClearBackground(color);
    }

    void setRotation(float rotation) {
        this.camera.rotation = rotation;
    }

    Camera2D get() {
        return this.camera;
    }


    Camera2D* getPointer() {
        return &this.camera;
    }

    void ignoreFrame() {
        this.ignoreMouseInput = true;
    }


    void firstPersonLook(Mouse mouse) {        
    }

    void updateTarget(Vector2 target) {
        this.camera.target = target;
    }

}