module camera;

import raylib;
import delta_time;

// Wrapper class for the game camera
public class GameCamera {

    private Camera3D camera;

    private bool firstPerson = true;

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

    void setRotation(Vector3 rotation) {
        // Must add position or the camera goes crazy
        Vector3 pos = this.camera.position;
        this.camera.target = Vector3(
            pos.x + rotation.x,
            pos.y + rotation.y,
            pos.z + rotation.z
        );
    }

    Vector3 getRotation() {
        return this.camera.target;
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