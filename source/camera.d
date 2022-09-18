module camera;

import raylib;
import delta_time;
import mouse;
import std.math.trigonometry: cos, sin;
import std.math.constants: PI;
import std.algorithm.comparison: clamp;
import std.stdio;

private immutable HALF_PI = PI / 2.0;
private immutable DOUBLE_PI = PI * 2;

// Wrapper class for the game camera
public class GameCamera {

    private Camera3D camera;

    private bool firstPerson = true;

    private Vector2 cameraLookRotation;
    private Vector3 cameraFront;
    private Vector3 cameraRight;
    private Vector3 cameraUp;

    this() {
        throw new Exception("CANNOT INITIALIZE A CAMERA WITHOUT A POSITION!");
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
        this.setRotation(this.camera.target);
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

    void firstPersonLook(Mouse mouse) {
        float delta = getDelta();
        Vector2 mouseDelta = mouse.getDelta();
        float sensitivity = mouse.getSensitivity();

        float yaw = this.cameraLookRotation.y += mouseDelta.x * delta * sensitivity;

        float pitch = (
            this.cameraLookRotation.x = clamp(
                this.cameraLookRotation.x + mouseDelta.y * delta * sensitivity,
                -HALF_PI,
                HALF_PI
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
        cameraRight = Vector3Normalize(Vector3CrossProduct(camera.up, cameraFront));
        cameraUp = Vector3CrossProduct(direction, cameraRight);

        this.setRotation(cameraFront);
        
    }

    void setRotation(Vector3 rotation) {
        this.camera.target = Vector3Add(this.camera.position,rotation);
    }

    void setPosition(Vector3 position) {
        this.camera.position = position;
        // Must update the target or the rotation goes crazy
        this.setRotation(this.camera.target);
    }

    Vector3 getPosition() {
        return this.camera.position;
    }

}