module game.player;

import raylib;
import std.stdio;

import engine.world;
import engine.keyboard;
import engine.camera;
import engine.models;

import game.game;

/*

Every frame besides the head pitch is 1-60

head:
90 is the 0 so subtract by 90 or something
0 to 180 : pitch

0 - stand pitch

Play this animation in reverse when standing back up
1 - stand to crouch animation

2 - crouch pitch

torso:
0  - stand idle animation
1  - walk
2  - run

Hold the last frame (60) when complete
3  - aiming

4  - cycle-gun
5  - toggle-safety

Play this in reverse when a player isn't holding right click anymore
6  - into-fighting
7  - punch

Loop frames 15-45 for continued animation
8  - craft

Loop frames 15-45 for continued animation
9  - eat

Play this animation in reverse when standing back up
10 - stand-to-crouch

11 - crouch idle animation
12 - crouch-walk

Hold the last frame (60) when complete
13 - crouch-aiming

14 - crouch-cycle-gun
15 - crouch-toggle-safety

Play this in reverse when a player isn't holding right click anymore
16 - crouch-into-fighting
17 - crouch-punch

Loop frames 15-45 for continued animation
18 - crouch-craft

Loop frames 15-45 for continued animation
19 - crouch-eat


legs:
Lock this to frame 1 so it doesn't do anything, animation looks strange
0 - stand idle animation

1 - walk
2 - run

Play this animation in reverse when standing back up
3 - stand-to-crouch

4 - crouch-walk

*/

public class Player {

    private Game game;

    private Entity entity;

    private GameModel head;
    private GameModel torso;
    private GameModel legs;

    private immutable float eyeHeightStand = 1.45;
    private immutable float modelYAdjust = 0.06;

    private immutable float physicsEngineDelta;
    private immutable Vector3 movementSpeed;

    private bool wasOnGround = false;

    //______________________________________
    /// Animation fields                    |
    //______________________________________|
    private int   headAnimation    = 0;  // |
    private int   headFrame        = 0;  // |
    private float headAccumulator  = 0.0;// |
    private float headFrameSpeed   = 0.0;// |
    //--------------------------------------|
    private int torsoAnimation     = 0;  // |
    private int torsoFrame         = 0;  // |
    private float torsoAccumulator = 0.0;// |
    private float torsoFrameSpeed  = 0.0;// |
    //--------------------------------------|
    private int legsAnimation      = 0;  // |
    private int legsFrame          = 0;  // |
    private float legsAccumulator  = 0.0;// |
    private float legsFrameSpeed   = 0.0;// |
    //--------------------------------------|

    this(Game game, Vector3 position, GameModel head, GameModel torso, GameModel legs) {
        this.game = game;

        this.entity = new Entity(position, Vector2(0.51,1.8),Vector3(0,0,0), true);

        game.world.addEntity(this.entity);

        this.physicsEngineDelta = game.world.getLockedTick();
        this.movementSpeed = Vector3(
            this.physicsEngineDelta / 4.0,
            this.physicsEngineDelta / 4.0,
            this.physicsEngineDelta / 4.0
        );

        this.head  = head;
        this.torso = torso;
        this.legs  = legs;
    }

    void update() {
        this.intakeControls();
    }

    void intakeControls() {
        if (!game.world.didTick()) {
            return;
        }
        // Don't allow player to control in mid air
        if (!this.entity.wasOnTheGround()) {
            return;
        }
        // We're talking to the next engine steps here so it gets kinda weird
        this.entity.appliedForce = false;

        Keyboard keyboard = game.keyboard;
        GameCamera camera3d = game.camera3d;

        bool changed = false;

        Vector3 addingVelocity = Vector3(0,0,0);

        if (keyboard.getForward()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getForward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getBack()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getBackward2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getRight()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getRight2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getLeft()) {
            changed = true;
            Vector3 direction = Vector3Multiply(camera3d.getLeft2d(), this.movementSpeed);
            addingVelocity = Vector3Add(addingVelocity, direction);
        }
        if (keyboard.getJump()) {
            changed = true;
            addingVelocity = Vector3Add(addingVelocity, Vector3(0,0.25,0));
            writeln("jumped");
        } else if (keyboard.getRun()) {
            // Vector3 direction = Vector3Multiply(camera3d.getDown2d(), movementSpeed);
            // velocity = Vector3Add(velocity, direction);
        }

        if (changed) {
            this.entity.addVelocity(addingVelocity);
            this.entity.appliedForce = true;
        }

    }

    Vector3 getPosition() {
        return this.entity.getCollisionBoxPosition();
    }

    Vector3 getModelPosition() {
        Vector3 modelPosition = this.entity.getCollisionBoxPosition();
        modelPosition.y += modelYAdjust;
        return modelPosition;
    }

    float getEyeHeightStand() {
        return this.eyeHeightStand;
    }
}