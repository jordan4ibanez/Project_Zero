module camera;

import raylib;
import mouse;
import std.math.trigonometry: cos, sin;
import std.math.constants: PI;
import std.algorithm.comparison: clamp;

/// Wrapper class for the game camera
public class GameCamera {

    private immutable HALF_PI = PI / 2.0;
    private immutable DOUBLE_PI = PI * 2;
    private immutable RAYLIB_FLIP_FIX = 0.0001;

    private Camera2D camera;

    private bool firstPerson = true;

    /*
     * This is a flag to ignore one frame from when the mouse was grabbed
     * This is required due to a side effect of GLFW calculations of mouse delta
     */
    private bool ignoreMouseInput = true;


    this() {
        throw new Exception("CANNOT INITIALIZE A CAMERA WITHOUT A POSITION!");
    }

    this(Vector2 position) {
        this.camera            = Camera2D();
        this.camera.offset     = position;
        this.camera.target     = Vector2(1,0);
        
        this.camera.rotation   = 0;

        // Again needs to update rotation target
        // this.setRotation(Vector3(-1,0,0));
    }

    void setFirstPerson(bool isFirstPerson) {
        this.firstPerson = isFirstPerson;
    }

    bool getFirstPerson() {
        return this.firstPerson;
    }

    void clear(Color color) {
        ClearBackground(color);
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

}