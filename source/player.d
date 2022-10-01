module player;

import raylib;
import std.stdio;

import game;
import world;
import keyboard;
import camera;

public class Player {

    private Game game;

    private Entity entity;

    private immutable float eyeHeight = 0.25;

    private immutable float physicsEngineDelta;
    private immutable Vector3 movementSpeed;

    private bool wasOnGround = false;

    this(Game game) {
        this.game = game;

        this.entity = new Entity(Vector3(50,20,50), Vector3(0.5,1,0.5),Vector3(0,0,0));

        game.world.addEntity(this.entity);

        this.physicsEngineDelta = game.world.getLockedTick();
        this.movementSpeed = *new Vector3(
            this.physicsEngineDelta / 10.0,
            this.physicsEngineDelta / 10.0,
            this.physicsEngineDelta / 10.0
        );
    }

    void update() {

        this.intakeControls();

        Vector3 position = this.entity.getPosition();

        position.y += this.eyeHeight;

        game.camera3d.setPosition(position);

    }

    void intakeControls() {

        Vector3 velocity = this.entity.getVelocity();

        Keyboard keyboard = game.keyboard;
        GameCamera camera3d = game.camera3d;

        bool changed = false;

        if (keyboard.getForward()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), this.movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getBack()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), this.movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getRight()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), this.movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (keyboard.getLeft()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), this.movementSpeed);
            velocity = Vector3Add(velocity, direction);
        }
        if (wasOnGround && keyboard.getJump()) {
            changed = true;
            velocity = Vector3Add(velocity, Vector3(0,0.25,0));
        } else if (keyboard.getRun()) {
            // Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            // velocity = Vector3Add(velocity, direction);
        }

        if (changed) {
            this.entity.setVelocity(velocity);
        }
    }
}