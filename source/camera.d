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

    private Camera3D camera;

    private bool firstPerson = true;

    /*
     * This is a flag to ignore one frame from when the mouse was grabbed
     * This is required due to a side effect of GLFW calculations of mouse delta
     */
    private bool ignoreMouseInput = true;

    private Vector2 cameraLookRotation;
    private Vector3 cameraFront;
    private Vector3 cameraRight;
    private Vector3 cameraUp;

    this() {
        this(Vector3(0,0,0));
    }

    this(Vector3 position) {
        this.camera            = Camera();
        this.camera.position   = position;
        this.camera.target     = Vector3(1,0,0);
        this.camera.up         = Vector3(0,1,0);
        this.camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
        this.camera.fovy       = 55;
        this.cameraLookRotation = Vector2(0,0);
        // Again needs to update rotation target
        this.setRotation(Vector3(-1,0,0));
    }

    void setFirstPerson(bool isFirstPerson) {
        this.firstPerson = isFirstPerson;
    }

    bool getFirstPerson() {
        return this.firstPerson;
    }

    void update() {
        UpdateCamera(&this.camera);
    }

    void clear(Color color) {
        ClearBackground(color);
    }

    void setFOV(float FOV) {
        this.camera.fovy = FOV;
    }

    Camera get() {
        return this.camera;
    }
    Camera* getPointer() {
        return &this.camera;
    }

    void ignoreFrame() {
        this.ignoreMouseInput = true;
    }


    void firstPersonLook(Mouse mouse) {

        if (!mouse.isGrabbed()) {
            return;
        }

        Vector2 mouseDelta = mouse.getDelta();

        /// This is a workaround for initial delta being crazy
        if (this.ignoreMouseInput) {
            if (mouseDelta.x == 0 && mouseDelta.y == 0) {
                this.ignoreMouseInput = false;
            }
            return;
        }

        float sensitivity = mouse.getSensitivity();

        float yaw = this.cameraLookRotation.y += mouseDelta.x * sensitivity;

        float pitch = (
            this.cameraLookRotation.x = clamp(
                this.cameraLookRotation.x + mouseDelta.y * sensitivity,
                -HALF_PI + RAYLIB_FLIP_FIX,
                HALF_PI - RAYLIB_FLIP_FIX
            )
        ) + PI;

        /// yaw limiter, precision keeper basically
        if (yaw < 0) {
            yaw += DOUBLE_PI;
            this.cameraLookRotation.y = yaw;
        } else if (yaw > DOUBLE_PI) {
            yaw -= DOUBLE_PI;
            this.cameraLookRotation.y = yaw;
        }

        Vector3 direction;
        

        direction.x = cos(yaw) * cos(pitch);
        direction.y = sin(pitch);
        direction.z = sin(yaw) * cos(pitch);

        cameraFront = Vector3Normalize(direction);
        cameraRight = Vector3Normalize(Vector3CrossProduct(cameraFront, camera.up));
        cameraUp = Vector3CrossProduct(cameraRight, direction);

        this.setRotation(cameraFront);
        
    }

    void setRotation(Vector3 rotation) {
        this.camera.target = Vector3Add(this.camera.position,rotation);
    }

    /// This needs to be removed when this test is done
    void movePosition(Vector3 positionAddition) {
        this.camera.position = Vector3Add(this.camera.position, positionAddition);
        // Must update the target or the rotation goes crazy
        this.setRotation(this.camera.target);
    }

    void setPosition(Vector3 position) {
        this.camera.position = position;
        // Must update the target or the rotation goes crazy
        this.setRotation(this.camera.target);
    }

    Vector3 getPosition() {
        return this.camera.position;
    }

    Vector3 getForward() {
        return this.cameraFront;
    }

    Vector3 getBackward() {
        return Vector3Multiply(this.cameraFront, Vector3(-1,-1,-1));
    }

    Vector3 getRight() {
        return this.cameraRight;
    }

    Vector3 getLeft() {
        return Vector3Multiply(this.cameraRight, Vector3(-1,-1,-1));
    }

    Vector3 getUp() {
        return this.cameraUp;
    }

    Vector3 getDown() {
        return Vector3Multiply(this.cameraUp, Vector3(-1,-1,-1));
    }

    /// Primarily used for 3d first person movement

    Vector3 getForward2d() {
        Vector3 forward = this.cameraFront;
        forward.y = 0;
        return Vector3Normalize(forward);
    }

    Vector3 getBackward2d() {
        Vector3 backward = this.getBackward();
        backward.y = 0;
        return Vector3Normalize(backward);
    }

    Vector3 getRight2d() {
        Vector3 right = this.cameraRight;
        right.y = 0;
        return Vector3Normalize(right);
    }

    Vector3 getLeft2d() {
        Vector3 left = this.getLeft();
        left.y = 0;
        return Vector3Normalize(left);

    }

    /// This is silly, but it makes it easier to work with
    Vector3 getUp2d() {
        return Vector3(0,1,0);
    }

    Vector3 getDown2d() {
        return Vector3(0,-1,0);
    }
}